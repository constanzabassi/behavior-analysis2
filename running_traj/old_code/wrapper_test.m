savepath = ['V:/Connie/results\navigation_correction'];
save_str = ['ex_plots_viewangle_roll_SOM_dataset_maze_reward_frames'];
num_bins  = 25;
% --- choose frame rate (Hz) robustly
if isfield(imaging_st{1,1}(1), 'framerate'), Fs_default = imaging_st{1,1}(1).framerate;
elseif isfield(imaging_st{1,1}(1), 'acq_rate'), Fs_default = imaging_st{1,1}(1).acq_rate;
else, Fs_default = 30; % fallback
end
all_mouse_stats = struct();     % collect per-mouse summaries
for m = 1:length(imaging_st)
    m
    imaging = imaging_st{1,m};
    empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
    good_trials  = setdiff(1:length(imaging),empty_trials);
    imaging_array      = [imaging(good_trials).movement_in_imaging_time];
    imaging_trial_info = [imaging(good_trials).virmen_trial_info];
    log_distance = log_transform_reward_distance(imaging_array); % your function
    heading_deviation = compute_heading_deviation(imaging_array, imaging_trial_info, vel_ball{m,1}, log_distance, num_bins); % trials x bins
    % center-of-mass heading for plotting
    median_viewangle = nanmedian([imaging_array.view_angle]);
    % --- PER-TRIAL CORRECTION STATS + SOM ETAs ---
    per_trial_stats = table();
    som_prop_sig = []; som_betas = []; som_beta_p = []; nSom = 0;
    spatial_stack = [];
    for p = 1:length(good_trials)
        t_idx = p;  % index into imaging_array / heading_deviation
        frames_to_include = [imaging_array(t_idx).maze_frames]; %, imaging_array(t_idx).reward_frames
        % upsample deviation to frame level (your approach)
        hd_frame = imresize(heading_deviation(t_idx,:), [1, numel(frames_to_include)], 'nearest');
        % kinematics & events
        % choose Fs robustly per trial if available:
        if isfield(imaging(good_trials(p)), 'framerate'), Fs = imaging(good_trials(p)).framerate; else, Fs = Fs_default; end
        % distance (cm) vector aligned to frames_to_include
        % Use your vel_ball{m,1}{t,2} if that’s distance-to-reward per frame; otherwise adapt here.
        if ~isempty(vel_ball{m,1}{p,2})
            dist_cm = vel_ball{m,1}{p,2}(:)';
        else
            dist_cm = 1:numel(frames_to_include); % fallback
        end
        % make sure dist_cm matches length
        if numel(dist_cm) ~= numel(frames_to_include)
            dist_cm = imresize(dist_cm, [1, numel(frames_to_include)], 'nearest');
        end
        % kinematics from headings
        K = compute_heading_kinematics(imaging_array(t_idx).view_angle, 1/Fs);
        % restrict to frames_to_include
        K.turn_vel = K.turn_vel(frames_to_include);
        K.turn_acc = K.turn_acc(frames_to_include);
        [ev, drive] = deal([]); params = struct();
        [ev, drive, params] = detect_corrections(hd_frame, K.turn_acc, Fs);
        % stats for this trial
        S = correction_stats_for_trial(imaging_array(t_idx).view_angle, hd_frame, dist_cm, 1:numel(frames_to_include), Fs);
        spatial_stack = cat(2, spatial_stack, S.spatial_p); % nbins x ntrials
        % SOM ETAs (ΔF/F)
        som_cells = all_celltypes{1,m}.som_cells;
        dff_mat   = imaging(good_trials(p)).dff(:, frames_to_include);    % cells x time
        ETA = som_event_triggered(dff_mat, som_cells, ev.onsets, Fs, [2 3]);
        % summarize SOM significance in this trial
        if ~isempty(ETA.sig)
            som_prop_sig(end+1,1) = mean(ETA.sig); %#ok<AGROW>
        else
            som_prop_sig(end+1,1) = NaN; %#ok<AGROW>
        end
        % quick GLM per SOM cell (store beta for drive_lag1 as example)
        if ~isempty(som_cells)
            for c = 1:numel(som_cells)
                cell_dff = dff_mat(som_cells(c), :);
                cell_dff = cell_dff - movmean(cell_dff, round(2*Fs), 2, 'Endpoints','shrink'); % slow baseline removal
                mdl = fit_glm_som(cell_dff, drive, K.turn_vel, Fs);
                b = mdl.Coefficients;
                % pull the first drive term (drive_lag1) if present
                ix = find(strcmp(b.Properties.RowNames,'drive_lag1'));
                if ~isempty(ix)
                    som_betas(end+1,1)   = b.Estimate(ix); %#ok<AGROW>
                    som_beta_p(end+1,1)  = b.pValue(ix);   %#ok<AGROW>
                end
                nSom = nSom + 1;
            end
        end
        % stash per-trial row
        per_trial_stats = [per_trial_stats; table(good_trials(p), S.n_corr, S.rate_per_100, ...
                                  'VariableNames', {'trial_id','n_corrections','corr_per_100cm'})]; %#ok<AGROW>
    end
    % Aggregate per-mouse
    mouse_stats = struct();
    mouse_stats.per_trial = per_trial_stats;
    mouse_stats.corr_per_trial_median = median(per_trial_stats.n_corrections, 'omitnan');
    mouse_stats.corr_per_100cm_median = median(per_trial_stats.corr_per_100cm, 'omitnan');
    mouse_stats.spatial_profile_mean  = nanmean(spatial_stack, 2);   % mean across trials
    mouse_stats.som_prop_sig_median   = median(som_prop_sig, 'omitnan');
    mouse_stats.som_beta_drive_lag1   = som_betas(:);
    mouse_stats.som_beta_p            = som_beta_p(:);
    mouse_stats.nSom                  = nSom;
    all_mouse_stats(m).summary = mouse_stats; %#ok<SAGROW>
    % --------- (Optional) quick significance summaries ----------
    % Is SOM beta > 0 on average?
    if ~isempty(som_betas)
        [~,p_beta] = ttest(som_betas, 0);
        fprintf('[mouse %d] SOM beta(drive_lag1) mean=%.4f, p=%.3g (n=%d cells)\n', ...
                m, mean(som_betas), p_beta, numel(som_betas));
    end
    % --------- Your existing figure (kept as-is) ----------
    figure(1); clf
    for p = 1:min(36, length(good_trials))
        subplot(6,6,p); hold on
        frames_to_include = [imaging_array(p).maze_frames];
        title(num2str(good_trials(p)))
        plot(rescale(imaging_array(p).x_velocity(frames_to_include),-1,1),'k');
        plot((imaging_array(p).view_angle(frames_to_include))-median_viewangle,'color',[0.5 0.5 0.5]);
        plot(imresize(heading_deviation(p,:),[1,length(imaging_array(p).maze_frames)]),'color',[0.7 0.7 0.7]);
        plot(rescale(smooth(mean(imaging(good_trials(p)).dff(all_celltypes{1,m}.som_cells,frames_to_include)),3,'boxcar'),-2,2),'color',[0.17 0.35 0.8]);
        hold off; xlim([1 length(frames_to_include)]); ylim([-4 4])
    end
    % --------- Save figure + summary tables ----------
    if ~isempty(savepath)
        if ~exist(savepath, 'dir'), mkdir(savepath); end
        cd(savepath)
        saveas(1, sprintf('%s_mouse%d.svg', save_str, m));
        saveas(1, sprintf('%s_mouse%d.png', save_str, m));
        % write per-trial table
        writetable(per_trial_stats, sprintf('correction_stats_per_trial_mouse%d.csv', m));
        % write SOM GLM summary
        Tglm = table(mouse_stats.som_beta_drive_lag1, mouse_stats.som_beta_p, ...
                     'VariableNames', {'beta_drive_lag1','p_value'});
        writetable(Tglm, sprintf('som_glm_mouse%d.csv', m));
        % save spatial profile
        sp = mouse_stats.spatial_profile_mean; %#ok<NASGU>
        save(sprintf('spatial_profile_mouse%d.mat', m), 'sp');
    end
end
% Optionally collect all mice into one CSV:
all_rows = [];
for m = 1:length(all_mouse_stats)
    PT = all_mouse_stats(m).summary.per_trial;
    PT.mouse = repmat(m, height(PT), 1);
    all_rows = [all_rows; PT]; %#ok<AGROW>
end
writetable(all_rows, fullfile(savepath, 'correction_stats_all_mice.csv'));
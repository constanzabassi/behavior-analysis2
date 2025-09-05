%% =========================
%  g–j style analysis across datasets  (paper-matched stats + final CI plot)
%  =========================

% ---------- user params ----------
WIN_S      = [2.5 2.5];   % seconds around trigger (in the paper it is ±2.5 s)
SPLIT_T_S  = 1.5;         % evaluate dev/accel at +1.5 s in the paper
% DEV_TH     = pi/12;       % deviation threshold (15°)
% ACC_TH     = 0.8;         % accel threshold (rad/s^2)
% PROM_TH    = 0.2;         % min peak prominence
% REFRAC_S   = 0.30;        % refractory (s)
% TJ_DIST_CM = 10;          % “enter T” when distance-to-reward < this (tune)
Fs_default = 30;          % fallback Hz
num_bins   = 15;          % your trajectory bin count (keep as before)
DEV_LARGE = pi/6;         % h parameters
DEV_SMALL = pi/12;        % h parameters
ACC_STRONG = 1;           % i parameters
ACC_WEAK = 0.5;           % i parameters
TV_TH = 0.5;              % j parameters
turning_threshold = .1;

% ---------- paper’s stats windows ----------
BASE_WIN   = [-1.0, 0.0];    % seconds
RESP_WIN   = [ 0.5, 2];    % seconds (paper:  [ 0.5, 2.5]; )

% ---------- collectors across sessions (for the final CI plot) ----------
panel_names = {'g','h_low','h_high','i_low','i_high','j_low','j_high'};
% store per-session deltas, one number per session (average across events in that session)
group_SOM   = struct(); group_NON = struct(); group_EVENTS_N= struct(); group_EVENTS= struct(); 
for k = 1:numel(panel_names)
    group_SOM.(panel_names{k}) = [];  % append one value per session
    group_NON.(panel_names{k}) = [];
    group_EVENTS_N.(panel_names{k}) = [];
    nm = panel_names{k};
    % Initialize as struct with named fields
    group_EVENTS.(nm).non = [];
            group_EVENTS.(nm).som = [];
    group_EVENTS.(nm).heading_dev = [];
    group_EVENTS.(nm).tv = [];
    group_EVENTS.(nm).ta = [];
%     if ~isfield(group_EVENTS, nm) || ~isstruct(group_EVENTS.(nm))
%         group_EVENTS.(nm) = struct( ...
%             'heading_dev', [], ...
%             'tv', [], ...
%             'ta', []);
%     end
end
session_rows = [];  % to build per-session table at the end

for m = 1:length(imaging_st)
    fprintf('\n==== Dataset %d/%d ====\n', m, length(imaging_st));

    % --- grab dataset-specific things ---
    imaging       = imaging_st{1,m};
    empty_trials  = find(cellfun(@isempty,{imaging.good_trial}));
    good_trials   = setdiff(1:length(imaging), empty_trials);
    imaging_array = [imaging(good_trials).movement_in_imaging_time];
    imaging_trial_info = [imaging(good_trials).virmen_trial_info];
    som_cells     = all_celltypes{1,m}.som_cells(:)';           % per-dataset SOM
    all_cells     = 1:size(imaging(good_trials(1)).dff,1);
    non_sst_cells = setdiff(all_cells, som_cells);               % adjust if you want PV-only

    if isfield(imaging(good_trials(1)),'framerate')
        Fs = imaging(good_trials(1)).framerate;
    else
        Fs = Fs_default;
    end

    % If you don't already have these computed earlier in your loop, do it here:
    [log_distance, reward_distance] = log_transform_reward_distance(imaging_array);
    dx = 1;
%     heading_deviation = compute_heading_deviation_interpolated(imaging_array, imaging_trial_info, reward_distance, log_distance, num_bins, dx)
    heading_deviation = compute_heading_deviation( ...
        imaging_array, imaging_trial_info, vel_ball{m,1}, log_distance, num_bins); % trials x bins

    % --- containers to stack event-triggered segments (for showing traces) ---
    stack = struct('g',[],'h_low',[],'h_high',[],'i_low',[],'i_high',[],'j_low',[],'j_high',[]);
    count = struct('g',0,'h_low',0,'h_high',0,'i_low',0,'i_high',0,'j_low',0,'j_high',0);

    % --- per-session stats accumulators (collect event-level deltas, then average -> session) ---
    sess_SOM = struct('g',[],'h_low',[],'h_high',[],'i_low',[],'i_high',[],'j_low',[],'j_high',[]);
    sess_NON = struct('g',[],'h_low',[],'h_high',[],'i_low',[],'i_high',[],'j_low',[],'j_high',[]);

    for p = 1:length(good_trials)
        if p == 12
            a = 1;
        end
        t_idx  = p;
        frames = [imaging_array(t_idx).maze_frames]; % , imaging_array(t_idx).reward_frames, imaging_array(t_idx).iti_frames
        T = numel(frames);

        % per-frame heading deviation (upsample your per-bin deviations)
        hd = imresize(heading_deviation(t_idx,:), [1, numel(imaging_array(t_idx).maze_frames)], 'nearest');
%         hd = [hd, nan(1, numel(imaging_array(t_idx).maze_frames))];
%         hd = hd(1:T);

        % kinematics from headings
        K  = kinematics_from_heading_local(imaging_array(t_idx).view_angle, Fs);
        tv = K.turn_vel(frames);
        ta = K.turn_acc(frames);

        % distance-to-reward (for defining “enter T”); resize if needed
        if ~isempty(vel_ball{m,1}{p,2})
            dist = vel_ball{m,1}{p,2}(:)'; %this gets the yaw value (2nd index)
            if numel(dist) ~= T, dist = imresize(dist, [1,T], 'nearest'); end
        else
            dist = linspace(100,0,T); % fallback
        end

        % Non-Sst & SOM mean ΔF/F
        dff = imaging(good_trials(p)).z_dff(:, frames);   % cells x time
        som_mean    = mean(dff(som_cells,:),1,'omitnan');
        nonsst_mean = mean(dff(non_sst_cells,:),1,'omitnan');

        % traces to collect around triggers
        traces = struct('nonsst',nonsst_mean,'som',som_mean, ...
                        'heading_dev',hd,'turn_vel',tv,'turn_acc',ta);

        % triggers
        turn_frame = find(abs (imaging_array(p).x_position(2:end)) >= turning_threshold,1,'first');

        x_velocity = imaging_array(p).x_velocity;
        view_angle = imaging_array(p).view_angle;
        
        % Z-score both vectors while ignoring NaNs
        xv = (x_velocity - nanmean(x_velocity)) ./ nanstd(x_velocity);
        va = (view_angle - nanmean(view_angle)) ./ nanstd(view_angle);
        
        % Difference between z-scored signals
        diff_signal = xv - va;
        
        % Find zero-crossings in the diff signal (change in sign)
        cross_frames = find(diff_signal .* circshift(diff_signal,1) < 0);
        
        % Compute distance from original turn_frame
        delta_frames = turn_frame - cross_frames;
        delta_frames(delta_frames < 0) = nan;  % ignore crossings after the turn_frame
        
        % Only update if there's a crossing within a reasonable window
        if any(delta_frames < 100)
            [~, idx] = min(delta_frames);  % find the closest crossing before turn_frame
            updated_turn_frame = cross_frames(idx);
        else
            updated_turn_frame = turn_frame;
        end

        
        tj = updated_turn_frame; %all_frames{m}(p).turn;%find(dist < TJ_DIST_CM, 1, 'first');  % enter T
        [~, accel_peaks] = findpeaks(abs(ta), 'MinPeakHeight',1,'MinPeakProminence',0.3, ...
                                           'MinPeakDistance', round(0.3*Fs)); %max(1, round(0.3*Fs))
        % (correction events available if you want counts)
        % [corr_on, corr_drive] = detect_corrections_local(hd, ta, Fs, DEV_TH, ACC_TH, PROM_TH, REFRAC_S); %#ok<ASGLU>

        %smooth signals for trigger selection (what the paper did)
        gk = gausswin(max(3, round(0.25*Fs))); gk = gk/sum(gk);   % 0.25 s Gaussian
        tv_s = conv(tv, gk, 'same');                               % smoothed for selection
        ta_s = conv(ta, gk, 'same');                               % smoothed for selection
        % g) trigger on entering T  (one event per trial if present)
        if ~isempty(tj)
            ETA = collect_eta_local(tj, WIN_S, Fs, traces);
            if ~isempty(ETA.keep)
                % stack for the multi-panel trace plot
                dev_sign = sign(ETA.heading_dev);  % vector of sign per timepoint
                aligned_tv = ETA.turn_vel .* dev_sign;
                aligned_ta = ETA.turn_acc .* dev_sign;
                
                block = [ETA.nonsst; ETA.som; ETA.heading_dev; aligned_tv; aligned_ta];

%                 block = [ETA.nonsst; ETA.som; ETA.heading_dev; ETA.turn_vel; ETA.turn_acc];
                stack.g = cat(1, stack.g, block); count.g = count.g + 1;

                % paper-style per-event Δ (resp 0.5–2.5 s vs base −1–0 s) for SOM & Non-Sst
                som_d = event_deltas(ETA.som_per_event, ETA.t,BASE_WIN,RESP_WIN);
                non_d = event_deltas(ETA.nonsst_per_event, ETA.t,BASE_WIN,RESP_WIN);
                sess_SOM.g = [sess_SOM.g; som_d]; 
                sess_NON.g = [sess_NON.g; non_d]; 
            end
        end

        % h) trigger on T; split by deviation at +1.5 s
        if ~isempty(tj)
            ETA = collect_eta_local(tj, WIN_S, Fs, traces);
            if ~isempty(ETA.keep)
                t15 = dsearchn(ETA.t', SPLIT_T_S);
                med_abs_dev = median(abs(ETA.heading_dev_per_event(:,t15)), 'omitnan');
%                 block = [ETA.nonsst; ETA.som; ETA.heading_dev; ETA.turn_vel; ETA.turn_acc];

                dev_sign = sign(ETA.heading_dev);  % vector of sign per timepoint
                aligned_tv = ETA.turn_vel .* dev_sign;
                aligned_ta = ETA.turn_acc .* dev_sign;
                
                block = [ETA.nonsst; ETA.som; ETA.heading_dev; aligned_tv; aligned_ta];

                som_d = event_deltas(ETA.som_per_event, ETA.t,BASE_WIN,RESP_WIN);
                non_d = event_deltas(ETA.nonsst_per_event, ETA.t,BASE_WIN,RESP_WIN);

                if abs(ETA.heading_dev(t15)) <  DEV_SMALL %med_abs_dev
                    stack.h_low  = cat(1, stack.h_low,  block); count.h_low  = count.h_low+1;
                    sess_SOM.h_low = [sess_SOM.h_low; som_d]; 
                    sess_NON.h_low = [sess_NON.h_low; non_d]; 
                elseif abs(ETA.heading_dev(t15)) > DEV_LARGE
                    stack.h_high = cat(1, stack.h_high, block); count.h_high = count.h_high+1;
                    sess_SOM.h_high = [sess_SOM.h_high; som_d]; 
                    sess_NON.h_high = [sess_NON.h_high; non_d];
                end
            end
        end

        % i) trigger on T; split by accel at +1.5 s
        if ~isempty(tj)
            ETA = collect_eta_local(tj, WIN_S, Fs, traces);
            if ~isempty(ETA.keep)
                t15 = dsearchn(ETA.t', SPLIT_T_S); %
                med_abs_acc = median(abs(ETA.turn_acc_per_event(:,t15)), 'omitnan');
                %

                dev_sign = sign(ETA.heading_dev);  % vector of sign per timepoint
                aligned_tv = ETA.turn_vel .* dev_sign;
                aligned_ta = ETA.turn_acc .* dev_sign;
                
                block = [ETA.nonsst; ETA.som; ETA.heading_dev; aligned_tv; aligned_ta];

%                 block = [ETA.nonsst; ETA.som; ETA.heading_dev; ETA.turn_vel; ETA.turn_acc];

                som_d = event_deltas(ETA.som_per_event, ETA.t,BASE_WIN,RESP_WIN);
                non_d = event_deltas(ETA.nonsst_per_event, ETA.t,BASE_WIN,RESP_WIN);

                if abs(ETA.heading_dev(t15)) > DEV_LARGE
                    %require high deviations at time SPLIT_T_S
                    dev_sign = sign(ETA.heading_dev(t15));
                    acc_aligned = -dev_sign * ETA.turn_acc(t15);
                    if acc_aligned <  ACC_WEAK%med_abs_acc
                        stack.i_low  = cat(1, stack.i_low,  block); count.i_low  = count.i_low+1;
                        sess_SOM.i_low = [sess_SOM.i_low; som_d]; 
                        sess_NON.i_low = [sess_NON.i_low; non_d]; 
                    elseif acc_aligned > ACC_STRONG
                        stack.i_high = cat(1, stack.i_high, block); count.i_high = count.i_high+1;
                        sess_SOM.i_high = [sess_SOM.i_high; som_d]; 
                        sess_NON.i_high = [sess_NON.i_high; non_d]; 
                    end
                end
            end
        end

        % j) trigger on accel peaks; split by deviation at +1.5 s
        if ~isempty(accel_peaks)
%             % keep only peaks with |turn vel| > 0.5 rad/s at the trigger
%             valid_peaks = accel_peaks(abs(tv(accel_peaks)) > TV_TH);

            % use SMOOTHED signals to pick peaks and apply the velocity gate
            [~, cand] = findpeaks(abs(ta_s), 'MinPeakHeight', 1, ...
                                           'MinPeakProminence', 0.3, ...
                                           'MinPeakDistance', round(0.3*Fs));
            cand = cand(abs(tv_s(cand)) > TV_TH);

            if ~isempty(cand) %~isempty(valid_peaks)
                keep = cand(1);
                for k = 2:numel(cand)
                    if cand(k) - keep(end) > 5*Fs %must be 5 sec apart
                        keep(end+1) = cand(k); 
                    end
                end

                ETA = collect_eta_local(keep, WIN_S, Fs, traces);
                if ~isempty(ETA.keep)
                    % split by heading deviation at time 0 (NOT +1.5 s)
                    t0 = dsearchn(ETA.t', 0);
                    dev0 = abs(ETA.heading_dev(t0));

                    dev_sign = sign(ETA.heading_dev);  % vector of sign per timepoint
                    aligned_tv = ETA.turn_vel .* dev_sign;
                    aligned_ta = ETA.turn_acc .* dev_sign;
                    
                    block = [ETA.nonsst; ETA.som; ETA.heading_dev; aligned_tv; aligned_ta];


%                     block = [ETA.nonsst; ETA.som; ETA.heading_dev; ETA.turn_vel; ETA.turn_acc];
                    som_d = event_deltas(ETA.som_per_event,    ETA.t, BASE_WIN, RESP_WIN);
                    non_d = event_deltas(ETA.nonsst_per_event, ETA.t, BASE_WIN, RESP_WIN);
                    if dev0 < DEV_SMALL
                        % low deviation (< pi/12)
                        stack.j_low   = cat(1, stack.j_low,  block); count.j_low  = count.j_low + 1;
                        sess_SOM.j_low = [sess_SOM.j_low; som_d];
                        sess_NON.j_low = [sess_NON.j_low; non_d];
                    elseif dev0 > DEV_LARGE
                        % high deviation (> pi/6)
                        stack.j_high  = cat(1, stack.j_high, block); count.j_high = count.j_high + 1;
                        sess_SOM.j_high = [sess_SOM.j_high; som_d];
                        sess_NON.j_high = [sess_NON.j_high; non_d];
                    else
                        % middle band (pi/12 .. pi/6): skip to match paper
                    end
                end
            end
        end
    end % trials

    % --- average stacks & plot for this dataset (g–j traces) ---
    taxis = (-round(WIN_S(1)*Fs):round(WIN_S(2)*Fs))/Fs;
    G  = avg_stack_local(stack.g,  taxis);
    H0 = avg_stack_local(stack.h_low,  taxis);
    H1 = avg_stack_local(stack.h_high, taxis);
    I0 = avg_stack_local(stack.i_low,  taxis);
    I1 = avg_stack_local(stack.i_high, taxis);
    J0 = avg_stack_local(stack.j_low,  taxis);
    J1 = avg_stack_local(stack.j_high, taxis);

    figure(900+m); clf
    DATA = {G,H0,H1,I0,I1,J0,J1};
    titlestr = {'g: enter T','h: low dev','h: high dev','i: low accel','i: high accel','j: low dev','j: high dev'};
    rows = {'Non-Sst','SOM','Heading dev (rad)','Turn vel (rad/s)','Turn accel (rad/s^2)'};

    for c = 1:numel(DATA)
        if isempty(DATA{c}), continue; end
        D = DATA{c};
        for r = 1:5
            subplot(5, numel(DATA), (r-1)*numel(DATA)+c); hold on
            switch r
                case 1, plot(D.t, D.nonsst,'Color',[.6 .6 .6],'LineWidth',1.5);
                case 2, plot(D.t, D.som,   'Color',[0.10 0.35 0.80],'LineWidth',1.5);
                case 3, plot(D.t, D.dev,   'k','LineWidth',1.2); ylim([-pi pi]);
                case 4, plot(D.t, D.vel,   'k','LineWidth',1.2);
                case 5, plot(D.t, D.acc,   'k','LineWidth',1.2);
            end
            xline(0,'k:'); yline(0,'k:'); xlim([D.t(1) D.t(end)]);
            if r==1, title(sprintf('%s', titlestr{c})); end
            if c==1, ylabel(rows{r}); end
        end
    end
    set(gcf,'Color','w'); drawnow

    % --- reduce event-level deltas -> one number per session (mean over events) ---
    sess_summary = struct();
    for k = 1:numel(panel_names)
        nm = panel_names{k};
        sess_summary.(['SOM_' nm]) = mean(sess_SOM.(nm), 'omitnan');
        sess_summary.(['NON_' nm]) = mean(sess_NON.(nm), 'omitnan');
        sess_summary.(['nEvents_' nm]) = [numel(sess_SOM.(nm)), numel(sess_NON.(nm))];
    end

%     % --- add to group collectors (one number per session) ---
%     for k = 1:numel(panel_names)
%         nm = panel_names{k};
%         group_SOM.(nm) = [group_SOM.(nm), sess_summary.(['SOM_' nm])]; 
%         group_NON.(nm) = [group_NON.(nm), sess_summary.(['NON_' nm])];
%     end

    %POOL ACROSS DATASETS
    for k = 1:numel(panel_names)
        nm = panel_names{k};
    
        % Pool mean ΔF for SOM and NON per condition (1 value per session)
        group_SOM.(nm) = [group_SOM.(nm), sess_summary.(['SOM_' nm])]; 
        group_NON.(nm) = [group_NON.(nm), sess_summary.(['NON_' nm])];
    
        % Pool event counts (number of trials used in that condition)
        group_EVENTS_N.(nm) = [group_EVENTS_N.(nm), sess_summary.(['nEvents_' nm])(1)];

        trials  = stack.(nm); 
        n_trials = size(trials, 1) / 5;
        % Pool full traces if you want to do population stats or averaging later
        % Pre-allocate if this is the first session
        if ~isfield(group_EVENTS, nm) || ~isstruct(group_EVENTS.(nm))
            group_EVENTS.(nm).non = [];
            group_EVENTS.(nm).som = [];
            group_EVENTS.(nm).heading_dev = [];
            group_EVENTS.(nm).tv = [];
            group_EVENTS.(nm).ta = [];
        end
        % Extract and append each measure
        for t = 1:n_trials
            row_base = (t - 1) * 5;
            group_EVENTS.(nm).non = [group_EVENTS.(nm).non; trials(row_base + 1, :)];
            group_EVENTS.(nm).som = [group_EVENTS.(nm).som; trials(row_base + 2, :)];
            group_EVENTS.(nm).heading_dev = [group_EVENTS.(nm).heading_dev; trials(row_base + 3, :)];
            group_EVENTS.(nm).tv          = [group_EVENTS.(nm).tv;          trials(row_base + 4, :)];
            group_EVENTS.(nm).ta          = [group_EVENTS.(nm).ta;          trials(row_base + 5, :)];
        end
%         for t = 1:n_trials
%             row_base = 5 * (t - 1);
%             group_EVENTS.(nm).heading_dev = [group_EVENTS.(nm).heading_dev; trials(row_base + 3, :)];
%             group_EVENTS.(nm).tv          = [group_EVENTS.(nm).tv; trials(row_base + 4, :)];
%             group_EVENTS.(nm).ta          = [group_EVENTS.(nm).ta; trials(row_base + 5, :)];
%         end
%         group_EVENTS.(nm) = [group_EVENTS.(nm); trials];
%         group_EVENTS.(nm).heading_dev = [group_EVENTS.(nm).heading_dev; trials(3,:)]; % Row = 3
%         group_EVENTS.(nm).tv        = [group_EVENTS.(nm).tv; trials(4,:)];      % Row = 4
%         group_EVENTS.(nm).ta          = [group_EVENTS.(nm).ta; trials(5,:)];      % Row = 5
    end


    % --- save per-session summary row(s) for CSV ---
    % build one table row per panel x celltype for this session
    for k = 1:numel(panel_names)
        nm = panel_names{k};
        session_rows = [session_rows;
            {m, nm, 'SOM', sess_summary.(['SOM_' nm]), sess_summary.(['nEvents_' nm])(1)};
            {m, nm, 'NonSst', sess_summary.(['NON_' nm]), sess_summary.(['nEvents_' nm])(2)}]; %#ok<AGROW>
    end

    % --- optional: save g–j figure per session ---
    if exist('savepath','var') && ~isempty(savepath)
        if ~exist(savepath,'dir'), mkdir(savepath); end
        saveas(900+m, fullfile(savepath, sprintf('gj_panels_mouse%d.png', m)));
        saveas(900+m, fullfile(savepath, sprintf('gj_panels_mouse%d.svg', m)));
    end

end% datasets loop
%%
% Settings
conds = {'h_low', 'h_high', 'i_low', 'i_high', 'j_low', 'j_high'};
n_conds = numel(conds);
t = linspace(-2, 2, size(group_EVENTS.h_low.tv, 2));  % Adjust this as needed

% Set up figure
% figure('Position', [100 100 1600 900]);
rows = 5; cols = n_conds;

% Trial types mapping to descriptive titles from Green et al. (2023)
titles = {
    'T-junction\newlineLow dev.', ...
    'T-junction\newlineHigh dev.', ...
    'Turning acc.\newlineLow', ...
    'Turning acc.\newlineHigh', ...
    'High acc.\newlineLow dev.', ...
    'High acc.\newlineHigh dev.'
};


for c = 1:n_conds
    cond = conds{c};

    % Extract pooled data (rows = trials, cols = frames)
    non = group_EVENTS.(cond).non;   % ΔF/F for Non-Sst trials
    som = group_EVENTS.(cond).som;   % ΔF/F for Sst trials
    hd  = group_EVENTS.(cond).heading_dev;
    tv  = group_EVENTS.(cond).tv;
    ta  = group_EVENTS.(cond).ta;

    % Row 1: Non-Sst ΔF/F
    subplot(rows, cols, c)
    plotWithSEM(t, non, [0.5 0.5 0.5])
    if c == 1, ylabel('Non-SOM'), end
%     title(sprintf('%s\nn = %d', strrep(cond, '_', ' '), size(hd,1)),'FontWeight','normal')
    title(sprintf('%s\nn = %d', titles{c}, size(hd,1)), 'FontWeight','normal', 'FontSize', 8)

    box off
    set(gca,'Fontsize',7)

    % Row 2: Sst ΔF/F
    subplot(rows, cols, cols + c)
    plotWithSEM(t, som, [0.13, 0.24, 0.51])
    if c == 1, ylabel('SOM'), end
    box off
    set(gca,'Fontsize',7)

    % Row 3: Heading deviation
    subplot(rows, cols, 2*cols + c)
    plotWithSEM(t, hd, [0 0 0])
    if c == 1, ylabel({'Heading dev';'(rad)'}), end
    box off
    set(gca,'Fontsize',7)

    % Row 4: Turning velocity
    subplot(rows, cols, 3*cols + c)
    plotWithSEM(t, tv, [0 0 0])
    if c == 1, ylabel({'Turning vel';'(rad/s)'}), end
    box off
    set(gca,'Fontsize',7)

    % Row 5: Turning acceleration
    subplot(rows, cols, 4*cols + c)
    plotWithSEM(t, ta, [0 0 0])
    if c == 1, ylabel({'Turning accel';'(rad/s^2)'}), end
    box off
    xlabel('Time (s)')
    set(gca,'Fontsize',7)
end
set(gcf,'Units', 'inches', 'Position', [1,1,6,5]);
% saveas(gcf, fullfile(savepath, 'pooled_plots.pdf'));
exportgraphics(gcf,fullfile(savepath, 'pooled_plots.pdf'), 'ContentType', 'vector');
%%
% Settings
conds = {'h_low', 'h_high', 'i_low', 'i_high', 'j_low', 'j_high'};
n_conds = numel(conds);
t = linspace(-2, 2, size(group_EVENTS.h_low.tv, 2));

% Set up tiled layout
rows = 5; cols = n_conds;
figure('Units', 'inches', 'Position', [1, 1, 6, 6])
tiledlayout(rows, cols, 'TileSpacing', 'compact', 'Padding', 'compact')

% Store axes for each row to link y-axes
ax_rows = cell(rows, 1);

for c = 1:n_conds
    cond = conds{c};

    % Extract pooled data
    non = group_EVENTS.(cond).non;
    som = group_EVENTS.(cond).som;
    hd  = group_EVENTS.(cond).heading_dev;
    tv  = group_EVENTS.(cond).tv;
    ta  = group_EVENTS.(cond).ta;

    % Row 1: Non-SOM
    ax = nexttile(0 * cols + c);
    plotWithSEM(t, non, [0.5 0.5 0.5]); hold on
    xline(0, '--k', 'LineWidth', 0.75)
    if c == 1, ylabel('Non-SOM'); end
    title(sprintf('%s\nn = %d', strrep(cond, '_', ' '), size(hd,1)), ...
        'FontWeight','normal', 'FontSize', 7)
    ax_rows{1}(end+1) = ax;

    % Row 2: SOM
    ax = nexttile(1 * cols + c);
    plotWithSEM(t, som, [0.13, 0.24, 0.51]); hold on
    xline(0, '--k', 'LineWidth', 0.75)
    if c == 1, ylabel('SOM'); end
    ax_rows{2}(end+1) = ax;

    % Row 3: Heading dev
    ax = nexttile(2 * cols + c);
    plotWithSEM(t, hd, [0 0 0]); hold on
    xline(0, '--k', 'LineWidth', 0.75)
    if c == 1, ylabel('Heading dev (rad)'); end
    ax_rows{3}(end+1) = ax;

    % Row 4: Turning velocity
    ax = nexttile(3 * cols + c);
    plotWithSEM(t, tv, [0 0 0]); hold on
    xline(0, '--k', 'LineWidth', 0.75)
    if c == 1, ylabel('Turning vel (rad/s)'); end
    ax_rows{4}(end+1) = ax;

    % Row 5: Turning acceleration
    ax = nexttile(4 * cols + c);
    plotWithSEM(t, ta, [0 0 0]); hold on
    xline(0, '--k', 'LineWidth', 0.75)
    if c == 1, ylabel('Turning accel (rad/s^2)'); end
    xlabel('Time (s)')
    ax_rows{5}(end+1) = ax;
end

% Style and link axes
for r = 1:rows
    linkaxes(ax_rows{r}, 'y')
    for ax = ax_rows{r}
        set(ax, 'FontSize', 7, 'Box', 'off', 'TickDir', 'out')
        if r < rows
            ax.XTickLabel = [];
        end
    end
end

%%
panel_names = fieldnames(group_EVENTS);
timevec = linspace(-2, 2, size(group_EVENTS.(panel_names{1}), 2));  % adjust if needed

figure;
for i = 1:numel(panel_names)
    nm = panel_names{i};
    data = group_EVENTS.(nm);  % nTrials × nTimepoints

    mean_trace = mean(data, 1, 'omitnan');
    sem_trace  = std(data, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(data), 1));

    % Optional 95% CI (for large samples, Z ≈ 1.96)
    ci95_upper = mean_trace + 1.96 * sem_trace;
    ci95_lower = mean_trace - 1.96 * sem_trace;

    % Plot with shaded area for SEM or CI
    subplot(ceil(numel(panel_names)/3), 3, i);
    hold on;
    fill([timevec, fliplr(timevec)], ...
         [mean_trace + sem_trace, fliplr(mean_trace - sem_trace)], ...
         [0.7 0.7 1], 'EdgeColor', 'none', 'FaceAlpha', 0.4);
    plot(timevec, mean_trace, 'b', 'LineWidth', 1.5);
    title(nm, 'Interpreter', 'none');
    xlabel('Time (s)');
    ylabel('Activity');
    ylim padded;
end

sgtitle('Pooled Event Traces with SEM');

%% -------- final plot: mean ± 95% bootstrapped CI across SESSIONS --------

% build arrays in panel order for SOM / NonSst
SOM_vec = []; NON_vec = [];
for k = 1:numel(panel_names)
    SOM_vec = [SOM_vec; group_SOM.(panel_names{k})(:)]; %#ok<AGROW>
    NON_vec = [NON_vec; group_NON.(panel_names{k})(:)]; %#ok<AGROW>
end

% stats per panel x celltype
stats_rows = {};
muS = zeros(1,numel(panel_names)); loS = muS; hiS = muS; semS = muS; nS = muS;
muN = muS; loN = muS; hiN = muS; semN = muS; nN = muS;

for k = 1:numel(panel_names)
    [muS(k), loS(k), hiS(k), semS(k), nS(k)] = mean_ci_sem(group_SOM.(panel_names{k}));
    [muN(k), loN(k), hiN(k), semN(k), nN(k)] = mean_ci_sem(group_NON.(panel_names{k}));

    stats_rows(end+1,:) = {panel_names{k}, 'SOM',    muS(k), loS(k), hiS(k), semS(k), nS(k)}; 
    stats_rows(end+1,:) = {panel_names{k}, 'NonSst', muN(k), loN(k), hiN(k), semN(k), nN(k)}; 
end

% make the final figure (two rows: SOM & NonSst; error bars = bootstrapped CI)
figure(12345); clf
xpos = 1:numel(panel_names);
subplot(2,1,1); hold on
errorbar(xpos, muS, muS-loS, hiS-muS, 'o-', 'LineWidth',1.5);
xlim([0.5, numel(panel_names)+0.5]); ylabel('ΔF/F (resp − base)');
title('SOM (mean ± 95% bootstrap CI across sessions)'); xticks(xpos); xticklabels(panel_names); grid on
subplot(2,1,2); hold on
errorbar(xpos, muN, muN-loN, hiN-muN, 'o-', 'LineWidth',1.5);
xlim([0.5, numel(panel_names)+0.5]); ylabel('ΔF/F (resp − base)');
title('Non-Sst (mean ± 95% bootstrap CI across sessions)'); xticks(xpos); xticklabels(panel_names); grid on
set(gcf,'Color','w')

% ----- save stats -----
if exist('savepath','var') && ~isempty(savepath)
    if ~exist(savepath,'dir'), mkdir(savepath); end

    % per-session table
    T_sess = cell2table(session_rows, ...
        'VariableNames', {'session_id','panel','celltype','delta_mean','n_events'});
    writetable(T_sess, fullfile(savepath, 'per_session_deltas.csv'));

    % group summary table (mean, CI, SEM, n_sessions)
    T_grp = cell2table(stats_rows, ...
        'VariableNames', {'panel','celltype','mean','ci_lo','ci_hi','sem','n_sessions'});
    writetable(T_grp, fullfile(savepath, 'group_summary_stats.csv'));

    % save the final CI figure
    saveas(12345, fullfile(savepath, 'final_session_mean_CI.png'));
    saveas(12345, fullfile(savepath, 'final_session_mean_CI.svg'));
end


%% ===== local helpers used above (do NOT modify your existing funcs) =====
function a = wrapToPi_local(a), a = mod(a+pi, 2*pi) - pi; end
function K = kinematics_from_heading_local(theta, Fs)
    dv = [0, wrapToPi_local(diff(theta))];
    turn_vel = dv .* Fs;
    da = [0, diff(turn_vel)];
    K.turn_vel = turn_vel;
    K.turn_acc = da .* Fs;
end
function [onsets, drive] = detect_corrections_local(hd, ta, Fs, DEV_TH, ACC_TH, PROM_TH, REFRAC_S)
    sgn = sign(hd); drive = max(0, -sgn .* ta);
    mask = abs(hd) > DEV_TH; x = drive; x(~mask) = 0;
    minDist = max(1, round(REFRAC_S * Fs));
    [~, onsets] = findpeaks(x, 'MinPeakHeight',ACC_TH, 'MinPeakProminence',PROM_TH, 'MinPeakDistance',minDist);
end
function ETA = collect_eta_local(trig_idx, win_s, Fs, traces)
    pre = round(win_s(1)*Fs); post = round(win_s(2)*Fs);
    T = numel(traces.heading_dev); w = -pre:post;
    keep = trig_idx(trig_idx+min(w) > 0 & trig_idx+max(w) <= T);
    ETA.t = w / Fs; ETA.keep = keep; if isempty(keep), return; end
    fns = fieldnames(traces);
    for k = 1:numel(fns)
        v = traces.(fns{k}); M = nan(numel(keep), numel(w));
        for i = 1:numel(keep); M(i,:) = v(keep(i)+w); end
        ETA.(fns{k}) = mean(M,1,'omitnan');
        ETA.([fns{k} '_per_event']) = M;  % keep per-event for stats (resp-base)
    end
end
function OUT = avg_stack_local(stack_block, t)
    OUT = []; if isempty(stack_block), return; end
    K = 5; n = size(stack_block,1)/K;
    M = reshape(stack_block, [K, n, size(stack_block,2)]);
    OUT.t=t; OUT.nonsst=squeeze(mean(M(1,:,:),2,'omitnan'));
    OUT.som=squeeze(mean(M(2,:,:),2,'omitnan'));
    OUT.dev=squeeze(mean(M(3,:,:),2,'omitnan'));
    OUT.vel=squeeze(mean(M(4,:,:),2,'omitnan'));
    OUT.acc=squeeze(mean(M(5,:,:),2,'omitnan'));
end

        % ---- helper to convert event matrices into paper-style Δ (resp - base) per event
function deltas = event_deltas(per_event, tvec,BASE_WIN,RESP_WIN)
    if isempty(per_event), deltas = []; return; end
    base_idx = tvec>=BASE_WIN(1) & tvec<BASE_WIN(2);
    resp_idx = tvec>=RESP_WIN(1) & tvec<RESP_WIN(2);
    b = mean(per_event(:,base_idx), 2, 'omitnan');
    r = mean(per_event(:,resp_idx), 2, 'omitnan');
    deltas = r - b;  % one delta per event
end

% helper: bootstrap CI (2.5/97.5 percentiles of the mean)
function [mu, lo, hi, semv, n] = mean_ci_sem(x, nboot)
    if nargin<2, nboot = 10000; end
    x = x(:); x = x(~isnan(x));
    n = numel(x);
    mu = mean(x);
    semv = std(x, 'omitnan') / max(1,sqrt(n));
    if n <= 1
        lo = NaN; hi = NaN; return;
    end
    bs = zeros(nboot,1);
    for b = 1:nboot
        idx = randi(n, n, 1);
        bs(b) = mean(x(idx));
    end
    lo = prctile(bs, 2.5);
    hi = prctile(bs, 97.5);
end
function plot_trace_with_sem(data, panel_name, color)
    % data: trials x time matrix
    % panel_name: string (e.g., 'LeftTurn')
    % color: line color (e.g., [0.2 0.6 1])

    m = nanmean(data, 1);                            % Mean trace
    sem = nanstd(data, [], 1) ./ sqrt(sum(~isnan(data), 1));  % SEM
    t = 1:size(data, 2);                             % Time axis

    fill([t fliplr(t)], [m+sem fliplr(m-sem)], color, ...
        'FaceAlpha', 0.3, 'EdgeColor', 'none');      % Shaded error
    hold on;
    plot(t, m, 'Color', color, 'LineWidth', 2);      % Mean line
    xlabel('Time (frames)');
    ylabel('\Delta');
    title(panel_name, 'Interpreter', 'none');
end
function plotWithSEM(t, data, color)
    mu = mean(data, 1, 'omitnan');
    sem = std(data, [], 1, 'omitnan') ./ sqrt(size(data,1));
    fill([t fliplr(t)], [mu+sem fliplr(mu-sem)], color + 0.5*(1-color), ...
        'EdgeColor', 'none', 'FaceAlpha', 0.3); hold on
    plot(t, mu, 'Color', color, 'LineWidth', .7)
    xline(0, '--k')
end



% % %% =========================
% % %  g–j style analysis across datasets
% % %  =========================
% % % ---------- user params ----------
% % WIN_S      = [2.5 2.5];   % seconds around trigger (±2.5 s)
% % SPLIT_T_S  = 1.5;         % evaluate dev/accel at +1.5 s
% % DEV_TH     = pi/12;       % deviation threshold (15°)
% % ACC_TH     = 0.8;         % accel threshold (rad/s^2)
% % PROM_TH    = 0.2;         % min peak prominence
% % REFRAC_S   = 0.30;        % refractory (s)
% % TJ_DIST_CM = 10;          % “enter T” when distance-to-reward < this (tune)
% % Fs_default = 30;          % fallback Hz
% % for m = 1:length(imaging_st)
% %     fprintf('\n==== Dataset %d/%d ====\n', m, length(imaging_st));
% %     % --- grab dataset-specific things ---
% %     imaging       = imaging_st{1,m};
% %     empty_trials  = find(cellfun(@isempty,{imaging.good_trial}));
% %     good_trials   = setdiff(1:length(imaging), empty_trials);
% %     imaging_array = [imaging(good_trials).movement_in_imaging_time];
% %     imaging_trial_info = [imaging(good_trials).virmen_trial_info];
% %     som_cells     = all_celltypes{1,m}.som_cells(:)';           % << per-dataset SOM
% %     all_cells     = 1:size(imaging(good_trials(1)).dff,1);
% %     non_sst_cells = setdiff(all_cells, som_cells);               % adjust if you want PV-only
% %     if isfield(imaging(good_trials(1)),'framerate')
% %         Fs = imaging(good_trials(1)).framerate;
% %     else
% %         Fs = Fs_default;
% %     end
% %     % If you don't already have these computed earlier in your loop, do it here:
% %     log_distance = log_transform_reward_distance(imaging_array);
% %     heading_deviation = compute_heading_deviation2( ...
% %         imaging_array, imaging_trial_info, vel_ball{m,1}, log_distance, num_bins); % trials x bins
% %     % --- containers to stack event-triggered segments for this dataset ---
% %     stack = struct('g',[],'h_low',[],'h_high',[],'i_low',[],'i_high',[],'j_low',[],'j_high',[]);
% %     count = struct('g',0,'h_low',0,'h_high',0,'i_low',0,'i_high',0,'j_low',0,'j_high',0);
% %     % --- per-trial accumulation ---
% %     for p = 1:length(good_trials)
% %         t_idx  = p;
% %         frames = [imaging_array(t_idx).maze_frames, imaging_array(t_idx).reward_frames];
% %         T = numel(frames);
% %         % per-frame heading deviation (upsample your per-bin deviations)
% %         hd = imresize(heading_deviation(t_idx,:), [1, numel(imaging_array(t_idx).maze_frames)], 'nearest');
% %         hd = [hd, nan(1, numel(imaging_array(t_idx).reward_frames))];
% %         hd = hd(1:T);
% %         % kinematics from headings
% %         K  = kinematics_from_heading_local(imaging_array(t_idx).view_angle, Fs);
% %         tv = K.turn_vel(frames);
% %         ta = K.turn_acc(frames);
% %         % distance-to-reward (for defining “enter T”); resize if needed
% %         if ~isempty(vel_ball{m,1}{p,2})
% %             dist = vel_ball{m,1}{p,2}(:)';
% %             if numel(dist) ~= T, dist = imresize(dist, [1,T], 'nearest'); end
% %         else
% %             dist = linspace(100,0,T); % fallback
% %         end
% %         % Non-Sst & SOM mean ΔF/F
% %         dff = imaging(good_trials(p)).dff(:, frames);   % cells x time
% %         som_mean    = mean(dff(som_cells,:),1,'omitnan');
% %         nonsst_mean = mean(dff(non_sst_cells,:),1,'omitnan');
% %         % traces to collect around triggers
% %         traces = struct('nonsst',nonsst_mean,'som',som_mean, ...
% %                         'heading_dev',hd,'turn_vel',tv,'turn_acc',ta);
% %         % triggers
% %         tj = find(dist < TJ_DIST_CM, 1, 'first');  % enter T
% %         [~, accel_peaks] = findpeaks(abs(ta), 'MinPeakProminence',0.5, ...
% %                                            'MinPeakDistance', max(1, round(0.3*Fs)));
% %         [corr_on, corr_drive] = detect_corrections_local(hd, ta, Fs, DEV_TH, ACC_TH, PROM_TH, REFRAC_S); %#ok<ASGLU>
% %         % g) trigger on entering T
% %         if ~isempty(tj)
% %             ETA = collect_eta_local(tj, WIN_S, Fs, traces);
% %             if ~isempty(ETA.keep)
% %                 block = [ETA.nonsst; ETA.som; ETA.heading_dev; ETA.turn_vel; ETA.turn_acc];
% %                 stack.g = cat(1, stack.g, block); count.g = count.g + 1;
% %             end
% %         end
% %         % h) trigger on T; split by deviation at +1.5 s
% %         if ~isempty(tj)
% %             ETA = collect_eta_local(tj, WIN_S, Fs, traces);
% %             if ~isempty(ETA.keep)
% %                 t15 = dsearchn(ETA.t', SPLIT_T_S);
% %                 med_abs_dev = median(abs(ETA.heading_dev_per_event(:,t15)), 'omitnan');
% %                 block = [ETA.nonsst; ETA.som; ETA.heading_dev; ETA.turn_vel; ETA.turn_acc];
% %                 if abs(ETA.heading_dev(t15)) < med_abs_dev
% %                     stack.h_low  = cat(1, stack.h_low,  block); count.h_low  = count.h_low+1;
% %                 else
% %                     stack.h_high = cat(1, stack.h_high, block); count.h_high = count.h_high+1;
% %                 end
% %             end
% %         end
% %         % i) trigger on T; split by accel at +1.5 s
% %         if ~isempty(tj)
% %             ETA = collect_eta_local(tj, WIN_S, Fs, traces);
% %             if ~isempty(ETA.keep)
% %                 t15 = dsearchn(ETA.t', SPLIT_T_S);
% %                 med_abs_acc = median(abs(ETA.turn_acc_per_event(:,t15)), 'omitnan');
% %                 block = [ETA.nonsst; ETA.som; ETA.heading_dev; ETA.turn_vel; ETA.turn_acc];
% %                 if abs(ETA.turn_acc(t15)) < med_abs_acc
% %                     stack.i_low  = cat(1, stack.i_low,  block); count.i_low  = count.i_low+1;
% %                 else
% %                     stack.i_high = cat(1, stack.i_high, block); count.i_high = count.i_high+1;
% %                 end
% %             end
% %         end
% %         % j) trigger on accel peaks; split by deviation at +1.5 s
% %         if ~isempty(accel_peaks)
% %             ETA = collect_eta_local(accel_peaks, WIN_S, Fs, traces);
% %             if ~isempty(ETA.keep)
% %                 t15 = dsearchn(ETA.t', SPLIT_T_S);
% %                 med_abs_dev = median(abs(ETA.heading_dev_per_event(:,t15)), 'omitnan');
% %                 block = [ETA.nonsst; ETA.som; ETA.heading_dev; ETA.turn_vel; ETA.turn_acc];
% %                 if abs(ETA.heading_dev(t15)) < med_abs_dev
% %                     stack.j_low  = cat(1, stack.j_low,  block); count.j_low  = count.j_low+1;
% %                 else
% %                     stack.j_high = cat(1, stack.j_high, block); count.j_high = count.j_high+1;
% %                 end
% %             end
% %         end
% %     end % trials
% %     % --- average stacks & plot for this dataset ---
% %     taxis = (-round(WIN_S(1)*Fs):round(WIN_S(2)*Fs))/Fs;
% %     G  = avg_stack_local(stack.g,  taxis);
% %     H0 = avg_stack_local(stack.h_low,  taxis);
% %     H1 = avg_stack_local(stack.h_high, taxis);
% %     I0 = avg_stack_local(stack.i_low,  taxis);
% %     I1 = avg_stack_local(stack.i_high, taxis);
% %     J0 = avg_stack_local(stack.j_low,  taxis);
% %     J1 = avg_stack_local(stack.j_high, taxis);
% %     figure(900+m); clf
% %     DATA = {G,H0,H1,I0,I1,J0,J1};
% %     titlestr = {'g: enter T','h: low dev','h: high dev','i: low accel','i: high accel','j: low dev','j: high dev'};
% %     rows = {'Non-Sst','SOM','Heading dev (rad)','Turn vel (rad/s)','Turn accel (rad/s^2)'};
% %     for c = 1:numel(DATA)
% %         if isempty(DATA{c}), continue; end
% %         D = DATA{c};
% %         for r = 1:5
% %             subplot(5, numel(DATA), (r-1)*numel(DATA)+c); hold on
% %             switch r
% %                 case 1, plot(D.t, D.nonsst,'Color',[.6 .6 .6],'LineWidth',1.5);
% %                 case 2, plot(D.t, D.som,   'Color',[0.10 0.35 0.80],'LineWidth',1.5);
% %                 case 3, plot(D.t, D.dev,   'k','LineWidth',1.2); ylim([-pi pi]);
% %                 case 4, plot(D.t, D.vel,   'k','LineWidth',1.2);
% %                 case 5, plot(D.t, D.acc,   'k','LineWidth',1.2);
% %             end
% %             xline(0,'k:'); yline(0,'k:'); xlim([D.t(1) D.t(end)]);
% %             if r==1, title(sprintf('%s (n=%d)', titlestr{c}, size(evalin('caller','stack'),2))); end %#ok<EVLC>
% %             if c==1, ylabel(rows{r}); end
% %         end
% %     end
% %     set(gcf,'Color','w'); drawnow
% %     % quick count printout
% %     fprintf('[m=%d] events: g=%d | h(low,high)=(%d,%d) | i(low,high)=(%d,%d) | j(low,high)=(%d,%d)\n', ...
% %         m, count.g, count.h_low, count.h_high, count.i_low, count.i_high, count.j_low, count.j_high);
% %     % optional saves
% %     if exist('savepath','var') && ~isempty(savepath)
% %         if ~exist(savepath,'dir'), mkdir(savepath); end
% %         saveas(900+m, fullfile(savepath, sprintf('gj_panels_mouse%d.png', m)));
% %         saveas(900+m, fullfile(savepath, sprintf('gj_panels_mouse%d.svg', m)));
% %     end
% % end % datasets
% % %% ===== helper locals (keep in same file; do NOT change your existing funcs) =====
% % function a = wrapToPi_local(a), a = mod(a+pi, 2*pi) - pi; end
% % function K = kinematics_from_heading_local(theta, Fs)
% %     dv = [0, wrapToPi_local(diff(theta))];
% %     turn_vel = dv .* Fs;
% %     da = [0, diff(turn_vel)];
% %     K.turn_vel = turn_vel;
% %     K.turn_acc = da .* Fs;
% % end
% % function [onsets, drive] = detect_corrections_local(hd, ta, Fs, DEV_TH, ACC_TH, PROM_TH, REFRAC_S)
% %     sgn = sign(hd); drive = max(0, -sgn .* ta);
% %     mask = abs(hd) > DEV_TH; x = drive; x(~mask) = 0;
% %     minDist = max(1, round(REFRAC_S * Fs));
% %     [~, onsets] = findpeaks(x, 'MinPeakHeight',ACC_TH, 'MinPeakProminence',PROM_TH, 'MinPeakDistance',minDist);
% % end
% % function ETA = collect_eta_local(trig_idx, win_s, Fs, traces)
% %     pre = round(win_s(1)*Fs); post = round(win_s(2)*Fs);
% %     T = numel(traces.heading_dev); w = -pre:post;
% %     keep = trig_idx(trig_idx+min(w) > 0 & trig_idx+max(w) <= T);
% %     ETA.t = w / Fs; ETA.keep = keep; if isempty(keep), return; end
% %     fns = fieldnames(traces);
% %     for k = 1:numel(fns)
% %         v = traces.(fns{k}); M = nan(numel(keep), numel(w));
% %         for i = 1:numel(keep); M(i,:) = v(keep(i)+w); end
% %         ETA.(fns{k}) = mean(M,1,'omitnan');
% %         ETA.([fns{k} '_per_event']) = M;
% %     end
% % end
% % function OUT = avg_stack_local(stack_block, t)
% %     OUT = []; if isempty(stack_block), return; end
% %     K = 5; n = size(stack_block,1)/K;
% %     M = reshape(stack_block, [K, n, size(stack_block,2)]);
% %     OUT.t=t; OUT.nonsst=squeeze(mean(M(1,:,:),2,'omitnan'));
% %     OUT.som=squeeze(mean(M(2,:,:),2,'omitnan'));
% %     OUT.dev=squeeze(mean(M(3,:,:),2,'omitnan'));
% %     OUT.vel=squeeze(mean(M(4,:,:),2,'omitnan'));
% %     OUT.acc=squeeze(mean(M(5,:,:),2,'omitnan'));
% % end


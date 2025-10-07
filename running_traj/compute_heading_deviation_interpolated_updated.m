function [heading_deviation, trials, course_correction_struc] = compute_heading_deviation_interpolated_updated( ...
    imaging_array, imaging_trial_info, position, log_distance, num_bins, dx, varargin)
if nargin < 6, dx = 0.75; end
if nargin < 5, num_bins = 15; end
num_trials = numel(imaging_array);
conditions  = arrayfun(@(s) s.condition, imaging_trial_info(:))';
heading_deviation = cell(num_trials,1);
course_correction_struc   = repmat(struct('theta_obs',[], 'theta_ref',[], 'theta_dev',[], ...
                      'turn_vel',[], 'turn_acc',[], ...
                      'turn_vel_ref',[], 'turn_acc_ref',[], ...
                      'turn_vel_corr',[], 'turn_acc_corr',[]), num_trials,1);
trials = [];
for cond = 1:2
    cond_trials = find(conditions == cond);
    % ---- select shortest 25% by usable samples ----
    usable_lengths = zeros(size(cond_trials));
    for i = 1:numel(cond_trials)
        t = cond_trials(i);
        usable_lengths(i) = sum(isfinite(log_distance{t}));
    end
    [~, sort_idx] = sort(usable_lengths);
    num_sel = max(1, ceil(0.25 * numel(cond_trials)));
    selected_trials = cond_trials(sort_idx(1:num_sel));
    % ---- build coarse trajectory in log-distance ----
    all_logd = []; all_pos = []; all_ang = [];
    for t = selected_trials(:)'
        mf = imaging_array(t).maze_frames;
        if isempty(mf), continue; end
        logd = log_distance{t}(:);
        pos  = position{t}(:);
        ang  = imaging_array(t).view_angle(mf); ang = ang(:);
        if isempty(logd) || isempty(pos) || isempty(ang), continue, end
        valid = isfinite(logd) & isfinite(pos) & isfinite(ang);
        all_logd = [all_logd; logd(valid)];
        all_pos  = [all_pos;  pos(valid)];
        all_ang  = [all_ang;  ang(valid)];
    end
    if isempty(all_logd), continue, end
    edges = linspace(min(all_logd), max(all_logd), num_bins+1);
    bin_pos = nan(num_bins,1);
    bin_heading = nan(num_bins,1);
    for b = 1:num_bins
        inb = all_logd >= edges(b) & all_logd < edges(b+1);
        if any(inb)
            bin_pos(b)    = median(all_pos(inb), 'omitnan');
            bin_heading(b)= circ_mean(all_ang(inb));
        end
    end
    ok = isfinite(bin_pos) & isfinite(bin_heading);
    bin_pos = bin_pos(ok); bin_heading = bin_heading(ok);
    if numel(bin_pos) < 2
        warning('Too few bins for interpolation in condition %d.', cond);
        for t = cond_trials(:)'; heading_deviation{t} = nan; end
        continue
    end
    % optional end-of-arm facing correction (your block, unmodified)
    if nargin>6
        bh_unw = unwrap(bin_heading);
        d_heading = diff(bh_unw); %#ok<NASGU>
        turn_thresh = pi * 0.75;
        last_good_idx = numel(bh_unw);
        for i = numel(bh_unw)-1:-1:1
            if abs(bh_unw(i+1) - bh_unw(i)) > turn_thresh
                last_good_idx = i; break
            end
        end
        if last_good_idx < numel(bh_unw)
            bh_unw(last_good_idx+1:end) = bh_unw(last_good_idx);
        end
        bin_heading = wrapToPi_local(bh_unw);
    end
    % sort by position and interpolate reference heading along fine grid
    [bin_pos, ord] = sort(bin_pos); bin_heading = bin_heading(ord);
    fine_grid   = (min(bin_pos):dx:max(bin_pos))';
    head_unw    = unwrap(bin_heading);
    interp_head = interp1(bin_pos, head_unw, fine_grid, 'linear', 'extrap');
    theta_ref_grid = wrapToPi_local(interp_head);     % reference heading as fn(pos)
    % ===== per trial: map to nearest ref heading and compute kinematics =====
    for t = cond_trials(:)'
        mf = imaging_array(t).maze_frames;
        if isempty(mf), continue, end
        pos = position{t}(:);
%         th  = imaging_array(t).view_angle(mf); th = th(:);
        view_angle_filled = fillmissing(imaging_array(t).view_angle(mf), 'linear');
        th  = view_angle_filled; th = th(:);
        if isempty(pos) || isempty(th)
            heading_deviation{t} = nan(size(th));
            continue
        end
        % nearest reference heading for each frame (vectorized)
        idx = dsearchn(fine_grid, pos);                 % nearest position on fine grid
        theta_ref = theta_ref_grid(idx);
        % deviation
        theta_dev = wrapToPi_local(th - theta_ref);
        heading_deviation{t} = theta_dev;
        % ------- kinematics (observed, reference, and correction) -------
        % You can optionally smooth th/theta_ref before diffs:
%         SMOOTH_N = 3;
%         th = movmean(th, SMOOTH_N); theta_ref = movmean(theta_ref, SMOOTH_N);
        Fs = 30; %frame rate
        % observed
        tv  = [0; wrapToPi_local(diff(th))] * Fs;
        ta  = [0; diff(tv)] * Fs;
        % reference (what the smooth path would predict)
        tv_ref = [0; wrapToPi_local(diff(theta_ref))] * Fs;
        ta_ref = [0; diff(tv_ref)] * Fs;
        % correction components (residuals)
        % either derivative of deviation OR observed - reference (identical)
        tv_corr = [0; wrapToPi_local(diff(theta_dev))] * Fs;  % == tv - tv_ref
        ta_corr = [0; diff(tv_corr)] * Fs;                    % == ta - ta_ref
        % store useful outputs
        course_correction_struc(t).theta_obs = th;
        course_correction_struc(t).theta_ref = theta_ref;
        course_correction_struc(t).theta_dev = theta_dev;
        course_correction_struc(t).turn_vel  = tv;
        course_correction_struc(t).turn_acc  = ta;
        course_correction_struc(t).turn_vel_ref  = tv_ref;
        course_correction_struc(t).turn_acc_ref  = ta_ref;
        course_correction_struc(t).turn_vel_corr = tv_corr;
        course_correction_struc(t).turn_acc_corr = ta_corr;
        trials = [trials, t]; 
    end
end
end
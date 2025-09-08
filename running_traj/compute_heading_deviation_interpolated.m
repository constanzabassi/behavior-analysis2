function [heading_deviation, trials] = compute_heading_deviation_interpolated(imaging_array, imaging_trial_info, position, log_distance, num_bins, dx,varargin)
% Compute per-timepoint heading deviation using interpolated smooth trajectory
% Output:
%   heading_deviation{t} : per-sample deviation (radians, wrapped to [-pi, pi])
if nargin < 6, dx = 0.75; end
if nargin < 5, num_bins = 15; end
num_trials = numel(imaging_array);
conditions = arrayfun(@(s) s.condition, imaging_trial_info(:))';
% Initialize output
heading_deviation = cell(num_trials,1);
% Loop over conditions (black-left / white-right)
trials = [];
for cond = 1:2
    cond_trials = find(conditions == cond);
    % --- Select shortest 25% based on usable samples ---
    usable_lengths = zeros(size(cond_trials));
    for i = 1:numel(cond_trials)
        t = cond_trials(i);
        usable_lengths(i) = sum(isfinite(log_distance{t}));
    end
    [~, sort_idx] = sort(usable_lengths);
    num_sel = max(1, ceil(0.25 * numel(cond_trials)));
    if nargin > 6
        num_sel = max(1, ceil(varargin{1,1} * numel(cond_trials)));
    end
    selected_trials = cond_trials(sort_idx(1:num_sel));
    % --- Build coarse trajectory (15 bins in log-distance) ---
    all_logd = []; all_pos = []; all_ang = [];
    % Collect data across selected trials
    for t = selected_trials(:)'
        mf = imaging_array(t).maze_frames;
        if isempty(mf), continue; end
        logd = log_distance{t};
        pos = position{t};
        ang = imaging_array(t).view_angle(imaging_array(t).maze_frames);
        if isempty(logd) || isempty(pos) || isempty(ang), continue; end
        % Align all to maze_frames
        logd = logd(:);
        pos = pos(:);
        ang = ang(:);
        if length(logd) ~= length(pos) || length(ang) ~= length(pos)
            warning('Length mismatch in trial %d', t); continue
        end
        valid = isfinite(logd) & isfinite(pos) & isfinite(ang);
        all_logd = [all_logd; logd(valid)];
        all_pos  = [all_pos;  pos(valid)];
        all_ang  = [all_ang;  ang(valid)];
%         all_logd = [all_logd; logd];
%         all_pos  = [all_pos; pos];
%         all_ang  = [all_ang; ang];
    end

    % Define global bin edges in log-distance
    edges = linspace(min(all_logd), max(all_logd), num_bins+1);

    % Bin: store median position and circ_mean heading
    bin_pos = nan(num_bins,1);
    bin_heading = nan(num_bins,1);
    for b = 1:num_bins
        in_bin = all_logd >= edges(b) & all_logd < edges(b+1);
        if ~any(in_bin), continue; end
        bin_pos(b) = median(all_pos(in_bin), 'omitnan');
        bin_heading(b) = circ_mean(all_ang(in_bin));
    end
    % Remove NaNs and sort by position
    valid = isfinite(bin_pos) & isfinite(bin_heading);
    bin_pos = bin_pos(valid);
    bin_heading = bin_heading(valid);
    if numel(bin_pos) < 2
        warning('Too few bins in condition %d for interpolation.', cond);
        for t = cond_trials(:)'
            heading_deviation{t} = nan(size(imaging_array(t).view_angle));
        end
%         continue;
    end
    
%     if nargin>6 %perform optional correction (make sure if mouse is facing away from reward at the end it is assinged to the last bin
        % ---- Optional correction: prevent backwards-facing trajectory at end ----
        % We'll assume "facing toward reward zone" = facing roughly forward from prior heading
        % This is subjective and might depend on maze geometry — but we’ll use continuity:
        % Step 1: unwrap heading to avoid jumps
        bin_heading_unw = unwrap(bin_heading);
        % Step 2: compute difference between successive heading values
        d_heading = diff(bin_heading_unw);
        % Step 3: look for sign reversals or large reversals at the end
        % (e.g., big jumps in heading direction that could be overshoots)
        % We'll say: if heading "turns around" by more than ~135° (2.4 rad), that's a reversal
        turn_thresh = pi * 0.75;
        % Start from end, look backward for stable forward-facing heading
        last_good_idx = numel(bin_heading_unw);
        for i = numel(bin_heading_unw)-1: -1: 1
            if abs(bin_heading_unw(i+1) - bin_heading_unw(i)) > turn_thresh
                last_good_idx = i;
                break
            end
        end
        % Apply correction: overwrite all later headings with the last stable one
        if last_good_idx < numel(bin_heading_unw)
            bin_heading_unw(last_good_idx+1:end) = bin_heading_unw(last_good_idx);
        end
        % Replace original bin_heading with corrected (wrapped) version
        bin_heading = wrapToPi_local(bin_heading_unw);
%     end

    % Sort
    [bin_pos, sort_idx] = sort(bin_pos);
    bin_heading = bin_heading(sort_idx);
    % Interpolate heading over fine-grained distance grid (unwrap first)
    fine_grid = min(bin_pos):dx:max(bin_pos);
    head_unwrapped = unwrap(bin_heading);
    interp_head = interp1(bin_pos, head_unwrapped, fine_grid, 'linear', 'extrap');
    interp_head = wrapToPi_local(interp_head);
    % For each trial, map timepoints to the nearest point in the fine grid
    for t = cond_trials(:)'
        mf = imaging_array(t).maze_frames;
        if isempty(mf), continue; end
        pos = position{t};
        ang = imaging_array(t).view_angle(mf);
        if isempty(pos) || isempty(ang)
            heading_deviation{t} = nan(size(ang));
            continue;
        end
        pos = pos(:);
        ang = ang(:);
        % Assign each timepoint the nearest interpolated heading
        dev = nan(size(ang));
        for i = 1:numel(pos)
            if isnan(pos(i)) || isnan(ang(i)), continue; end
            [~, idx] = min(abs(fine_grid - pos(i)));
            ref_heading = interp_head(idx);
            dev(i) = wrapToPi_local(ang(i) - ref_heading);
        end
        heading_deviation{t} = dev;
        trials = [trials,t];
    end
end
end
function heading_deviation = compute_heading_deviation_timeseries(imaging_array, imaging_trial_info, position, log_distance, num_bins)
% ADAPTED FROM CODE 1 to implement the paper's procedure.
% Output:
%   heading_deviation{t} : per-sample radians in [-pi, pi] for trial t
%
% Inputs:
%   imaging_array(t).view_angle   : heading (rad), length Nt
%   imaging_trial_info(t).condition : 1 or 2
%   position{t,2}                 : distance-to-reward (cm), length Nt
%   log_distance{t}               : log(distance-to-reward), length Nt
%   num_bins                      : e.g., 15 (equal-width bins in log(distance))
%   dx_cm                         : interpolation spatial step, default 0.75 cm
%
% Requires: circ_mean (Circular Statistics toolbox) or a compatible function.
if nargin < 5 || isempty(num_bins), num_bins = 15; end
if nargin < 6 || isempty(dx_cm), dx_cm = 0.75; end
num_trials = numel(imaging_array);
conditions = arrayfun(@(s) s.condition, imaging_trial_info(:))';
% Helper for wrapping angles to [-pi, pi]
wrap = @(x) atan2(sin(x), cos(x));
% Precompute "has data"
has_data = false(num_trials,1);
for t = 1:num_trials
    has_data(t) = ~isempty(imaging_array(t).view_angle) && ...
                  numel(imaging_array(t).view_angle) == numel(position{t,2}) && ...
                  numel(position{t,2}) == numel(log_distance{t});
end
% Output: per-trial cell array (per-timepoint deviations)
heading_deviation = cell(num_trials,1);
for condition = 1:2
    cond_trials = find(conditions == condition & has_data);
    if isempty(cond_trials), continue; end
    % ---- Select shortest 25% by usable samples (finite log_distance) ----
    usable_counts = zeros(numel(cond_trials),1);
    for k = 1:numel(cond_trials)
        t = cond_trials(k);
        ld = log_distance{t};
        usable_counts(k) = sum(isfinite(ld));
    end
    [~, order] = sort(usable_counts, 'ascend');
    sorted_trials = cond_trials(order);
    num_sel = max(1, ceil(0.25 * numel(sorted_trials)));
    sel_trials = sorted_trials(1:num_sel);
    % ---- Build equal-width log(distance) bins over selected trials ----
    % Safely concatenate variable-length log_distance
    C = log_distance(sel_trials);
    C = C(~cellfun(@isempty, C));
    C = cellfun(@(x) x(:), C, 'UniformOutput', false);
    if isempty(C)
        % No data; fill condition's trials with NaNs and continue
        for t = cond_trials(:)'
            heading_deviation{t} = nan(size(imaging_array(t).view_angle));
        end
        continue;
    end
    all_logd = vertcat(C{:});
    all_logd = all_logd(isfinite(all_logd));
    if isempty(all_logd)
        for t = cond_trials(:)'
            heading_deviation{t} = nan(size(imaging_array(t).view_angle));
        end
        continue;
    end
    edges = linspace(min(all_logd), max(all_logd), num_bins+1);
    % ---- Aggregate across selected trials: median position & circular mean heading per bin ----
    bin_pos = nan(1, num_bins);    % median position (cm)
    bin_head = nan(1, num_bins);   % circular mean heading (rad)
    for b = 1:num_bins
        pos_stack = []; ang_stack = [];
        lo = edges(b); hi = edges(b+1);
        for t = sel_trials(:)'
            logd_t = log_distance{t}(:);
            pos_t  = position{t,2}(:);
            ang_t  = imaging_array(t).view_angle(:);
            ok = isfinite(logd_t) & isfinite(pos_t) & isfinite(ang_t) & ...
                 logd_t >= lo & logd_t < hi;
            if any(ok)
                pos_stack = [pos_stack; pos_t(ok)]; %#ok<AGROW>
                ang_stack = [ang_stack; ang_t(ok)]; %#ok<AGROW>
            end
        end
        if ~isempty(pos_stack)
            bin_pos(b) = median(pos_stack, 'omitnan');
        end
        if ~isempty(ang_stack)
            % circular mean across pooled samples from selected trials in this bin
            bin_head(b) = circ_mean(ang_stack, [], 1);
        end
    end
    % Drop empty bins and sort by position (cm)
    okb = isfinite(bin_pos) & isfinite(bin_head);
    bin_pos = bin_pos(okb);
    bin_head = bin_head(okb);
    if numel(bin_pos) < 1
        % No reference; all NaNs
        for t = cond_trials(:)'
            heading_deviation{t} = nan(size(imaging_array(t).view_angle));
        end
        continue;
    end
    % Sort by position and deduplicate positions circularly if needed
    [bin_pos, sidx] = sort(bin_pos(:));
    bin_head = bin_head(sidx);
    [u_pos, ~, ic] = unique(bin_pos);
    if numel(u_pos) < numel(bin_pos)
        head_u = nan(size(u_pos));
        for k = 1:numel(u_pos)
            head_u(k) = circ_mean(bin_head(ic == k), [], 1);
        end
        bin_pos = u_pos;
        bin_head = head_u;
    end
    % ---- Interpolate smooth trajectory at dx_cm resolution ----
    if numel(bin_pos) == 1
        p_grid = bin_pos;
        head_grid = bin_head;
    else
        pmin = min(bin_pos); pmax = max(bin_pos);
        if pmax == pmin
            p_grid = pmin;
            head_grid = bin_head(1);
        else
            p_grid = (pmin:dx_cm:pmax).';
            % unwrap -> linear interpolate -> wrap
            head_unw = unwrap(bin_head);
            head_interp = interp1(bin_pos, head_unw, p_grid, 'linear', 'extrap');
            head_grid = wrap(head_interp);
        end
    end
    % Build a nearest-neighbor interpolant on position -> unwrapped angle (for stability)
    if numel(bin_pos) >= 2
        head_unw_for_nn = unwrap(bin_head);
        Fnn = griddedInterpolant(bin_pos, head_unw_for_nn, 'nearest', 'nearest');
    else
        Fnn = []; % degenerate case
    end
    % ---- Assign per-timepoint smooth heading & compute deviation ----
    for t = cond_trials(:)'
        pos_t = position{t,2}(:);
        ang_t = imaging_array(t).view_angle(:);
        dev_t = nan(size(ang_t));
        ok = isfinite(pos_t) & isfinite(ang_t);
        if ~any(ok)
            heading_deviation{t} = dev_t;
            continue;
        end
        if numel(p_grid) >= 2
            % nearest neighbor via Fnn on original coarse positions (robust, no need to scan full grid)
            smooth_head_unw = Fnn(pos_t(ok));
            smooth_head = wrap(smooth_head_unw);
        else
            % single reference point: assign constant heading
            smooth_head = repmat(head_grid(1), sum(ok), 1);
        end
        dev_t(ok) = wrap(ang_t(ok) - smooth_head);
        heading_deviation{t} = dev_t;
    end
end
end

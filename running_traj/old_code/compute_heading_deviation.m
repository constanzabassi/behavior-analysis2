function heading_deviation = compute_heading_deviation(imaging_array, imaging_trial_info, position, log_distance, num_bins)
% Compute heading deviation per trial/bin as:
%   view_angle(trial,bin) - circular_mean_heading(bin)   (wrapped to [-pi,pi])
%
% Inputs:
%   imaging_array(t).maze_frames : indices/timepoints for maze segment (unused here but OK)
%   imaging_array(t).view_angle  : vector of headings (radians) per sample
%   imaging_trial_info(t).condition : 1 or 2
%   position{t,2}         : distance-to-reward (or position scalar) per sample (same length as view_angle)
%   log_distance{t}       : log(distance) per sample (same length as view_angle)
%   num_bins              : number of bins along log(distance)
%
% Output:
%   heading_deviation(trial, bin) : radians, wrapped to [-pi, pi]

% --- gather conditions ---
num_trials = numel(imaging_array);
conditions = arrayfun(@(s) s.condition, imaging_trial_info(:))';

% Preallocate binned arrays with NaNs (trial x bin)
binned_position = nan(num_trials, num_bins);   % median (or mean) position per bin
binned_angle    = nan(num_trials, num_bins);   % mean heading per bin

% --- bin per trial using its own log-distance axis ---
for t = 1:num_trials
    t
    if isempty(log_distance{t}) || isempty(imaging_array(t).view_angle)
        continue
    end
    L = numel(log_distance{t});
    if L < num_bins,  % too short to bin cleanly
        continue
    end

    % Bin edges spanning the trial’s log-distance samples (index-based binning)
    % We use equal-length index bins over the *vector*; if you truly want
    % equal-width in log(distance) *value*, build edges with linspace(min(logd), max(logd), num_bins+1)
    % and use discretize(logd, edges). Here we keep your original approach:
    edges = round(linspace(1, L+1, num_bins+1));

    va = imaging_array(t).view_angle(:)';    % radians
    pos = position{t,2}(:)';                 % e.g., distance to reward (or any scalar pos)
    % (Optional) if position is distance-to-reward, using mean is fine; median is also OK.

    for i = 1:num_bins
        idx = edges(i):(edges(i+1)-1);
        if isempty(idx), continue; end
        % robust to NaNs
        binned_position(t,i) = mean(pos(idx), 'omitnan');
        binned_angle(t,i)    = circ_mean(va(idx), 2);   % circular mean across samples in bin
    end
end

% --- compute heading deviation per condition ---
heading_deviation = nan(num_trials, num_bins);  % trial x bin

for condition = 1:2
    condition_trials = find(conditions == condition);

    if isempty(condition_trials)
        continue
    end

    % sort by "length" of maze (use count of valid binned points, as a proxy)
    valid_counts = sum(~isnan(binned_angle(condition_trials,:)), 2);
    [~, order]   = sort(valid_counts, 'ascend');  % fewer bins ~= shorter
    sorted_trials = condition_trials(order);

    % select shortest 25%
    num_selected_trials = max(1, ceil(0.25 * numel(sorted_trials)));
    selected_trials = sorted_trials(1:num_selected_trials);

    % circular mean heading per bin across selected trials
    cm_heading = circ_mean(binned_angle(selected_trials, :), 1);     % 1 = across trials
    % (Optional) median position per bin across selected trials
    % median_position = median(binned_position(selected_trials, :), 1, 'omitnan'); %#ok<NASGU>

    % heading deviation for all trials in this condition: wrap(view - cm)
    dev = binned_angle(condition_trials, :) - cm_heading(ones(numel(condition_trials),1), :);

    % wrap to [-pi, pi)
    dev = wrapToPi_local(dev);

    % write back
    heading_deviation(condition_trials, :) = dev;
end

end

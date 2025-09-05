function heading_deviation = compute_heading_deviation2(imaging_array, imaging_trial_info, position, log_distance,num_bins)
    % Initialize heading deviation array
    heading_deviation = [];
    % Extract condition information
    num_trials = numel(imaging_array);
    conditions = [];
    for trial = 1:num_trials
        conditions(trial) = imaging_trial_info(trial).condition;
    end
    % Loop through each condition
    for condition = 1:2 % Assuming you have only two conditions
        % Find trials for the current condition
        condition_trials = find(conditions == condition);
        % Sort trials based on the length of maze_frames
        [~, sorted_indices] = sort(cellfun(@length, {imaging_array(condition_trials).maze_frames}));
        sorted_trials = condition_trials(sorted_indices);
        % Select the shortest 25% of trials for the current condition
        num_selected_trials = ceil(0.25 * numel(sorted_trials));
        selected_trials = sorted_trials(1:num_selected_trials);

        % Compute median position and circular mean for selected trials
%         median_position = zeros(num_bins, 2);
%         circular_mean_heading = zeros(num_bins, 1);
        binned_position =[];binned_angle=[];
       for tt = 1:length(condition_trials)
           t = condition_trials(tt);
            bin_edges= floor(linspace(1,length(log_distance{t}), num_bins+1));
            
            for i = 1:length(bin_edges)-1
                i
                to_add = floor(diff(bin_edges));
                binned_position(t,i) = mean([position{t,2}(bin_edges(i):bin_edges(i)+to_add)]);
                binned_angle(t,i) = nanmean(imaging_array(t).view_angle(bin_edges(i):bin_edges(i)+to_add));
            end
            %binned_pos{t} = binned_position;
       end
        
       %convert indices
       [tf, indx] = ismember(selected_trials,condition_trials);
       median_position = nanmedian(binned_position(indx,:),1);
       circular_mean_heading = circ_mean(binned_angle(indx,:));
        

        % Compute heading deviation for all trials in this condition
        for tt = 1:length(condition_trials)
            t = condition_trials(tt);
            % Extract view angle and log distance for the current trial
            view_angle = binned_angle(t,:);
            log_dist = binned_position(t,:);
            % Compute heading deviation
            % Assume you have aligned the time points for view_angle and log_dist
%             aligned_headings = smoothdata(view_angle, 'movmean', 5); % Smoothing the view angle data
            heading_deviation(t,:)= view_angle - circular_mean_heading;
        end
    end
end
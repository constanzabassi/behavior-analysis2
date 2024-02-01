function [all_conditions, condition_array] = divide_trials (imaging)
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!

condition_array = [];
count = 0;
for t = 1:length(good_trials)
    count = count+1;
    condition_array(count,1) = good_trials(t); 
    condition_array(count,2) = imaging(good_trials(t)).virmen_trial_info.correct;%correct
    condition_array(count,3) = imaging(good_trials(t)).virmen_trial_info.left_turn;

    %if isfield(imaging(t).virmen_trial_info,'is_stim_trial')
    %    condition_array(count,4) = imaging(good_trials(t)).virmen_trial_info.is_stim_trial;
    %end
    
end

%find trials that match each condtion
num_conditions = size(condition_array, 2) -1; % Number of conditions

% Generate all possible combinations of conditions
all_combinations = dec2bin(0:(2^num_conditions - 1)) - '0';

% Initialize a cell array to store matching trials for each combination
all_conditions = cell(size(all_combinations, 1), 2);

% Find trials for each combination of conditions
for i = 1:size(all_combinations, 1)
    condition_values = all_combinations(i, :);

        
    % data: Your matrix/array where rows represent trials and columns represent conditions
    % condition_values: A vector representing the condition values that can occur to check for each column
    
    % Get labels for the current combination of conditions
    labels = get_condition_labels(condition_values);

    % find condition that matches each trial
    matching_trials = (condition_array(:, 2:end) == condition_values);

    %add them up- if it's equal to the condition the sum should equal the
    %number of conditions 
    sum_matching_trials = sum(matching_trials,2);

    all_conditions{i,1} = find(sum_matching_trials == num_conditions);
    all_conditions{i,2} = {condition_values};
    all_conditions{i, 3} = labels;
end


for m = 1:length(imaging_st)
    imaging = imaging_st{1,m};
    empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
    good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
    imaging_array = [imaging(good_trials).movement_in_imaging_time]; %convert to array for easier indexing
    
    reward_onset = cellfun(@(x) find(x == 1),{imaging_array.is_reward},'UniformOutput',false);
    turn_onset = [imaging_array.turn_frame];
    reward_trial = cellfun(@(x) ~isempty(x),reward_onset,'UniformOutput',false);
    reward_trial = find([reward_trial{1,:}] == 1); %of good trials which ones have reward
    difference_start = [reward_onset{1,reward_trial}] - turn_onset(1,reward_trial);
    
    min_diff(m) = min(difference_start);
end
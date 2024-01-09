function [align_info] = find_align_info (imaging,turn_frames)
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
imaging_array = [imaging(good_trials).movement_in_imaging_time]; %convert to array for easier indexing
aligned_imaging =[]; %this is needed so there is an output if there are zero trials in the condition (happens w reward)

%find the trial with the smallest amount of frames
maze_length= cellfun(@length,{imaging_array.maze_frames});
temp_stim = cellfun(@(x) find(x==1),{imaging_array.stimulus},'UniformOutput',false);
stim_onset = cellfun(@min,temp_stim,'UniformOutput',false); %find first one in stimulus to determine stimulus onset
shortest_maze_length = min(maze_length - [stim_onset{1,:}]);
min_length_stim = min([stim_onset{1,:}])-1; %min number of frames in front of stimulus onset during maze
if min_length_stim == 0 %sometimes weird trial not found bc it is the first of the file
    min_length_stim = min(setdiff([stim_onset{1,:}],min([stim_onset{1,:}])))-1;
    keyboard %probably some weird trial where sound is playing during iti
end


max_length_reward = min(cellfun(@length,{imaging_array.reward_frames})); %24/25 or 30 frames between maze and ITI
reward_onset = cellfun(@(x) find(x == 1),{imaging_array.is_reward},'UniformOutput',false); %reward onset based on all frames in trial
reward_trial = cellfun(@(x) ~isempty(x),reward_onset,'UniformOutput',false);
reward_trial = find([reward_trial{1,:}] == 1); %of good trials which ones have reward
min_length_reward = min([[reward_onset{1,:}] - cellfun(@min,{imaging_array(reward_trial).reward_frames})]); %min number of frames in front of reward before the end of maze

%for turns using 30 frames before and after
frames_around = turn_frames;
align_info.turn_onset = frames_around+1;
% align_info.stimulus_onsets = [stim_onset{1,:}];
align_info.maze_length = maze_length;
align_info.min_length = shortest_maze_length;
align_info.stimulus_onset = min_length_stim+1;

% align_info.reward_onsets = [reward_onset{1,:}];
align_info.max_length_reward = max_length_reward;
align_info.reward_onset = min_length_reward+1;
% align_info.reward_trials = reward_trial;

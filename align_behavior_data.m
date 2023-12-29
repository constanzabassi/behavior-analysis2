function [aligned_imaging,imaging_array,align_info] = align_behavior_data (imaging,data_type,alignment_type)
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
imaging_array = [imaging(good_trials).movement_in_imaging_time]; %convert to array for easier indexing


%find the trial with the smallest amount of frames
maze_length= cellfun(@length,{imaging_array.maze_frames});
temp_reward = cellfun(@(x) find(x==1),{imaging_array.stimulus},'UniformOutput',false);
stim_onset = cellfun(@min,temp_reward,'UniformOutput',false); %find first one in stimulus to determine stimulus onset
shortest_maze_length = min(maze_length - [stim_onset{1,:}]);
min_length_stim = min([stim_onset{1,:}])-1; %min number of frames in front of stimulus onset during maze
if min_length_stim == 0
    keyboard %probably some weird trial where sound is playing during iti
end


max_length_reward = min(cellfun(@length,{imaging_array.reward_frames})); %24/25 or 30 frames between maze and ITI
reward_onset = cellfun(@(x) find(x == 1),{imaging_array.is_reward},'UniformOutput',false); %reward onset based on all frames in trial
reward_trial = cellfun(@(x) ~isempty(x),reward_onset,'UniformOutput',false);
reward_trial = find([reward_trial{1,:}] == 1); %of good trials which ones have reward
min_length_reward = min([[reward_onset{1,:}] - cellfun(@min,{imaging_array(reward_trial).reward_frames})]); %min number of frames in front of reward before the end of maze

%for turns using 30 frames before and after
frames_around = 30;
align_info.turn_onset = frames_around+1;
align_info.stim_onsets = [stim_onset{1,:}];
align_info.maze_length = maze_length;
align_info.min_length = shortest_maze_length;
align_info.stim_onset = min_length_stim+1;

align_info.reward_onsets = [reward_onset{1,:}];
align_info.max_length_reward = max_length_reward;
align_info.reward_onset = min_length_reward+1;

if strcmp(alignment_type,'stimulus' )
% 1) align data based on stimulus onset (include preceding maze- couple frames)
    for vr_trials = 1:length(good_trials)
        t = good_trials(vr_trials);
        frames_to_include = stim_onset{1,vr_trials}-min_length_stim:stim_onset{1,vr_trials}+shortest_maze_length-min_length_stim; %currently stim onset is frame 1
        if strcmp(data_type,'dff')
            aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).dff(:,frames_to_include);
        elseif strcmp(data_type,'z_dff')
            aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).z_dff(:,frames_to_include);
        else
            aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).deconv(:,frames_to_include);
        end
       
    end
elseif strcmp(alignment_type,'turn')
    
% 2) align data based on maze offset/turn (1 sec pre and post)
    for vr_trials = 1:length(good_trials) 
            t = vr_trials;
            frames_to_include = imaging_array(t).turn_frame-frames_around :imaging_array(t).turn_frame+frames_around ; %turn onset is frame 31
            if strcmp(data_type,'dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).dff(:,frames_to_include);
            elseif strcmp(data_type,'z_dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).z_dff(:,frames_to_include);
            else
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).deconv(:,frames_to_include);
            end
           
    end

% 3) align data based on reward (include only reward period?)
elseif strcmp(alignment_type ,'reward')
        for vr_trials = 1:length(reward_trial) %incorrect ones are empty for reward
            t = reward_trial(vr_trials);
            frames_to_include = reward_onset{1,t}-min_length_reward:reward_onset{1,t}+max_length_reward-min_length_reward; %reward onset at min_length_reward+1
            if strcmp(data_type,'dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(reward_trial(vr_trials))).dff(:,frames_to_include);
            elseif strcmp(data_type,'z_dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(reward_trial(vr_trials))).z_dff(:,frames_to_include);
            else
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(reward_trial(vr_trials))).deconv(:,frames_to_include);
            end
           
    end
end


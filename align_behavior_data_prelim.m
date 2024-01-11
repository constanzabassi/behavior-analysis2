function [aligned_imaging,imaging_array,align_info] = align_behavior_data_prelim (imaging,align_info,alignment,varargin)
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
imaging_array = [imaging(good_trials).movement_in_imaging_time]; %convert to array for easier indexing
aligned_imaging =[]; %this is needed so there is an output if there are zero trials in the condition (happens w reward)

% get stimulus onsets 
temp_stim = cellfun(@(x) find(x==1),{imaging_array.stimulus},'UniformOutput',false);
stim_onset = cellfun(@min,temp_stim,'UniformOutput',false); %find first one in stimulus to determine stimulus onset
%save into align_info
align_info.stimulus_onsets = [stim_onset{1,:}];

% reward onsets and trials with reward
reward_onset = cellfun(@(x) find(x == 1),{imaging_array.is_reward},'UniformOutput',false); %reward onset based on all frames in trial
reward_trial = cellfun(@(x) ~isempty(x),reward_onset,'UniformOutput',false);
reward_trial = find([reward_trial{1,:}] == 1); %of good trials which ones have reward
%save into align_info
align_info.reward_onsets = [reward_onset{1,:}];
align_info.reward_trials = reward_trial;

%save good trials
align_info.good_trials = good_trials;
if nargin > 3
    cell_ids = varargin{1,1};
else
    cell_ids = 1:size(imaging(good_trials(1)).dff,1);
end

if strcmp(alignment.type,'stimulus' )
% 1) align data based on stimulus onset (include preceding maze- couple frames)
    for vr_trials = 1:length(good_trials)
        t = good_trials(vr_trials);
        frames_to_include = align_info.stimulus_onsets(vr_trials)-align_info.stimulus_onset+1:align_info.stimulus_onsets(vr_trials)+align_info.min_length-align_info.stimulus_onset+1; %currently stim onset is frame 1
        if strcmp(alignment.data_type,'dff')
            aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).dff(cell_ids,frames_to_include);
        elseif strcmp(alignment.data_type,'z_dff')
            aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).z_dff(cell_ids,frames_to_include);
        else
            aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).deconv(cell_ids,frames_to_include);
        end
       
    end
elseif strcmp(alignment.type,'turn')
    
% 2) align data based on maze offset/turn (1 sec pre and post)
    for vr_trials = 1:length(good_trials) 
            t = vr_trials;
            frames_to_include = imaging_array(t).turn_frame-align_info.turn_onset+1 :imaging_array(t).turn_frame+align_info.turn_onset-1 ; %turn onset is frame 31
            if strcmp(alignment.data_type,'dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).dff(cell_ids,frames_to_include);
            elseif strcmp(alignment.data_type,'z_dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).z_dff(cell_ids,frames_to_include);
            else
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).deconv(cell_ids,frames_to_include);
            end
           
    end

% 3) align data based on reward (include only reward period?)
elseif strcmp(alignment.type ,'reward')
        for vr_trials = 1:length(align_info.reward_trials) %incorrect ones are empty for reward
            t = align_info.reward_trials(vr_trials);
            frames_to_include = align_info.reward_onsets(vr_trials)-align_info.reward_onset+1:align_info.reward_onsets(vr_trials)+align_info.max_length_reward-align_info.reward_onset-1; %reward onset at min_length_reward+1
            if strcmp(alignment.data_type,'dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(t)).dff(cell_ids,frames_to_include);
            elseif strcmp(alignment.data_type,'z_dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(t)).z_dff(cell_ids,frames_to_include);
            else
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(t)).deconv(cell_ids,frames_to_include);
            end
           
    end
end



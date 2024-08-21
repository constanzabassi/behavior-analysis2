function [aligned_imaging_array] = align_imaging_array (imaging_array,align_info,alignment_frames,left_padding,right_padding,alignment,field_to_align)
%save good trials
possible_fields = fieldnames(imaging_array);
matching_field = find(strcmp(field_to_align,possible_fields));
if strcmp(alignment.type,'stimulus' )
% 1) align data based on stimulus onset (include preceding maze- couple frames)
    frames = find_alignment_frames (alignment_frames,[1:3],left_padding,right_padding);
    for vr_trials = 1:length(imaging_array)
        t = vr_trials;
        frames_to_include = frames(t,:);%align_info.stimulus_onsets(vr_trials)-align_info.stimulus_onset+1:align_info.stimulus_onsets(vr_trials)+align_info.min_length-align_info.stimulus_onset+1; %currently stim onset is frame 1
        aligned_imaging_array(vr_trials,:) = imaging_array(vr_trials).(possible_fields{matching_field})(frames_to_include);  
    end
elseif strcmp(alignment.type,'turn')
    
% 2) align data based on maze offset/turn (1 sec pre and post)
frames = find_alignment_frames (alignment_frames,[4],left_padding,right_padding);
    for vr_trials = 1:length(imaging_array)
        t = vr_trials;
        frames_to_include = frames(t,:);%align_info.stimulus_onsets(vr_trials)-align_info.stimulus_onset+1:align_info.stimulus_onsets(vr_trials)+align_info.min_length-align_info.stimulus_onset+1; %currently stim onset is frame 1
        aligned_imaging_array(vr_trials,:) = imaging_array(vr_trials).(possible_fields{matching_field})(frames_to_include);  
    end

% 3) align data based on reward (include only reward period?)
elseif strcmp(alignment.type ,'reward')
    frames = find_alignment_frames (alignment_frames,[5],left_padding,right_padding);
        for vr_trials = 1:length(imaging_array)
            t = vr_trials;
            frames_to_include = frames(t,:);%align_info.stimulus_onsets(vr_trials)-align_info.stimulus_onset+1:align_info.stimulus_onsets(vr_trials)+align_info.min_length-align_info.stimulus_onset+1; %currently stim onset is frame 1
            aligned_imaging_array(vr_trials,:) = imaging_array(vr_trials).(possible_fields{matching_field})(frames_to_include);  
        end
elseif strcmp(alignment.type ,'ITI')
    frames = find_alignment_frames (alignment_frames,[6],left_padding,right_padding);
        for vr_trials = 1:length(imaging_array)
            t = vr_trials;
            frames_to_include = frames(t,:);%align_info.stimulus_onsets(vr_trials)-align_info.stimulus_onset+1:align_info.stimulus_onsets(vr_trials)+align_info.min_length-align_info.stimulus_onset+1; %currently stim onset is frame 1
            aligned_imaging_array(vr_trials,:) = imaging_array(vr_trials).(possible_fields{matching_field})(frames_to_include);  
        end
elseif strcmp(alignment.type ,'all')
    frames = find_alignment_frames (alignment_frames,[1:6],left_padding,right_padding);
        for vr_trials = 1:length(imaging_array)
            t = vr_trials;
            frames_to_include = frames(t,:);%align_info.stimulus_onsets(vr_trials)-align_info.stimulus_onset+1:align_info.stimulus_onsets(vr_trials)+align_info.min_length-align_info.stimulus_onset+1; %currently stim onset is frame 1
            aligned_imaging_array(vr_trials,:) = imaging_array(vr_trials).(possible_fields{matching_field})(frames_to_include);  
        end
    
end

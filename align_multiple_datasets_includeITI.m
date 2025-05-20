function [aligned_data_all,all_conditions_all,num_trials,alignment, frames_used_per_mouse, aligned_data_structure,condition_array_trials_all]= align_multiple_datasets_includeITI(imaging_st,alignment)
for m = 1:length(imaging_st)
    m
    imaging = imaging_st{1,m};
    [align_info,alignment_frames,left_padding,right_padding] = find_align_info (imaging,30,3);
    alignment.data_type = 'dff';
    [aligned_imaging,imaging_array,align_info,frames_used] = align_behavior_data_includeITI (imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
    [all_conditions, condition_array_trials, trial_info] = divide_trials_includeITI (imaging); %divide trials into all possible conditions
    alignment.left_padding = left_padding;
    alignment.right_padding = right_padding;

    %save dff
    aligned_data_structure.dff{m} = aligned_imaging;
    %save deconv
    alignment.data_type = 'deconv';
    [aligned_imaging,imaging_array,align_info,frames_used] = align_behavior_data_includeITI (imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
    aligned_data_structure.deconv{m} = aligned_imaging;

    aligned_data_all{m} = aligned_imaging;
    all_conditions_all{m} = all_conditions;
    %
    concatenated_conditions = [all_conditions_all{m}]
    temp = cellfun(@(x) length(x),concatenated_conditions);
    num_trials(:,m) = temp(:,1);

    if strcmp(alignment.type,'all')
        event_id = 1:6;
    elseif strcmp(alignment.type,'pre')
        event_id = 1:5;
    elseif strcmp(alignment.type,'stimulus' )
        event_id = 1:3;
    elseif strcmp(alignment.type,'turn' )
        event_id = 4;
    elseif strcmp(alignment.type,'reward' )
        event_id = 5;
    end
    alignment.event_onsets = determine_onsets(left_padding,right_padding,event_id);
    frames_used_per_mouse{m} = frames_used;

    condition_array_trials_all{m} = trial_info;

    
end
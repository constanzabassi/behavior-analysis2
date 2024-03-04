function [aligned_data_all,all_conditions_all,num_trials]= align_multiple_datasets(imaging_st,alignment)
for m = 1:length(imaging_st)
    m
    imaging = imaging_st{1,m};
    [align_info,alignment_frames,left_padding,right_padding] = find_align_info (imaging,30);
    [aligned_imaging,imaging_array,align_info] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
    [all_conditions, condition_array_trials] = divide_trials (imaging); %divide trials into all possible conditions

    aligned_data_all{m} = aligned_imaging;
    all_conditions_all{m} = all_conditions;
    %
    concatenated_conditions = [all_conditions_all{m}]
    temp = cellfun(@(x) length(x),concatenated_conditions);
    num_trials(:,m) = temp(:,1);
end
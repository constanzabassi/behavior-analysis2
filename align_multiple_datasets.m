function [aligned_data_all,all_conditions_all]= align_multiple_datasets(imaging_st,alignment)
for m = 1:length(imaging_st)
    imaging = imaging_st{1,m};
    [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
    [aligned_imaging,imaging_array,align_info] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
    [all_conditions, condition_array_trials] = divide_trials (imaging); %divide trials into all possible conditions

    aligned_data_all{m} = aligned_imaging;
    all_conditions_all{m} = all_conditions;
end

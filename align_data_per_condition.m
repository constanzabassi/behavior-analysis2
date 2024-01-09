function aligned_conditions = align_data_per_condition(data_matrix,all_conditions,data_type,alignment_type,varagin)
for c = 1:length(all_conditions)
    condition_data_matrix = data_matrix(all_conditions{c,1});
    if nargin > 4
        align_info = find_align_info(condition_data_matrix,30);
        [aligned_stimulus,imaging_array] = align_behavior_data(condition_data_matrix,align_info,data_type,alignment_type,varagin);
    else
        align_info = find_align_info(condition_data_matrix,30);
        [aligned_stimulus,imaging_array] = align_behavior_data(condition_data_matrix,align_info,data_type,alignment_type);
    end
    aligned_conditions{1,c} = aligned_stimulus;
    aligned_conditions{2,c} = align_info;
end
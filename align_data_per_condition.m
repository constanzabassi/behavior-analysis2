function aligned_conditions = align_data_per_condition(data_matrix,all_conditions,data_type,alignment_type)
for c = 1:length(all_conditions)
    condition_data_matrix = data_matrix(all_conditions{c,1});
    [aligned_stimulus,imaging_array,align_info] = align_behavior_data(condition_data_matrix,data_type,alignment_type);
    aligned_conditions{c} = aligned_stimulus;
end
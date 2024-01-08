function aligned_conditions = align_data_per_condition(data_matrix,all_conditions,data_type,alignment_type,varagin)
for c = 1:length(all_conditions)
    condition_data_matrix = data_matrix(all_conditions{c,1});
    if nargin > 4
        [aligned_stimulus,imaging_array,align_info] = align_behavior_data(condition_data_matrix,data_type,alignment_type,varagin);
    else
        [aligned_stimulus,imaging_array,align_info] = align_behavior_data(condition_data_matrix,data_type,alignment_type)
    end
    aligned_conditions{1,c} = aligned_stimulus;
    aligned_conditions{2,c} = align_info;
end
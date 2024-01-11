function aligned_conditions = align_data_per_condition(data_matrix,all_conditions,alignment,align_info_input,varagin)
for c = 1:length(all_conditions)
    condition_data_matrix = data_matrix(all_conditions{c,1});
    if ~isempty(align_info_input) %given align info using all other trials
        if nargin > 4
            align_info = align_info_input;
            [aligned_stimulus,imaging_array,align_info] = align_behavior_data_prelim(condition_data_matrix,align_info,alignment,varagin);
        else
            align_info = align_info_input;
            [aligned_stimulus,imaging_array,align_info] = align_behavior_data_prelim(condition_data_matrix,align_info,alignment);
        end
    else %calculate align info for each condition separately
        if nargin > 4
            align_info = find_align_info(condition_data_matrix,30);
            [aligned_stimulus,imaging_array,align_info] = align_behavior_data_prelim(condition_data_matrix,align_info,alignment,varagin);
        else
            align_info = find_align_info(condition_data_matrix,30);
            [aligned_stimulus,imaging_array,align_info] = align_behavior_data_prelim(condition_data_matrix,align_info,alignment);
        end
    end
    aligned_conditions{1,c} = aligned_stimulus;
    aligned_conditions{2,c} = align_info;
end
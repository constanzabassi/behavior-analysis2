function all_datasets = organize_aligned_datasets(aligned_data_all,params)

for m = 1:length(aligned_data_all)
    norm_aligned_data = normalize_aligned_data(aligned_data_all{1,m},params.normalization,params.smooth);
    all_datasets{m} = norm_aligned_data;
end
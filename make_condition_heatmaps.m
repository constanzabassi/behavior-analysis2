function make_condition_heatmaps (data,min_max,sorting_type,all_conditions)
figure(2);clf;
tiledlayout(ceil(sqrt(length(all_conditions))),ceil(sqrt(length(all_conditions))));
for c = 1:length(all_conditions)
    data_to_plot = 
    make_heatmap(data_to_plot,min_max,sorting_type);
end
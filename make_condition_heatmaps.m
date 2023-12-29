function make_condition_heatmaps (data,min_max,sorting_type,all_conditions)
figure(4);clf;

tiledlayout(ceil(sqrt(length(all_conditions))),ceil(sqrt(length(all_conditions))));
for c = 1:length(all_conditions)
    nexttile
    hold on
    data_to_plot = squeeze(mean(data{1,c},1));%finds mean across trials
    title(all_conditions{c,3})
    make_heatmap(data_to_plot,min_max,sorting_type); 
    hold off
end

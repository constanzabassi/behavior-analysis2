function make_condition_heatmaps (data,min_max,sorting_type,all_conditions)
figure(4);clf;

% find empty arrays and don't count them as condition
empty_array = cellfun(@isempty,data);
empty_conditions = find(empty_array(1,:));

if ~isempty(empty_conditions)
    total_conditions = length(all_conditions) - length(empty_conditions);
    tiledlayout(ceil(sqrt(total_conditions)),ceil(sqrt(total_conditions)));
else
    tiledlayout(ceil(sqrt(length(all_conditions))),ceil(sqrt(length(all_conditions))));
end
for c = 1:length(all_conditions)
    if ~ismember(c,empty_conditions)
        nexttile
        hold on
        data_to_plot = squeeze(mean(data{1,c},1));%finds mean across trials
        title(all_conditions{c,3})
        make_heatmap(data_to_plot,min_max,sorting_type); 
        hold off
    end
end

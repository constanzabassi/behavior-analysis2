function make_condition_heatmaps (data,plot_info,all_conditions,alignment,sorting_id)

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

        %find alignment event
        align_info = data{2,c};
        align_fieldnames = fieldnames(align_info);
        alignment_event_index = find(strcmp(fieldnames(align_info),strcat(alignment.type,'_onset')));
        alignment_event_onset = align_info.(align_fieldnames{alignment_event_index});

        %make heatmap of specific condition with alignment event onset
        %based on alignment type
        if isempty(sorting_id)
            make_heatmap(data_to_plot,plot_info,alignment_event_onset,alignment_event_onset); 
        else
            make_heatmap_sorted(data_to_plot,plot_info,sorting_id,alignment_event_onset);
        end
        hold off
    end
end

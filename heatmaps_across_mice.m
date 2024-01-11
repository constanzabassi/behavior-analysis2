function mouse_data_conditions = heatmaps_across_mice (imaging_st,min_max,sorting_type,conditions,alignment,celltype,sorting_id)

tiledlayout(ceil(sqrt(length(conditions))),ceil(sqrt(length(conditions))));
for c = conditions
        %find infor for each mouse and combine it
        for m = 1:length(celltype)
            imaging = imaging_st{1,m};
            [all_conditions, condition_array_trials] = divide_trials (imaging); %divide trials into all possible conditions   
            celltypes_permouse = celltype{m};
            [align_info,alignment_frames,left_padding,right_padding] = find_align_info (imaging,30);
            [aligned_imaging] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment.data_type,alignment.type,celltypes_permouse);
            mouse_data{m} = aligned_imaging(all_conditions{c,1},:,:); %use specified trials in the condition array
        end
        mouse_data_conditions{m,c} = mouse_data{m};
        mean_mouse_data = cellfun(@(x) squeeze(mean(x,1)),mouse_data,'UniformOutput',false);

        nexttile
        hold on
        data_to_plot = cat(1,mean_mouse_data{1,:});%concatenated mouse data
        title(all_conditions{c,3})

        %find alignment event
        event_onsets = determine_onsets(left_padding,right_padding,alignment.number);
        alignment_event_onset = event_onsets(1);

        %make heatmap of specific condition with alignment event onset
        %based on alignment type
        if isempty(sorting_id)
            make_heatmap(data_to_plot,min_max,sorting_type,alignment_event_onset,event_onsets); 
        else
            make_heatmap_sorted(data_to_plot,min_max,sorting_id,alignment_event_onset);
        end
        hold off
    end
end


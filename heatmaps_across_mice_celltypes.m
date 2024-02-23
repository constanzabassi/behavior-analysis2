function mouse_data_conditions = heatmaps_across_mice_celltypes (imaging_st,plot_info,alignment)
% Number of things to plot
num_plots = length(alignment.conditions)*3;  % Change this value based on your requirement

% Calculate the number of rows and columns for the tiled layout
rows = ceil(sqrt(num_plots));
columns = ceil(num_plots / rows);

% Create a tiled layout
tiledlayout(rows, columns);

%Initialize variables
% celltype = alignment.cells;
for ce = 1:3
    %Initialize variables
    celltype = {alignment.cells{ce,:}};

    for c = alignment.conditions
            %find infor for each mouse and combine it
            for m = 1:length(celltype)
                imaging = imaging_st{1,m};
                [all_conditions, condition_array_trials] = divide_trials (imaging); %divide trials into all possible conditions   
                celltypes_permouse = celltype{m};
                [align_info,alignment_frames,left_padding,right_padding] = find_align_info (imaging,30);
                [aligned_imaging] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment,celltypes_permouse);
                mouse_data{m} = aligned_imaging(all_conditions{c,1},:,:); %use specified trials in the condition array
                mouse_data_conditions{m,c} = mouse_data{m};
            end
            
            mean_mouse_data = cellfun(@(x) squeeze(mean(x,1)),mouse_data,'UniformOutput',false);
    
            nexttile
            hold on
            data_to_plot = cat(1,mean_mouse_data{1,:});%concatenated mouse data
            title(alignment.title{ce})
    
            %make heatmap of specific condition with alignment event onset
            %based on alignment type
            if c == alignment.conditions(2) % sort based on first condition
                sorting_id = sorting_value{ce};
            else
                sorting_id = [];
            end
    
            if isempty(sorting_id)
                make_heatmap(data_to_plot,plot_info,1); %align by first spatial bin
                sorting_value{ce} = sort_values (data_to_plot,1, 1);
            else
                make_heatmap_sorted(data_to_plot,plot_info,sorting_id);
            end
            set(gca, 'box', 'off' )%'xtick', []
            set(gca,'fontsize', 14)
            hold off
    end
end
end


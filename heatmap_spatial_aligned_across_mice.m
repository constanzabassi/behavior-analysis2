function mouse_data_conditions = heatmap_spatial_aligned_across_mice(imaging_st,alignment,plot_info,celltypes_to_plot)
% Create a tiled layout
tiledlayout(1,size(alignment.cells,1), "TileSpacing","compact");

for ce = celltypes_to_plot
    %Initialize variables
    celltype = {alignment.cells{ce,:}};
    for c = alignment.conditions
    
        hold on
        for m = 1:length(imaging_st)
            ex_imaging = imaging_st{1,m};
            alignment.cell_ids = celltype{m};%1:num_cells(m);
        
            [all_conditions, condition_array_trials] = divide_trials (ex_imaging); %divide trials into all possible conditions  
            [spatially_aligned_data,mean_data,trial_indices] = spatial_alignment(ex_imaging,alignment);
            mouse_data{m} = spatially_aligned_data(all_conditions{c,1},:,:); %use specified trials in the condition array
            mouse_data_conditions{m,c} = mouse_data{m};
        end
            
            mean_mouse_data = cellfun(@(x) squeeze(nanmean(x,1)),mouse_data,'UniformOutput',false);
    
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
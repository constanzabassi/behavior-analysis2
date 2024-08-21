function mouse_data_conditions = heatmaps_avg_combined_all_celltypes_extra_fields (imaging_st,plot_info,alignment,sorting_id,save_data_directory,bin_size,extra_fields)
% Create a tiled layout
tiledlayout(3, 1,"TileSpacing","tight");

for ce = 1:3
%Initialize variables
celltype = {alignment.cells{ce,:}};
mouse_data ={}; mouse_data_conditions ={};
if length(alignment.conditions) >= 1

        %find infor for each mouse and combine it
        for m = 1:length(celltype)
            imaging = imaging_st{1,m};
            [all_conditions, condition_array_trials] = divide_trials (imaging); %divide trials into all possible conditions   
            celltypes_permouse = celltype{m};
            [align_info,alignment_frames,left_padding,right_padding] = find_align_info (imaging,30);
            [aligned_imaging,imaging_array] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment,celltypes_permouse);
            [aligned_imaging_array] = align_imaging_array (imaging_array,align_info,alignment_frames,left_padding,right_padding,alignment,extra_fields);
            mouse_data{m} = aligned_imaging(cat(1,all_conditions{alignment.conditions,1}),:,:); %use specified trials in the condition array
            mouse_data_behavior{m} = aligned_imaging_array(cat(1,all_conditions{alignment.conditions,1}),:);
        end
        
        mean_mouse_data = cellfun(@(x) squeeze(mean(x,[1,2],'omitnan')),mouse_data,'UniformOutput',false);
        mean_mouse_data_behav = cellfun(@(x) squeeze(mean(x,1,'omitnan')),mouse_data_behavior,'UniformOutput',false);
        
        nexttile
        hold on
        
        data_to_plot = cat(2,mean_mouse_data{1,:});%concatenated mouse data
        data_to_plot_behav = cat(1,mean_mouse_data_behav{1,:});%concatenated mouse data

        scatter(mean(data_to_plot_behav(:,1:15),2,'omitnan'),mean(data_to_plot(1:15,:),'omitnan'),'markeredgecolor',plot_info.colors_celltype(ce,:),'color',plot_info.colors_celltype(ce,:),'LineWidth',1.2)

%         scatter3(1:length(mean(data_to_plot_behav)),mean(data_to_plot_behav),mean(data_to_plot'),'markeredgecolor',plot_info.colors_celltype(ce,:),'color',plot_info.colors_celltype(ce,:),'LineWidth',1.2)
%         xlabel('Frames')
%         ylabel(strcat('Behavioral feature ',extra_fields));
%         zlabel({alignment.title{ce};'Neural Activity'})
        
        xlabel(strcat('Behavioral feature ',extra_fields));
        ylabel({alignment.title{ce};'Neural Activity'})
        set(gca, 'box', 'off')
        set(gca,'fontsize', 12,'FontName','Arial')
%         set_current_fig;
        hold off
    %end
else
    %find infor for each mouse and combine it
        for m = 1:length(celltype)
            imaging = imaging_st{1,m};
            [all_conditions, condition_array_trials] = divide_trials (imaging); %divide trials into all possible conditions   
            celltypes_permouse = celltype{m};
            [align_info,alignment_frames,left_padding,right_padding] = find_align_info (imaging,30);
            [aligned_imaging] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment,celltypes_permouse);
            [aligned_imaging_array] = align_imaging_array (imaging_array,align_info,alignment_frames,left_padding,right_padding,alignment,extra_fields);
            mouse_data{m} = aligned_imaging(:,:,:); %use specified trials in the condition array
            mouse_data_behavior{m} = aligned_imaging_array;
        end
        mouse_data_conditions{m} = mouse_data{m};
        mean_mouse_data = cellfun(@(x) squeeze(mean(x,1)),mouse_data,'UniformOutput',false);

        nexttile
        hold on
        data_to_plot = cat(1,mean_mouse_data{1,:});%concatenated mouse data
        

        %find alignment event
        event_onsets = determine_onsets(left_padding,right_padding,alignment.number);
        alignment_event_onset = event_onsets(1);

        %make heatmap of specific condition with alignment event onset
        %based on alignment type
        if isempty(sorting_id)
            make_heatmap(data_to_plot,plot_info,alignment_event_onset,event_onsets); 
        else
            make_heatmap_sorted(data_to_plot,plot_info,sorting_id,alignment_event_onset);
        end
        set(gca, 'box', 'off', 'xtick', [])
        set(gca,'fontsize', 12,'FontName','Arial')
        ylabel({alignment.title{ce};'Neurons'})
        
end
end


    

%%

if ~isempty(save_data_directory)
    mkdir(save_data_directory)
    cd(save_data_directory)

    image_string = strcat('heatmaps_avgtrace_condition_',num2str(alignment.conditions,3),'_',extra_fields);
    saveas(90,[image_string '_datasets.svg']);
    saveas(90,[image_string '_datasets.fig']);
    saveas(90,[image_string '_datasets.png']);
end


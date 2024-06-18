function avg_plot_celltypes (imaging_st,plot_info,alignment,save_data_directory,bin_size)
%find the mean across datasets for each celltype!
for m = 1:size(imaging_st,2)
    m
    for ce = 1:3
        celltype = {alignment.cells{ce,:}};
        imaging = imaging_st{1,m};
        [all_conditions, condition_array_trials] = divide_trials (imaging); %divide trials into all possible conditions   
        celltypes_permouse = celltype{m};
        [align_info,alignment_frames,left_padding,right_padding] = find_align_info (imaging,30);
        [aligned_imaging] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment,celltypes_permouse);

        %create grand avg plot!
        binss = 1:bin_size:size(aligned_imaging,3)-bin_size;
        
        for b = 1:length(binss)        
            binned_data(ce,b) = squeeze(mean(aligned_imaging(:,:,binss(b):binss(b)+bin_size-1),[1,2,3])); %mean across trials and celltypes
          
        end
        
    end
    binned_data_all(m,:,:) = binned_data;
end

%find event onsets if using bins
event_onsets = determine_onsets(left_padding,right_padding,[1:6]);
new_onsets = find(histcounts(event_onsets,binss));

%make avg plot!

nexttile
hold on
for ce = 1:3
    
%     plot(squeeze(mean(binned_data_all(:,ce,:),1)),'LineWidth',1.5,'color',plot_info.colors_celltype(ce,:));

    data = squeeze(binned_data_all(:,ce,:));
    SEM= std(data)/sqrt(size(data,1));
    a(ce) = shadedErrorBar(1:size(data,2),mean(data,1), SEM, 'lineProps',{'color', plot_info.colors_celltype(ce,:),'LineWidth',1.5});

    for i = 1:length(new_onsets)
        xline(new_onsets(i),'--k','LineWidth',1)
    end
    ylabel({'Mean dF/F'})
    xlim([1 length(binss)])
    set(gca, 'box', 'off', 'xtick', [])
%     set(gcf,'Position',[23 453 683 133])
    set(gca,'fontsize', 12,'FontName','Arial')
    
end
hold off


set(gca,'xtick',new_onsets,'xticklabel',plot_info.xlabel_events,'xticklabelrotation',45);

if ~isempty(save_data_directory)
    mkdir(save_data_directory)
    cd(save_data_directory)

    image_string = strcat('heatmaps_avgtrace_condition_',num2str(alignment.conditions,3));
    saveas(90,[image_string '_datasets.svg']);
    saveas(90,[image_string '_datasets.fig']);
    saveas(90,[image_string '_datasets.png']);
end


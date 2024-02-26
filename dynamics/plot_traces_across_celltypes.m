function plot_traces_across_celltypes(imaging_st,all_celltypes,alignment,dynamics_info,plot_info,info)
possible_celltypes = fieldnames(all_celltypes{1,1});
bin_size = dynamics_info.bin_size;
for m = 1:size(imaging_st,2)

    
    ex_imaging = imaging_st{1,m};
    [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
    [aligned_imaging,~,~] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
    
    if ~isempty(dynamics_info.conditions)
        [all_conditions,~] = divide_trials (ex_imaging);
        aligned_imaging =  aligned_imaging(all_conditions{dynamics_info.conditions,1},:,:);
    end

    binss = 1:bin_size:size(aligned_imaging,3)-bin_size;

    %find event onsets if using bins
    event_onsets = determine_onsets(left_padding,right_padding,[1:6]);
    new_onsets = find(histcounts(event_onsets,binss));

    %find the mean across datasets for each celltype!
    for ce = 1:3
        for b = 1:length(binss)        
            binned_data(ce,b) = squeeze(mean(aligned_imaging(:,all_celltypes{1,m}.(possible_celltypes{ce}),binss(b):binss(b)+bin_size-1),[1,2,3])); %mean across trials and celltypes
          
        end

    end
    binned_data_all(m,:,:) = binned_data;
end

%make avg plot!
figure(58);clf;

for ce = 1:3
    hold on;
    plot(squeeze(mean(binned_data_all(:,ce,:),1)),'LineWidth',1.5,'color',plot_info.colors_celltype(ce,:));

    for i = 1:length(new_onsets)
        xline(new_onsets(i),'--k','LineWidth',1.5)
    end
    ylabel({'Average activity'; 'across cell types'})
    xlim([1 length(binss)])
    set(gca, 'box', 'off', 'xtick', [])
    set(gcf,'Position',[23 453 683 133])
    hold off
end

if ~isempty(info)
    mkdir([info.savepath '\frc_dynamics'])
    cd([info.savepath '\frc_dynamics'])
%     max_cel_mode = max_cel_avg;
%     save('max_cel_mode','max_cel_mode');
    if ~isempty(dynamics_info.conditions)
        saveas(58,strcat('avg_traces_binsize',num2str(unique(diff(binss))),'_condition',num2str(dynamics_info.conditions),'.svg'));
        saveas(58,strcat('avg_traces_binsize',num2str(unique(diff(binss))),'_condition',num2str(dynamics_info.conditions),'.png'));
    else
        saveas(58,strcat('avg_traces_binsize',num2str(unique(diff(binss))),'.svg'));
        saveas(58,strcat('avg_traces_binsize',num2str(unique(diff(binss))),'.png'));
    end
end
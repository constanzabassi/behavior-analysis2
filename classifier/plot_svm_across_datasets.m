function plot_svm_across_datasets(svm_mat,plot_info,event_onsets)
overall_mean = [];
overall_shuff = [];


for ce = 1:4
    mean_across_data = cellfun(@(x) mean(x.accuracy,1),{svm_mat{:,ce}},'UniformOutput',false);
    mean_across_data = vertcat(mean_across_data{1,:});
    overall_mean(ce,:) = mean(mean_across_data,1);
    mean_data(ce,:,:) = mean_across_data;

    mean_across_data_shuff = cellfun(@(x) mean(x.shuff_accuracy,1),{svm_mat{:,ce}},'UniformOutput',false);
    mean_across_data_shuff = vertcat(mean_across_data_shuff{1,:});
    overall_shuff(ce,:) = mean(mean_across_data_shuff,1);
    mean_data2(ce,:,:) = mean_across_data_shuff;

end


figure(100);clf;
for ce = 1:4
    hold on; 
        %shadedErrorBar(1:size(time),mean(aross_subsamples gives
        %size(time))

    SEM= std(squeeze(mean_data(ce,:,:)))/sqrt(size(mean_data(ce,:,:),2)); %first number is observations (time)/ maybe datasets or subsamples
    shadedErrorBar(1:size(overall_mean,2),smooth(overall_mean(ce,:),3, 'boxcar'), smooth(SEM,3, 'boxcar'), 'lineProps',{'color', plot_info.colors_celltype(ce,:)});
    
    SEM= std(squeeze(mean_data2(ce,:,:)))/sqrt(size(mean_data2(ce,:,:),2));
    shadedErrorBar(1:size(overall_mean,2),smooth(overall_shuff(ce,:),3, 'boxcar'), smooth(SEM,3, 'boxcar'), 'lineProps',{'color', [0.2 0.2 0.2]*ce});

    for i = 1:length(event_onsets)
        xline(event_onsets(i),'--k','LineWidth',1.5)
        if i == 4
            xline(event_onsets(i),'--k',{'turn onset'},'LineWidth',1.5)
        end
    end
yline(.5,'--k');
end

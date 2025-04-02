function plot_svm_across_datasets(svm_mat,plot_info,event_onsets,mdl_param,save_str,save_path,minmax,bins_to_include)
overall_mean = [];
overall_shuff = [];


for ce = 1:size(svm_mat,2)
    mean_across_data = cellfun(@(x) mean(x.accuracy(:,1:bins_to_include),1),{svm_mat{:,ce}},'UniformOutput',false);
    mean_across_data = vertcat(mean_across_data{1,:});
    overall_mean(ce,:) = mean(mean_across_data,1);
    mean_data(ce,:,:) = mean_across_data;

    mean_across_data_shuff = cellfun(@(x) mean(x.shuff_accuracy(:,1:bins_to_include),1),{svm_mat{:,ce}},'UniformOutput',false);
    mean_across_data_shuff = vertcat(mean_across_data_shuff{1,:});
    overall_shuff(ce,:) = mean(mean_across_data_shuff,1);
    mean_data2(ce,:,:) = mean_across_data_shuff;

end


figure(100);clf;
legend_handles = []; % Initialize an array to collect handles for the legend
legend_labels = {}; % Initialize a cell array to collect labels for the legend

hold on; 
for ce = 1:size(svm_mat,2)
    
        %shadedErrorBar(1:size(time),mean(aross_subsamples gives
        %size(time))

    SEM= std(squeeze(mean_data(ce,:,:)))/sqrt(size(mean_data(ce,:,:),2)); %first number is observations (time)/ maybe datasets or subsamples
    h1 = shadedErrorBar(1:size(overall_mean,2),smooth(overall_mean(ce,:),3, 'boxcar'), smooth(SEM,3, 'boxcar'), 'lineProps',{'color', plot_info.colors_celltype(ce,:)});
    legend_handles(end+1) = h1.mainLine; % Collect the handle of the main line
    legend_labels{end+1} = plot_info.labels{ce}; % Collect the corresponding label


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
% Create the legend using the collected handles and labels
legend(legend_handles, legend_labels,'location','north','Box', 'off'); 

ylabel({'% Accuracy'})
xlim([1 size(overall_mean,2)])
[second_ticks,second_labels] = x_axis_sec_onset(mdl_param);
xticks([second_ticks]);
xticklabels(second_labels);
if ~isempty(minmax)
    ylim([minmax(1) minmax(2)])
end

set(gca, 'box', 'off')
set(gca,'fontsize', 14)

if ~isempty(save_path)
    mkdir(save_path )
    cd(save_path)
    saveas(100,strcat('svm_alldatasets_',num2str(size(svm_mat,1)),save_str,'.svg'));
    saveas(100,strcat('svm_alldatasets_',num2str(size(svm_mat,1)),save_str,'.png'));
end


function stats = errorbar_events2task(data,plot_info,savepath)

%% SOM
% Compute means and standard deviations
som_data = data.som;
means = mean(som_data);
std_devs = std(som_data);
% Plotting
figure(333);clf
hold on
a = errorbar(1:size(som_data,2), means, std_devs, 'o-', 'LineWidth', 1.5,'Color',plot_info.colors_celltype(2,:));

%% PV
% Compute means and standard deviations
pv_data = data.pv;
means = mean(pv_data);
std_devs = std(pv_data);

% Plotting
b= errorbar(1:size(pv_data,2), means, std_devs, 'o-', 'LineWidth', 1.5,'Color',plot_info.colors_celltype(3,:));
ylabel('Number of Events');
xlim([0 5])
xticks([1:4])
xticklabels({'Stimulus', 'Turn', 'Reward', 'ITI'});
legend([a,b],{'SOM','PV'})

set(gca,'fontsize', 14,'box', 'off','FontName','Arial');

%% COMPUTE STATS
 % Compute means and standard deviations
    % Perform repeated measures ANOVA
    [p_som, tbl_som, stats_som] = anova1(som_data,[],'off');
    [p_pv, tbl_pv, stats_pv] = anova1(pv_data,[],'off');

%% Compute Wilcoxon signed rank test
    p_values = zeros(1, size(som_data, 2));
    for i = 1:size(som_data, 2)
        [p_values(i), ~] = signrank(som_data(:,i), pv_data(:,i));
    end
%     %% Mark significant p-values
%     significant_levels = [0.001, 0.01, 0.05];
%     for i = 1:length(p_values)
%         if p_values(i) <= significant_levels(1)
%             text(i, max([means_som(i), means_pv(i)]), '***', 'HorizontalAlignment', 'center');
%         elseif p_values(i) <= significant_levels(2)
%             text(i, max([means_som(i), means_pv(i)]), '**', 'HorizontalAlignment', 'center');
%         elseif p_values(i) <= significant_levels(3)
%             text(i, max([means_som(i), means_pv(i)]), '*', 'HorizontalAlignment', 'center');
%         end
%     end
%% Output stats
    stats.p_val_wilcoxon = p_values;
    stats.p_som = p_som;
    stats.tbl_som = tbl_som;
    stats.stats_som = stats_som;
    stats.p_pv = p_pv;
    stats.tbl_pv = tbl_pv;
    stats.stats_pv = stats_pv;

    %%
    if ~isempty(savepath)
        mkdir(savepath)
        cd(savepath)
        saveas(333,strcat('errorbar_SOM_PV_events_datasets',num2str(size(som_data,1)),'.svg'));
        saveas(333,strcat('errorbar_SOM_PV_events_datasets',num2str(size(som_data,1)),'.png'));
        save('errorbar_stats','stats')
    end





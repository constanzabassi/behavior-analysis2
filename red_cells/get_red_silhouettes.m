%% get silhouette scores across all datasets!
function [all_sil,missing_data] = get_red_silhouettes(info,plot_info,save_data_directory)
all_sil = []; missing_data =[];
for m = 1:length(info.mouse_date)
    m
    temp = [];
    mm = info.mouse_date(m)
    mm = mm{1,1};
    ss = info.server(m);
    ss = ss {1,1};
    load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/dual_red/clustering_info.mat')); %load clustering info!

    red_vects = find(clustering_info.redvect); 
    celltype_ids = clustering_info.cellids(red_vects);
    if length(clustering_info.used_silhouettes) == length(celltype_ids)
        temp(1,:)= clustering_info.used_silhouettes;
        temp(2,:) = celltype_ids;
        all_sil = [all_sil, temp];
    else %mouse that had uncertain cells that were deleted!
%         allredvect = clustering_info.redvect;
%         allredvect(unique([clustering_info.uncertain])) = 1;
%         new_ids = find(ismember(find(allredvect),red_vects)); %this should match the number of actually used cells
% 
%         temp(1,:)= clustering_info.used_silhouettes(new_ids);
%         temp(2,:) = celltype_ids;
%         all_sil = [all_sil, temp];

        missing_data = [missing_data,info.mouse_date(m)];
    end
end

%% make histogram of silhoutte scores across celltypes!
pv = find(all_sil(2,:)== 2);
som = find(all_sil(2,:)== 1);
figure(88);clf;
hold on
histogram(all_sil(1,pv),'BinWidth',0.02,'FaceColor',plot_info.colors_celltype(3,:),'Normalization','probability'); 
histogram(all_sil(1,som),'BinWidth',0.02,'FaceColor',plot_info.colors_celltype(2,:),'Normalization','probability'); 
hold off
title('Silhouettes Scores')
legend('PV','SOM','location','northwest')

figure(89);clf;
hold on;
Violin({all_sil(1,pv)},1,'ViolinColor', {plot_info.colors_celltype(2,:)});Violin({all_sil(1,pv)},2,'ViolinColor', {plot_info.colors_celltype(3,:)});hold off
ylabel('Silhouettes Scores')
xticks([1,2])
xticklabels({'PV','SOM'})

[red_stats.all] = get_basic_stats(all_sil(1,:));
[red_stats.som] = get_basic_stats(all_sil(1,som));
[red_stats.pv] = get_basic_stats(all_sil(1,pv));

som_sem = red_stats.som.sd/sqrt(red_stats.som.n);
pv_sem = red_stats.pv.sd/sqrt(red_stats.pv.n);

red_stats.pv.sem = pv_sem;
red_stats.som.sem = som_sem;

p_val = ranksum(all_sil(1,som),all_sil(1,pv));
red_stats.p_val = p_val;


figure(90);clf;
hold on;

x_values = 1:2;  % x-values for plots

scatter(1,mean(all_sil(1,som)),'filled','SizeData',60, 'LineWidth', 1, 'MarkerEdgeColor', plot_info.colors_celltype(2,:), 'Color', plot_info.colors_celltype(2,:));  % som
scatter(2,mean(all_sil(1,pv)), 'filled','SizeData',60, 'LineWidth', 1, 'MarkerEdgeColor', plot_info.colors_celltype(3,:), 'Color', plot_info.colors_celltype(3,:));  % pv

errorbar(1, mean(all_sil(1,som)), som_sem, 'o', 'MarkerSize', 10, 'MarkerEdgeColor',plot_info.colors_celltype(2,:), 'Color', plot_info.colors_celltype(2,:));  % som
errorbar(2, mean(all_sil(1,pv)), pv_sem, 'o', 'MarkerSize', 10, 'MarkerEdgeColor', plot_info.colors_celltype(3,:), 'Color', plot_info.colors_celltype(3,:));  % pv


% if p_val< 0.05
%     xline_vars = 1:2;   
%     y_val = max(all_sil(1,:));
%     plot_pval_star(0, y_val+.1, p_val, xline_vars,0.01)
% end

ylabel('Silhouettes Scores')
xticks([1,2])
xticklabels({'SOM','PV'})
xlim([0 3])
set_current_fig;

if ~isempty(save_data_directory)
    mkdir(save_data_directory)
    cd(save_data_directory)

    image_string = strcat('Silhouettes_scores_',num2str(length(info.mouse_date) - length(missing_data)));
    saveas(88,[image_string '_datasets.svg']);
    saveas(88,[image_string '_datasets.fig']);
    saveas(88,[image_string '_datasets.pdf']);

    saveas(90,[image_string '_datasets_scattersem.svg']);
    saveas(90,[image_string '_datasets_scattersem.fig']);
    saveas(90,[image_string '_datasets_scattersem.pdf']);

    save('all_sil','all_sil');
    save('missing_data','missing_data')
    save('red_stats','red_stats');
end

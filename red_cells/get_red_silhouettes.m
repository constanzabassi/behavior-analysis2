%% get silhouette scores across all datasets!
function [all_sil,missing_data] = get_red_silhouettes(info,plot_info,save_data_directory)
all_sil = []; missing_data =[];
all_silhouettes = {}; total_pyr = [];
for dataset_index = 1:length(info.mouse_date)
    dataset_index
    temp = [];
    datasets_id = info.mouse_date(dataset_index)
    datasets_id = datasets_id{1,1};
    ss = info.server(dataset_index);
    ss = ss {1,1};
    load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(datasets_id),'/dual_red/clustering_info.mat')); %load clustering info!

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
        % Given `redvect` after removing uncertain values (length 62)
        redvect = find(clustering_info.redvect); % Your filtered redvect
        
        % Uncertain values to locate in the original sequence
        uncertain_positions = clustering_info.uncertain; % Example: [218, 251, 261]
        if contains(datasets_id,'2023-07-07')
            uncertain_positions = uncertain_positions(2:3); %union(clustering_info.uncertain,clustering_info.excluded);
        elseif contains(datasets_id,'2023-03-31')
            uncertain_positions = uncertain_positions(2);
        end
        % Find where these uncertain values **would have been** in `redvect`
            indices_to_remove = zeros(size(uncertain_positions)); % Preallocate
        
        
        for i = 1:length(uncertain_positions)
            % Find the first index where redvect surpasses the uncertain value
            idx = find(redvect >= uncertain_positions(i), 1, 'first');
            
            if isempty(idx)
                indices_to_remove(i) = length(redvect) + 1; % If it's larger than all elements
            else
                indices_to_remove(i) = idx;
                
                % If multiple uncertain values lie between, increment the indices
                if i > 1 && indices_to_remove(i) == (indices_to_remove(i-1))
                    indices_to_remove(i:end) = indices_to_remove(i:end) + 1;
                end
            end
        end
        clustering_info.used_silhouettes(indices_to_remove) = [];
        temp(1,:)= clustering_info.used_silhouettes;
        temp(2,:) = celltype_ids;
        all_sil = [all_sil, temp];
        
        missing_data = [missing_data,info.mouse_date(dataset_index)];
    end
    som_indices = find(temp(2,:) == 1);
    pv_indices = find(temp(2,:) == 2);
    all_silhouettes{dataset_index,1} = temp(1,som_indices); %SOM
    all_silhouettes{dataset_index,2} = temp(1,pv_indices); %PV
    total_pyr =[ total_pyr ,length(find(clustering_info.cellids == 0))];

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

%% make plots divided by datasets
n_mice = length(all_silhouettes);
figure(91);clf;
for celltype= 1:2
    hold on
    %SOM
    h = boxplot(cellfun(@nanmean ,{all_silhouettes{:,celltype}}), 'position', celltype, 'width', .7, 'colors',  plot_info.colors_celltype(celltype+1,:),'symbol', 'o');
    %set line width
    out_line = findobj(h, 'Tag', 'Outliers');
    set(out_line, 'Visible', 'off');
    hh = findobj('LineStyle','--','LineWidth',1); 
    set(h(1:6), 'LineStyle','-','LineWidth',1.5);
    for m = 1:n_mice
        jitter = (rand-.5) *.5;
    %     plot(1+jitter, mean(all_silhouettes{m,1})  ,'o','MarkerFaceColor', plot_info.colors_celltype(2,:),0.2);
        scatter(celltype+jitter, mean(all_silhouettes{m,1}), 30, ...
                            plot_info.colors_celltype(celltype+1,:), 'o', 'filled', ...
                            'MarkerFaceAlpha', 0.4)
    end
    ylim([.8 1])
    
    hold off
end
xlim([0,3])
xticks([1,2])
xticklabels({'SOM', 'PV'});
ylabel('Silhouette Score')
box off
set(gcf,'units','points','position',[100,100,150,150])
set_current_fig;

p_val = signrank(cellfun(@nanmean ,{all_silhouettes{:,1}}),cellfun(@nanmean ,{all_silhouettes{:,2}}));
red_stats.p_val_sign_datasets = p_val;

figure(92);clf;
mouse_means = [cellfun(@length ,{all_silhouettes{:,1}});cellfun(@length ,{all_silhouettes{:,2}})];
for celltype= 1:2
    mean_cel = mean(cellfun(@length ,{all_silhouettes{:,celltype}}));
    err = std(cellfun(@length ,{all_silhouettes{:,celltype}})) / sqrt(length(all_silhouettes));
    hold on
    errorbar(celltype, mean_cel, err, 'o', ...
        'Color', plot_info.colors_celltype(celltype+1,:), ...
        'LineWidth', 1, 'MarkerSize', 2,'MarkerFaceColor', plot_info.colors_celltype(celltype+1,:));
    % Plot connected line for this mouse
    plot([1+.2,2-.2], mouse_means, '-', 'Color', ...
        [0.5,0.5,0.5, 0.3], 'LineWidth', 1)

end
xlim([0,3])
xticks([1,2])
xticklabels({'SOM', 'PV'});
box off
set(gcf,'units','points','position',[100,100,150,150])
ylabel('Cell Counts')
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

    exportgraphics(figure(92),strcat('cell_counts_connected_lines_n',num2str(n_mice),'_datasets.pdf'), 'ContentType', 'vector');
    exportgraphics(figure(91),strcat('Silouette_scores_n',num2str(n_mice),'_datasets.pdf'), 'ContentType', 'vector');


    save('all_sil','all_sil');
    save('all_silhouettes','all_silhouettes');
    save('missing_data','missing_data')
    save('red_stats','red_stats');
end

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
    else
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

if ~isempty(save_data_directory)
    mkdir(save_data_directory)
    cd(save_data_directory)

    image_string = strcat('Silhouettes_scores_',num2str(length(info.mouse_date) - length(missing_data)));
    saveas(88,[image_string '_datasets.svg']);
    saveas(88,[image_string '_datasets.fig']);
    saveas(88,[image_string '_datasets.pdf']);
end

function plot_zscore_comparisons(z_scores, pvals, celltype_list, saveorno, savepath)

% Inputs:
% - z_scores: z-scores for each pairwise comparison
% - pvals: empirical p-values from bootstrap
% - celltype_list: e.g. {'pyr_cells','som_cells','pv_cells'}
% - saveorno: 0 (no save) or 1 (save plot)
% - savepath: where to save if saveorno = 1

combos = nchoosek(1:numel(celltype_list), 2);
labels = cell(size(combos,1),1);

for i = 1:size(combos,1)
    labels{i} = [strrep(celltype_list{combos(i,1)},'_cells','') ' vs ' strrep(celltype_list{combos(i,2)},'_cells','')];
end

figure; set(gcf,'color','w');
bar(z_scores, 'FaceColor', [0.4 0.6 0.8]); hold on;

% Annotate significance
for i = 1:length(pvals)
    star = '';
    if pvals(i) < 0.001
        star = '***';
    elseif pvals(i) < 0.01
        star = '**';
    elseif pvals(i) < 0.05
        star = '*';
    end
    text(i, z_scores(i) + 0.1*sign(z_scores(i)), star, 'HorizontalAlignment', 'center', 'FontSize', 14);
end

xticks(1:length(labels));
xticklabels(labels);
xtickangle(45);
ylabel('Z-score (bootstrap)');
title('Pairwise Comparison of Cell Type Responses');

box off;
ylim padded;

if saveorno
    if ~exist(savepath, 'dir'); mkdir(savepath); end
    saveas(gcf, fullfile(savepath, 'zscore_celltype_comparisons.png'));
    saveas(gcf, fullfile(savepath, 'zscore_celltype_comparisons.svg'));
end
end

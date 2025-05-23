function boxplot_zscore_responsive(z_score_struct, plot_info, info, saveorno)

tw = 1:6; % task windows
celltypes = {'pyr', 'som', 'pv'};
celltype_colors = plot_info.colors_celltype;
combos = nchoosek(1:3, 2);
x_seq = [-0.2, 0, 0.2];
w = 0.15; yma = -Inf;

figure; hold on; set(gcf,'color','w');
yline(0,'--k','Alpha',0.5)

for t = 1:length(tw)
    for ce = 1:3
        ct_name = celltypes{ce};
        all_z = [];

        for d = 1:numel(z_score_struct)
            zvals = z_score_struct{d}(tw(t)).(ct_name).zscore;
            all_z = [all_z; zvals(:)];
        end

        pos = t + x_seq(ce);
        h = boxplot(all_z, 'positions', pos, 'widths', w, ...
            'colors', celltype_colors(ce,:), 'symbol', '');
        set(h(1:6), 'LineStyle','-', 'LineWidth', 1.1);
        yma = max(yma, max(all_z)+2);
    end

    % Significance bars between cell types
    for c = 1:size(combos,1)
        data1 = []; data2 = [];
        for d = 1:numel(z_score_struct)
            z1 = z_score_struct{d}(tw(t)).(celltypes{combos(c,1)}).zscore;
            z2 = z_score_struct{d}(tw(t)).(celltypes{combos(c,2)}).zscore;
            data1 = [data1; z1(:)];
            data2 = [data2; z2(:)];
        end
        pval = ranksum(data1, data2);
        x1 = t + x_seq(combos(c,1));
        x2 = t + x_seq(combos(c,2));
%         plot_pval_star([x1, x2], yma + c*1.5, pval, 0.1);
    end
end

set(gca,'xtick',1:length(tw), 'xticklabel', plot_info.xlabel_events(tw), ...
    'xticklabelrotation', 45);
xlim([0.5 length(tw)+0.5]); ylim([-4 7]);
ylabel('Z-score of Task Responsiveness');
title('Z-scored responsiveness by cell type', 'FontWeight','Normal');
box off;
set_current_fig;

if saveorno == 1
    mkdir([info.savepath '/responsive_zscores']);
    cd([info.savepath '/responsive_zscores']);
    saveas(gcf,'boxplot_zscore_responsive.png');
    saveas(gcf,'boxplot_zscore_responsive.svg');
end

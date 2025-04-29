function boxplot_zscore_responsive_from_raw(all_celltypes, all_datasets_aligned, responsive_neuron_zscore, plot_info, info, saveorno)

tw = 1:6; % task windows
celltypes = {'pyr', 'som', 'pv'};
combos = nchoosek(1:3, 2);
ts_str = plot_info.xlabel_events;

n_datasets = numel(all_datasets_aligned);
zscore_data = NaN(n_datasets, length(tw), 3); % [datasets x tw x celltypes]

% Collect z-scored responsive fractions by indexing into the neuron set
for d = 1:n_datasets
    d
    aligned_data = all_datasets_aligned{d}; % [trials x neurons x time]
    zscore_matrix = responsive_neuron_zscore{d}; % [neurons x time_window]
    
    for ce = 1:3
        switch celltypes{ce}
            case 'pyr'
                ids = all_celltypes{d}.pyr_cells;
            case 'som'
                ids = all_celltypes{d}.som_cells;
            case 'pv'
                ids = all_celltypes{d}.pv_cells;
        end
        
        if isempty(ids), continue; end
        
        % Take mean z-score over all neurons in this cell type
        for t = 1:length(tw)
            vals = zscore_matrix{t}(ids);
            vals = vals(~isnan(vals));
            if ~isempty(vals)
                zscore_data(d, t, ce) = mean(vals);  % mean or median
            end
        end
    end
end

%% PLOT
figure; set(gcf,'color','w'); hold on; yma = -Inf;
w = 0.15; mksz = 10;  r = 0.5;
x_seq = [-0.2, 0, 0.2];

for t = 1:length(tw)
    for ce = 1:3
        v = zscore_data(:,t,ce);
        h = boxplot(v, 'position', t+x_seq(ce), 'width', w, ...
            'colors', plot_info.colors_celltype(ce,:), 'symbol', 'o');
        set(h(1:6), 'LineStyle','-', 'LineWidth', 1.1);
        yl = ylim; yma = max(yma, yl(2)+0.5);

        % Optional: explicitly hide outlier markers
        out_line = findobj(h, 'Tag', 'Outliers');
        set(out_line, 'Visible', 'off');

    end
    ct = 0;
    % Statistical comparisons
    for c = 1:size(combos,1)
        
        data = squeeze(zscore_data(:,tw(t),combos(c,:)));
        y_val = max(max(zscore_data(:,tw(t),:)));
        pval = ranksum(data(:,1), data(:,2));
        x_line_vals = x_seq(combos(c,:));
        if pval < 0.05
            ct = ct +1;
        end
        plot_pval_star(t, y_val + (ct*0.4), pval, x_line_vals, 0.15);
    end
end

set(gca, 'xtick', 1:length(tw), 'xticklabel', ts_str(tw), 'xticklabelrotation', 45);
xlim([0.5 length(tw)+0.5]); ylim([-.5 1.5]);
ylabel('Z-score of responsive fraction');
box off;
title('Z-scored responsive cells','FontWeight','Normal');
set_current_fig;

if saveorno == 1
    mkdir([info.savepath '/responsive'])
    cd([info.savepath '/responsive'])
    saveas(gcf,'boxplot_zscore_responsive.png')
    saveas(gcf,'boxplot_zscore_responsive.svg')
end
end

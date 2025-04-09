function plot_dist_weights(bin_id, betas,all_celltypes,plot_info,data_type,svm_info,celtype)
possible_celltypes = fieldnames(all_celltypes{1,1});


figure(572);clf;
[rows,columns] = determine_num_tiles(size(betas,2)); %uses length of input
tiledlayout(rows,columns);

edges = -1:0.1:1; %bin edges can be changed

for m = 1:size(betas,2) %per mouse

    all_data = [betas{:,m,bin_id}]; %neurons x num_iterations
    if ~isempty(all_data)
        nexttile
        hold on;
    
        if ~isempty(celtype)
            for ce = celtype
                ex_mouse = m;
                
                % Plotting the histogram %PLOT standard error of the mean across
                % subsample iterations
                
                mean_data = mean(all_data(all_celltypes{1,m}.(possible_celltypes{ce}),:),2); %find mean for specified cells across all subsamples
                [mean_prob]= get_hist(mean_data,edges);
                [across_prob] = get_hist(all_data(all_celltypes{1,m}.(possible_celltypes{ce}),:),edges);%cellfun(@(x) get_hist(x,edges),{all_data(all_celltypes{1,m}.(possible_celltypes{ce}),:)},'UniformOutput',false);%probability values for each cell across subsamples
        
        
                SEM= std(across_prob')/sqrt(size(across_prob,2)); %frames/num iterations
                shadedErrorBar(edges,mean_prob, SEM, 'lineProps',{'color', plot_info.colors_celltype(ce,:),'LineWidth', 1.5});
            end
        else
                ex_mouse = m;
                
                % Plotting the histogram %PLOT standard error of the mean across
                % subsample iterations
                
                mean_data = mean(all_data,2); %find mean for specified cells across all subsamples
                [mean_prob]= get_hist(mean_data,edges);
                [across_prob] = get_hist(all_data,edges);%cellfun(@(x) get_hist(x,edges),{all_data(all_celltypes{1,m}.(possible_celltypes{ce}),:)},'UniformOutput',false);%probability values for each cell across subsamples
        
        
                SEM= std(across_prob')/sqrt(size(across_prob,2)); %frames/num iterations
                shadedErrorBar(edges,mean_prob, SEM, 'lineProps',{'color', plot_info.colors_celltype(1,:),'LineWidth', 1.5});
    
        end
    
        % Adding labels and title
        xlabel('Classifier Weight');
        ylabel({'Probability'});
        title(svm_info.mouse_date(m));
    end
end
hold off

mkdir([svm_info.savepath '\SVM_' data_type '_' svm_info.savestr]);
cd([svm_info.savepath '\SVM_' data_type '_' svm_info.savestr]);
% save('roc_mdl','roc_mdl');
saveas(572,strcat('SVM_weights_across_cells_bin',num2str(bin_id),'.png'));
saveas(572,strcat('SVM_weights_across_cells_bin',num2str(bin_id),'.svg'));
exportgraphics(gcf,strcat('SVM_weights_across_cells_bin',num2str(bin_id),'.pdf'), 'ContentType', 'vector');

% --- NEW FINAL FIGURE FOR AVERAGE ACROSS DATASETS ---
figure(573); clf;

hold on;
edges = -1:0.1:1;

for ce = celtype
    histograms_per_mouse = []; % rows = datasets, cols = histogram bins
    
    for m = 1:size(betas,2)
        if isempty(betas{1,m,bin_id})
            continue; % skip if no data
        end
        all_data = [betas{:,m,bin_id}]; % neurons x iterations
        if ~isempty(all_data)
            cell_inds = all_celltypes{1,m}.(possible_celltypes{ce});
            if isempty(cell_inds)
                continue;
            end

            % Compute mean across iterations for each cell, then get histogram
            mean_data = mean(all_data(cell_inds, :), 2); % avg across iterations
            [mean_prob] = get_hist(mean_data, edges);    % histogram for this mouse

            histograms_per_mouse = [histograms_per_mouse; mean_prob]; % accumulate
        end
    end

    if ~isempty(histograms_per_mouse)
        % Now take mean and SEM across mice (each row = one mouse)
        mean_hist = mean(histograms_per_mouse, 1);
        sem_hist = std(histograms_per_mouse, 0, 1) / sqrt(size(histograms_per_mouse, 1));

        shadedErrorBar(edges, mean_hist, sem_hist, ...
            'lineProps', {'color', plot_info.colors_celltype(ce,:), 'LineWidth', 2});
    end
end

xlabel('Classifier Weight');
ylabel('Probability');
% legend(plot_info.labels,'Box','off','Location','best');

% Get current axis limits
x_range = xlim;
y_range = ylim;
y_offset_base = .2;
% Calculate base text position
text_x = x_range(2) - y_offset_base * diff(x_range);
text_y = y_range(2) - y_offset_base * diff(y_range);

% Auto-calculate evenly spaced y-offsets
num_labels = length(celtype);
y_offsets = linspace(0, 0.1 * (num_labels - 1), num_labels); % Adjusted scaling
% Place text labels
for i = 1:num_labels
    text(text_x, text_y - y_offsets(i) * diff(y_range), plot_info.labels{i}, ...
         'Color', plot_info.colors_celltype(i,:), 'FontSize', 8);
end
set(gca,'fontsize',12);
set(gcf,'position',[100,100,200,200])
exportgraphics(gcf,strcat('AVG_SVM_weights_across_cells_bin',num2str(bin_id),'.pdf'), 'ContentType', 'vector');

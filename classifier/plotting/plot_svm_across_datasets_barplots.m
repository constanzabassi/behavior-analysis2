function [plot_data,sorted_combinations, KW_Test] = plot_svm_across_datasets_barplots(svm_mat,plot_info,event_onsets,comp_window,save_str,save_path,minmax,varargin)
overall_mean = [];
overall_shuff = [];
total_celltypes = size(svm_mat,2);

for ce = 1:total_celltypes
    mean_across_data = cellfun(@(x) mean(x.accuracy,1),{svm_mat{:,ce}},'UniformOutput',false);
    mean_across_data = vertcat(mean_across_data{1,:})*100;
    if nargin > 7
        temp_mean = mean_across_data(:,varargin{1,1});
        mean_across_data = temp_mean;
    end
    overall_mean(ce,:) = mean(mean_across_data,1,'omitnan');
    mean_data(ce,:,:) = mean_across_data;

    mean_across_data_shuff = cellfun(@(x) mean(x.shuff_accuracy,1),{svm_mat{:,ce}},'UniformOutput',false);
    mean_across_data_shuff = vertcat(mean_across_data_shuff{1,:})*100;
    if nargin > 7
        temp_mean = mean_across_data_shuff(:,varargin{1,1});
        mean_across_data_shuff = temp_mean;
    end
    overall_shuff(ce,:) = mean(mean_across_data_shuff,1,'omitnan');
    mean_data2(ce,:,:) = mean_across_data_shuff;

end

%find average across specified time window
specified_window = event_onsets:event_onsets+comp_window; %1 sec %event_onsets:event_onsets+5;%
specified_mean = []; specified_mean_shuff =[];
for ce = 1:total_celltypes
    specified_mean(ce,:) = mean(mean_data(ce,:,specified_window),3,'omitnan'); %[max(squeeze(mean_data(ce,:,specified_window)),[],2)]
    specified_mean_shuff(ce,:) = mean(mean_data2(ce,:,specified_window),3,'omitnan');
end 

%concatenate shuffled all
specified_mean_all = vertcat(specified_mean,specified_mean_shuff(4,:)); %concatenate the all cells shuffled probably doesnt matter
total_celltypes = size(specified_mean_all,1);
plot_info.colors_celltype(total_celltypes,:) = [0.5,0.5,0.5];

tw = 1; %right now just focus on single svms
total_comparisons = total_celltypes; %four cell types

plot_data = cell(length(tw), total_comparisons);
combos = nchoosek(1:total_comparisons-1,2); %comparing celltypes

% Calculate the absolute difference between elements in each pair
abs_diff = abs(diff(combos, 1, 2));
% Sort combinations based on absolute difference, in descending order
[~, idx] = sort(abs_diff, 'ascend');
sorted_combinations = combos(idx, :);

ts_str = {plot_info.labels{1,:}, 'Shuff'};

figure(101);clf; set(gcf,'color','w'); hold on; yma = -Inf;
% set(gca,'Position', [100,100,150,170],'FontSize',8);

if total_celltypes > 5
    ratio = [0.6,.3];
    w = 0.075; 
else
    ratio = [0.6,.3];
    w = 0.1; 
end
x_val_dif = ratio(1)/(total_comparisons);%.6/(total_comparisons-1);
x_seq = [-ratio(2):x_val_dif:ratio(2)];
sig_ct = 0;
for t = 1:length(tw)
    for ce = 1:total_celltypes %compare across celltypes!
        
        data = specified_mean_all(ce,:); 
        
%         scatter(t*ones(nx,1)+w*(rand(nx,1)-0.5)+x_seq(a), v, mksz,...
%             cc{a}, 'filled', 'markerfacealpha', r);
        h = boxplot(data, 'position', t+x_seq(ce), 'width', w, 'colors', plot_info.colors_celltype(ce,:),'symbol', 'o');

        % Find lines connecting outliers and remove them
        out_line = findobj(h, 'Tag', 'Outliers');
        set(out_line, 'Visible', 'off');

        %set line width
        hh = findobj('LineStyle','--','LineWidth',0.5); 
        set(h(1:6), 'LineStyle','-','LineWidth',1.3);

        %set outliers
%         out_line = findobj(h, 'Tag', 'Outliers');
%         set(out_line, 'LineStyle','-','LineWidth',1.25);

        if ce==1; v0 = data; end
        yl = ylim;%setBoxStyle(h, 1);
        yma = max(yma, yl(2)+5);
        

    end

%     if ce == total_celltypes
%         data = specified_mean_shuff(ce,:); 
%         
%         h = boxplot(data, 'position', t+x_seq(ce+1), 'width', w, 'colors', [0.2 0.2 0.2]*ce,'symbol', 'o');
% 
%         % Find lines connecting outliers and remove them
%         out_line = findobj(h, 'Tag', 'Outliers');
%         set(out_line, 'Visible', 'off');
% 
%         %set line width
%         hh = findobj('LineStyle','--','LineWidth',0.5); 
%         set(h(1:6), 'LineStyle','-','LineWidth',1.3);
% 
%     end
    combos = sorted_combinations ;
    [KW_Test.celltypes_p_val,KW_Test.stimcontext_tbl, KW_Test.stimcontext_stats_cell] = kruskalwallis(specified_mean_all',[1:total_celltypes],'off');

    for c = 1:size(combos,1)
        data = [squeeze(specified_mean_all(combos(c,:),:))]; %specified_mean(ce,:)
        y_val =  max(max([squeeze(specified_mean_all(:,:))]));

%         pval = ranksum(data(1,:), data(2,:));
        [pval, observeddifference, effectsize] = permutationTest(data(1,:), data(2,:), 10000)
        plot_data{t,c} = pval;
        plot_data{length(tw)+2,c} = combos(c,:);
        x_line_vals = x_seq(combos(c,:));%relative to t+x_seq(ce)
        x_line_vals = [x_line_vals(1), x_line_vals(2)];
        if pval < 0.05/length(combos)
            sig_ct =sig_ct+1;
            plot_pval_star(t,y_val+(.04*sig_ct)*100, pval,x_line_vals,0.01); %yl(2)+3
        end

    end
end

for c = 1:total_celltypes-1
    data = [specified_mean(c,:);specified_mean_shuff(c,:)]; %specified_mean(ce,:)
    pval = ranksum(data(1,:), data(2,:));
    plot_data{2,c} = pval;
end
set(gca,'xtick',x_seq(1:total_celltypes)+1,'xticklabel',ts_str,'xticklabelrotation',45);
%set(gca,'xtick',1:length(tw),'xticklabel',ts_str(tw),'xticklabelrotation',45);
%xlim([0.5 length(tw)+0.5]); ylim([.4 1]);
xlim([1+x_seq(1)-.1 1+x_seq(end)]);
if ~isempty(minmax)
    ylim([minmax(1) minmax(2)]*100)
end
% yticks([.4:.1:1])
yline(.5*100,'--k');
ylabel('% Accuracy'); box off
%title('Decoding accuracy across cell types','FontWeight','Normal');
set_current_fig;
set(gcf,'position',[100,100,150,150])
set(gca,'FontSize',8);
ylim([minmax(1)*100, minmax(2)*100 + 15]);  % Add space above 100%

yticks = get(gca, 'YTick');
yticklabels = get(gca, 'YTickLabel');

% Hide any tick labels above 100%
for i = 1:length(yticks)
    if yticks(i) > minmax(2)*100
        yticklabels{i} = '';
    end
end

set(gca, 'YTick', yticks, 'YTickLabel', yticklabels);
% 3. Cover y-axis line above 100% (draw a white line over it)
yl = ylim;
xl = xlim;
line([xl(1), xl(1)], [minmax(2)*100, yl(2)], 'Color', 'w', 'LineWidth', 2);

svm_box_stats.p_vals = plot_data;
svm_box_stats.combos = sorted_combinations;

if ~isempty(save_path)
    mkdir(save_path )
    cd(save_path)
    saveas(101,strcat('boxplot_svm_alldatasets_',num2str(size(svm_mat,1)),save_str,'_bins',num2str(specified_window),'.svg'));
    saveas(101,strcat('boxplot_svm_alldatasets_',num2str(size(svm_mat,1)),save_str,'_bins',num2str(specified_window),'.png'));
    exportgraphics(gcf,strcat('boxplot_svm_alldatasets_',num2str(size(svm_mat,1)),save_str,'_bins',num2str(specified_window),'.pdf'), 'ContentType', 'vector');
    string_to_save = strcat('boxplot_svm_alldatasets_',num2str(size(svm_mat,1)),save_str,'_bins',num2str(specified_window),'.mat');
    save(string_to_save,"svm_box_stats");
end


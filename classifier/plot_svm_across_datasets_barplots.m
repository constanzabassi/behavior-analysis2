function [plot_data,sorted_combinations] = plot_svm_across_datasets_barplots(svm_mat,plot_info,event_onsets,comp_window,save_str,save_path)
overall_mean = [];
overall_shuff = [];
total_celltypes = size(svm_mat,2);

for ce = 1:total_celltypes
    mean_across_data = cellfun(@(x) mean(x.accuracy,1),{svm_mat{:,ce}},'UniformOutput',false);
    mean_across_data = vertcat(mean_across_data{1,:});
    overall_mean(ce,:) = mean(mean_across_data,1);
    mean_data(ce,:,:) = mean_across_data;

    mean_across_data_shuff = cellfun(@(x) mean(x.shuff_accuracy,1),{svm_mat{:,ce}},'UniformOutput',false);
    mean_across_data_shuff = vertcat(mean_across_data_shuff{1,:});
    overall_shuff(ce,:) = mean(mean_across_data_shuff,1);
    mean_data2(ce,:,:) = mean_across_data_shuff;

end

%find average across specified time window
specified_window = event_onsets:event_onsets+comp_window; %1 sec %event_onsets:event_onsets+5;%
specified_mean = []; specified_mean_shuff =[];
for ce = 1:total_celltypes
    specified_mean(ce,:) = mean(mean_data(ce,:,specified_window),3); %[max(squeeze(mean_data(ce,:,specified_window)),[],2)]
    specified_mean_shuff(ce,:) = mean(mean_data2(ce,:,specified_window),3);
end 


tw = 1; %right now just focus on single svms
total_comparisons = total_celltypes; %four cell types

plot_data = cell(length(tw), total_comparisons);
combos = nchoosek(1:total_comparisons,2); %comparing celltypes

% Calculate the absolute difference between elements in each pair
abs_diff = abs(diff(combos, 1, 2));
% Sort combinations based on absolute difference, in descending order
[~, idx] = sort(abs_diff, 'ascend');
sorted_combinations = combos(idx, :);

ts_str = plot_info.labels;

figure(101);clf; set(gcf,'color','w'); hold on; yma = -Inf;
w = 0.1; 

x_val_dif = .6/(total_comparisons-1);
x_seq = [-0.3:x_val_dif:0.3];
sig_ct = 0;
for t = 1:length(tw)
    for ce = 1:total_celltypes %compare across celltypes!
        
        data = specified_mean(ce,:); 
        
%         scatter(t*ones(nx,1)+w*(rand(nx,1)-0.5)+x_seq(a), v, mksz,...
%             cc{a}, 'filled', 'markerfacealpha', r);
        h = boxplot(data, 'position', t+x_seq(ce), 'width', w, 'colors', plot_info.colors_celltype(ce,:),'symbol', 'o');

        % Find lines connecting outliers and remove them
%         out_line = findobj(h, 'Tag', 'Outliers');
%         set(out_line, 'Visible', 'off');

        %set line width
        hh = findobj('LineStyle','--','LineWidth',0.5); 
        set(h(1:6), 'LineStyle','-','LineWidth',1.8);

        %set outliers
%         out_line = findobj(h, 'Tag', 'Outliers');
%         set(out_line, 'LineStyle','-','LineWidth',1.25);

        if ce==1; v0 = data; end
        yl = ylim;%setBoxStyle(h, 1);
        yma = max(yma, yl(2)+5);

    end
    combos = sorted_combinations ;
    for c = 1:size(combos,1)
        data = [squeeze(specified_mean(combos(c,:),:))]; %specified_mean(ce,:)
        y_val =  max(max([squeeze(specified_mean(:,:))]));
        pval = ranksum(data(1,:), data(2,:));
        plot_data{t,c} = pval;
        x_line_vals = x_seq(combos(c,:));%relative to t+x_seq(ce)
        x_line_vals = [x_line_vals(1), x_line_vals(2)];
        if pval < 0.05
            sig_ct =sig_ct+1;
            plot_pval_star(t,1+(sig_ct*.04), pval,x_line_vals,0.01); %yl(2)+3
        end

    end
end

for c = 1:total_celltypes
    data = [specified_mean(c,:);specified_mean_shuff(c,:)]; %specified_mean(ce,:)
    pval = ranksum(data(1,:), data(2,:));
    plot_data{2,c} = pval;
end

%set(gca,'xtick',1:length(tw),'xticklabel',ts_str(tw),'xticklabelrotation',45);
set(gca,'xtick',x_seq+1,'xticklabel',ts_str,'xticklabelrotation',45);
%xlim([0.5 length(tw)+0.5]); ylim([.4 1]);
xlim([1+x_seq(1)-.1 1+x_seq(end)+.1]); ylim([.4 1.15]);
yticks([.4:.1:1])
yline(.5,'--k');
ylabel('Decoding Accuracy'); box off
%title('Decoding accuracy across cell types','FontWeight','Normal');
set_current_fig;


if ~isempty(save_path)
    mkdir(save_path )
    cd(save_path)
    saveas(101,strcat('boxplot_svm_alldatasets_',num2str(size(svm_mat,1)),save_str,'.svg'));
    saveas(101,strcat('boxplot_svm_alldatasets_',num2str(size(svm_mat,1)),save_str,'.png'));
end


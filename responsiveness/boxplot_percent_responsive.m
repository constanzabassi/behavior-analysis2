% function plot_responsive

tw = 1:6;

plot_data = cell(length(tw), 3);
combos = nchoosek(1:3,2); %comparing celltypes
ts_str = {'Stim 1','Stim 2','Stim 3','Turn','Reward','ITI'};
% ts_str = {'Stim 1','Stim 2','Turn','Reward','ITI'};

figure; set(gcf,'color','w'); hold on; yma = -Inf;
w = 0.15; mksz = 10;  r = 0.5;
x_seq = [-0.2, 0, 0.2];

for t = 1:length(tw)
    for ce = 1:3 %compare across celltypes!
        
        v = num_responsive(:,tw(t),ce); v = v(:);
        
%         scatter(t*ones(nx,1)+w*(rand(nx,1)-0.5)+x_seq(a), v, mksz,...
%             cc{a}, 'filled', 'markerfacealpha', r);
        h = boxplot(v, 'position', t+x_seq(ce), 'width', w, 'colors', plot_info.colors_celltype(ce,:),'symbol', '');
        hh = findobj('LineStyle','--','LineWidth',0.5); set(h, 'LineStyle','-','LineWidth',1);
        if ce==1; v0 = v; end
        yl = ylim;%setBoxStyle(h, 1);
        yma = max(yma, yl(2)+5);

    end
    for c = 1:size(combos,1)
        data = [squeeze(num_responsive(:,tw(t),combos(c,:)))];
        y_val =  max(max([squeeze(num_responsive(:,tw(t),:))]));
        pval = ranksum(data(:,1), data(:,2));
        plot_data{t,c} = pval;
        x_line_vals = x_seq(combos(c,:));%relative to t+x_seq(ce)
        plot_pval_star(t,y_val+(c*3), pval,x_line_vals); %yl(2)+3
        

    end
end
set(gca,'xtick',1:length(tw),'xticklabel',ts_str(tw),'xticklabelrotation',45);
xlim([0.5 length(tw)+0.5]); ylim([0 104]);
ylabel('Percentage'); box off
title('Responsive cells','FontWeight','Normal');
set_current_fig;

% function plot_responsive

tw = 1:6;
ts_str = {'Stim 1','Stim 2','Stim 3','Turn','Reward','ITI'};
% ts_str = {'Stim 1','Stim 2','Turn','Reward','ITI'};

plot_data = cell(length(tw), 3);
figure; set(gcf,'color','w'); hold on; yma = -Inf;
w = 0.15; mksz = 10;  r = 0.5;
x_seq = [-0.2, 0, 0.2];
for t = 1:length(tw)
    for ce = 1:3 %compare across celltypes!
        
        v = num_responsive(:,tw(t),ce); v = v(:);
%         if a==1; v0 = v; end
%         scatter(t*ones(nx,1)+w*(rand(nx,1)-0.5)+x_seq(a), v, mksz,...
%             cc{a}, 'filled', 'markerfacealpha', r);
        h = boxplot(v, 'position', t+x_seq(ce), 'width', w, 'colors', plot_info.colors_celltype(ce,:));
        hh = findobj('LineStyle','--','LineWidth',0.5); set(h, 'LineStyle','-','LineWidth',1);
        yl = h;%setBoxStyle(h, 1);
        yma = max(yma, yl(2)+5);
%         try; pval = ranksum(v0, v);
%         catch ME; pval = 1;
%         end
%         plot_pval_star(t+x_seq(a), yl(2)+3, pval);
%         plot_data{t,ce} = v;
    end
end
set(gca,'xtick',1:length(tw),'xticklabel',ts_str(tw),'xticklabelrotation',45);
xlim([0.5 length(tw)+0.5]); ylim([0 max(yma,1)]);
ylabel('Percentage'); box off
title('Responsive cells','FontWeight','Normal');

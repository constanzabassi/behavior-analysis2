function [sig_test] = plot_performance_alt(performance,save_data_directory)
figure(5556);clf;
subplot(1,3,1)
hold on
bar(1, mean(cellfun(@(x) mean(mean(x),1),{(performance.y_vel)})),'FaceColor',[0.9 0.6 0],'LineStyle','none')
bar(2, mean(cellfun(@(x) mean(mean(x),1),{(performance.y_vel_ctrl)})),'FaceColor',[0.8 0.8 0.8],'LineStyle','none')

% for m = 1:size(performance,2)
% plot([ mean([performance(:,m).y_vel]),mean([performance(:,m).correct_ctrl])]*100 ,'-','color','k', 'MarkerFaceColor', 'k');
% 
% end
set(gca, 'XLimMode', 'manual', 'XLim', [0 3]);
xticks([1 2])
xticklabels({'Opto','Ctrl'})
ylabel('y velocity')

[sig_test.p_y, h1] = signrank(cellfun(@(x) mean(x),{(performance.y_vel)}),cellfun(@(x) mean(x),{(performance.y_vel_ctrl)}));
plot_pval_star(0,max([cellfun(@(x) mean(x),{(performance.y_vel)})]), sig_test.p_y,[1 2],.15); %yl(2)+3

set_current_fig;
set(gca,'FontSize',12);
%%
subplot(1,3,2)
hold on
bar(1, mean(cellfun(@(x) mean(mean(x),1),{(performance.x_vel)})),'FaceColor',[0.9 0.6 0],'LineStyle','none')
bar(2, mean(cellfun(@(x) mean(mean(x),1),{(performance.x_vel_ctrl)})),'FaceColor',[0.8 0.8 0.8],'LineStyle','none')

% for m = 1:size(performance,2)
% plot([ mean([performance(:,m).y_vel]),mean([performance(:,m).correct_ctrl])]*100 ,'-','color','k', 'MarkerFaceColor', 'k');
% 
% end
set(gca, 'XLimMode', 'manual', 'XLim', [0 3]);
xticks([1 2])
xticklabels({'Opto','Ctrl'})
ylabel('x velocity')

[sig_test.p_x, h1] = signrank(cellfun(@(x) mean(x),{(performance.x_vel)}),cellfun(@(x) mean(x),{(performance.x_vel_ctrl)}));
plot_pval_star(0,max([cellfun(@(x) mean(x),{(performance.x_vel)})]), sig_test.p_x,[1 2],.15); %yl(2)+3

set_current_fig;
set(gca,'FontSize',12);

%%
subplot(1,3,3)
hold on
bar(1, mean(cellfun(@(x) mean(mean(x),1),{(performance.view_angle)})),'FaceColor',[0.9 0.6 0],'LineStyle','none')
bar(2, mean(cellfun(@(x) mean(mean(x),1),{(performance.view_angle_ctrl)})),'FaceColor',[0.8 0.8 0.8],'LineStyle','none')

% for m = 1:size(performance,2)
% plot([ mean([performance(:,m).y_vel]),mean([performance(:,m).correct_ctrl])]*100 ,'-','color','k', 'MarkerFaceColor', 'k');
% 
% end
set(gca, 'XLimMode', 'manual', 'XLim', [0 3]);
xticks([1 2])
xticklabels({'Opto','Ctrl'})
ylabel('view angle')

[sig_test.p_view, h1] = signrank(cellfun(@(x) mean(x),{(performance.view_angle)}),cellfun(@(x) mean(x),{(performance.view_angle_ctrl)}));
plot_pval_star(0,max([cellfun(@(x) mean(x),{(performance.view_angle)})]), sig_test.p_view,[1 2],.15); %yl(2)+3


set_current_fig;
set(gca,'FontSize',12);

%% save figures

if ~isempty(save_data_directory)
    mkdir(save_data_directory)
    cd(save_data_directory)

    image_string = strcat('paired_opto_ctrl_performance_alt_',num2str(size(performance,2)));
    saveas(5556,[image_string '_datasets.svg']);
    saveas(5556,[image_string '_datasets.fig']);
    saveas(5556,[image_string '_datasets.pdf']);
end
function [sig_test] = plot_performance(performance,save_data_directory)
[r,c] = determine_num_tiles(size(performance,2));
figure(5555);clf;
% tiledlayout(r,c)
%% % CORRECT
subplot(1,3,1)
hold on
bar(1, mean(cellfun(@(x) mean(x,1),{performance.correct_opto}))*100,'FaceColor',[0.9 0.6 0],'LineStyle','none')
bar(2, mean(cellfun(@(x) mean(x,1),{performance.correct_ctrl}))*100,'FaceColor',[0.8 0.8 0.8],'LineStyle','none')

for m = 1:size(performance,2)
plot([ mean([performance(:,m).correct_opto]),mean([performance(:,m).correct_ctrl])]*100 ,'-','color','k', 'MarkerFaceColor', 'k');

end
set(gca, 'XLimMode', 'manual', 'XLim', [0 3]);
xticks([1 2])
xticklabels({'Opto','Ctrl'})
ylabel('% correct')

[sig_test.p_correct, h1] = signrank([performance.correct_opto],[performance.correct_ctrl]);
plot_pval_star(0,max([performance.correct_opto])*100, sig_test.p_correct,[1 2],.15); %yl(2)+3

set_current_fig;
set(gca,'FontSize',12);
%% % LEFT TURNS
subplot(1,3,2)
hold on
bar(1, mean(cellfun(@(x) mean(x,1),{performance.left_opto}))*100,'FaceColor',[0.9 0.6 0],'LineStyle','none')
bar(2, mean(cellfun(@(x) mean(x,1),{performance.left_ctrl}))*100,'FaceColor',[0.8 0.8 0.8],'LineStyle','none')

for m = 1:size(performance,2)

plot([ mean([performance(:,m).left_opto]),mean([performance(:,m).left_ctrl])]*100 ,'-','color','k', 'MarkerFaceColor', 'k');

end
set(gca, 'XLimMode', 'manual', 'XLim', [0 3]);
xticks([1 2])
xticklabels({'Opto','Ctrl'})
ylabel('% left')

[sig_test.p_left, h1] = signrank([performance.left_opto],[performance.left_ctrl]);
plot_pval_star(0,max([performance.left_opto])*100, sig_test.p_left,[1 2],.15); %yl(2)+3

set_current_fig;
set(gca,'FontSize',12);
%% TIME TO COMPLETE TURN
subplot(1,3,3)
hold on
bar(1, mean(cellfun(@(x) mean(mean(x),1),{performance.turn_onset_opto}))/30,'FaceColor',[0.9 0.6 0],'LineStyle','none')
bar(2, mean(cellfun(@(x) mean(mean(x),1),{performance.turn_onset_ctrl}))/30,'FaceColor',[0.8 0.8 0.8],'LineStyle','none')

temp = [];
for m = 1:size(performance,2)
opto_turn = mean(performance(1,m).turn_onset_opto)/30;
ctrl_turn = mean(performance(1,m).turn_onset_ctrl)/30;
temp(m,:) = [opto_turn, ctrl_turn];

plot([opto_turn,ctrl_turn] ,'-','color','k', 'MarkerFaceColor', 'k');

end
set(gca, 'XLimMode', 'manual', 'XLim', [0 3]);
xticks([1 2])
xticklabels({'Opto','Ctrl'})
ylabel({'seconds to'; 'turn onset'})

[sig_test.p_turn_onset, h1] = signrank(temp(:,1),temp(:,2));
plot_pval_star(0,max(cellfun(@mean,{performance.turn_onset_opto}))/30, sig_test.p_turn_onset,[1 2],.15); %yl(2)+3

set_current_fig;
set(gca,'FontSize',12);
% %% perform statistical analysis
% [sig_test.p_correct, h1] = signrank([performance.correct_opto],[performance.correct_ctrl]);
% [sig_test.p_left, h1] = signrank([performance.left_opto],[performance.left_ctrl]);
% [sig_test.p_turn_onset, h1] = signrank(temp(:,1),temp(:,2));

%% save figures

if ~isempty(save_data_directory)
    mkdir(save_data_directory)
    cd(save_data_directory)

    image_string = strcat('paired_opto_ctrl_performance_dots_',num2str(size(performance,2)));
    saveas(5555,[image_string '_datasets.svg']);
    saveas(5555,[image_string '_datasets.fig']);
    saveas(5555,[image_string '_datasets.pdf']);
end
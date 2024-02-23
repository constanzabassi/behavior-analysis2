function [sig_test] = plot_performance(performance,save_data_directory)
[r,c] = determine_num_tiles(size(performance,2));
figure(5555);clf;
% tiledlayout(r,c)
%% % CORRECT
subplot(1,3,1)
for m = 1:size(performance,2)
hold on
plot([ mean([performance(:,m).correct_opto]),mean([performance(:,m).correct_ctrl])]*100 ,'-o','color','k', 'MarkerFaceColor', 'k');

end
set(gca, 'XLimMode', 'manual', 'XLim', [0 3]);
xticks([1 2])
xticklabels({'Opto','Ctrl'})
title('% Correct')
%% % LEFT TURNS
subplot(1,3,2)
for m = 1:size(performance,2)
hold on
plot([ mean([performance(:,m).left_opto]),mean([performance(:,m).left_ctrl])]*100 ,'-o','color','k', 'MarkerFaceColor', 'k');

end
set(gca, 'XLimMode', 'manual', 'XLim', [0 3]);
xticks([1 2])
xticklabels({'Opto','Ctrl'})
title('% Left')
%% TIME TO COMPLETE TURN
subplot(1,3,3)
temp = [];
for m = 1:size(performance,2)
opto_turn = mean(performance(1,m).turn_onset_opto)/30;
ctrl_turn = mean(performance(1,m).turn_onset_ctrl)/30;
temp(m,:) = [opto_turn, ctrl_turn];
hold on
plot([opto_turn,ctrl_turn] ,'-o','color','k', 'MarkerFaceColor', 'k');

end
set(gca, 'XLimMode', 'manual', 'XLim', [0 3]);
xticks([1 2])
xticklabels({'Opto','Ctrl'})
title('sec to turn onset')
%% perform statistical analysis
[sig_test.p_correct, h1] = signrank([performance.correct_opto],[performance.correct_ctrl]);
[sig_test.p_left, h1] = signrank([performance.left_opto],[performance.left_ctrl]);
[sig_test.p_turn_onset, h1] = signrank(temp(:,1),temp(:,2));

%% save figures

if ~isempty(save_data_directory)
    mkdir(save_data_directory)
    cd(save_data_directory)

    image_string = strcat('paired_opto_ctrl_performance_dots_',num2str(size(performance,2)));
    saveas(5555,[image_string '_datasets.svg']);
    saveas(5555,[image_string '_datasets.fig']);
    saveas(5555,[image_string '_datasets.pdf']);
end
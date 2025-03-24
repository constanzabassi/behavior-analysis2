function plot_performance_all(performance,save_data_directory, mouseID)
[r,c] = determine_num_tiles(size(performance,2));
figure(5556);clf;
rng(1);
% tiledlayout(r,c)

%% 1) get means across mouse_indices
unique_mice = unique(mouseID);
n_mice = length(unique_mice);
correct_per_mouse = [];
left_per_mouse = [];
sec_to_turn_per_mouse = [];

for m = 1:n_mice
    curr_mouse = unique_mice(m);
    mouse_datasets = find(mouseID == curr_mouse);
    d = mouse_datasets;
    correct_per_mouse = [correct_per_mouse,mean([performance(d).correct_all])];
    left_per_mouse = [left_per_mouse,mean([performance(d).left_all])];
    sec_to_turn_per_mouse = [sec_to_turn_per_mouse,mean([performance(d).turn_onset_all])];
    
end
%2) get symbols if given
if n_mice > 20
    mouse_symbols = cell(1,n_mice);
    mouse_symbols(1:n_mice) = {'*'};
else
    mouse_symbols = cell(1,n_mice);
    mouse_symbols = {'>','o','d','s','p','v'};
    
end

%% % CORRECT
subplot(1,3,1)
hold on
bar(1, mean(correct_per_mouse)*100,'FaceColor',[0.5 .5 .5],'LineStyle','none')
% bar(1, mean(correct_per_mouse)*100,'FaceColor',[1 1 1],'EdgeColor',[0.5 0.5 0.5])

for m = 1:n_mice
    jitter = (rand-.5) *.8;
    plot(1+jitter, [correct_per_mouse(m)]*100  ,mouse_symbols{m},'color','k', 'MarkerEdgeColor', 'k');
end
set(gca, 'XLimMode', 'manual', 'XLim', [0 2]);
xticks([1])
xticklabels({'All trials'})
ylabel('% correct')

% [sig_test.p_correct, h1] = signrank([performance.correct_opto],[performance.correct_ctrl]);
% plot_pval_star(0,max([performance.correct_opto])*100, sig_test.p_correct,[1 2],.15); %yl(2)+3

set_current_fig;
set(gca,'FontSize',12);
%% % LEFT TURNS
subplot(1,3,2)
hold on
bar(1, mean(left_per_mouse)*100,'FaceColor',[0.5 0.5 0.5],'LineStyle','none')

for m = 1:n_mice
    jitter = (rand-.5) *.8;
    plot(1+jitter, [left_per_mouse(m)]*100  ,mouse_symbols{m},'color','k', 'MarkerEdgeColor', 'k');
end
set(gca, 'XLimMode', 'manual', 'XLim', [0 2]);
xticks([1])
xticklabels({'All trials'})
ylabel('% left')
ylim([0 75])

% [sig_test.p_left, h1] = signrank([performance.left_opto],[performance.left_ctrl]);
% plot_pval_star(0,max([performance.left_opto])*100, sig_test.p_left,[1 2],.15); %yl(2)+3

set_current_fig;
set(gca,'FontSize',12);
%% TIME TO COMPLETE TURN
subplot(1,3,3)
hold on
bar(1, mean(sec_to_turn_per_mouse),'FaceColor',[0.5 0.5 0.5],'LineStyle','none')

for m = 1:n_mice
    jitter = (rand-.5) *.8;
    plot(1+jitter, [sec_to_turn_per_mouse(m)]  ,mouse_symbols{m},'color','k', 'MarkerEdgeColor', 'k');
end
set(gca, 'XLimMode', 'manual', 'XLim', [0 2]);
xticks([1])
xticklabels({'All trials'})
ylabel({'seconds to'; 'turn onset'})

% [sig_test.p_turn_onset, h1] = signrank(temp(:,1),temp(:,2));
% plot_pval_star(0,max(cellfun(@mean,{performance.turn_onset_opto}))/30, sig_test.p_turn_onset,[1 2],.15); %yl(2)+3

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

    image_string = strcat('all_performance_dots_',num2str(size(performance,2)));
    saveas(5556,[image_string '_datasets.svg']);
    saveas(5556,[image_string '_datasets.fig']);
    exportgraphics(figure(5556),[image_string '_datasets.pdf'], 'ContentType', 'vector');
end
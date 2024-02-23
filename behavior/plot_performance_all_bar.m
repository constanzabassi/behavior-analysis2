function [sig_test] = plot_performance_all_bar(performance,save_data_directory)
overall_mean = [];
for m = 1:size(performance,2)
    overall_mean = [overall_mean,mean([performance(:,m).correct_opto])];
end

%% make the plot
figure(1111);clf;

y=rand(length(overall_mean),1)/2+.75;
h=bar([mean(overall_mean)],'FaceColor','w','EdgeColor','k','LineWidth',2)
hold on
errorbar(h(1).XEndPoints,mean(overall_mean),std(overall_mean),'LineStyle','none','Color','k','LineWidth',2)
% simple version
% scatter(y,overall_mean,60,'MarkerEdgeColor','k','LineWidth',1)

%title
title('Fraction Correct')
yticks([0:0.2:1])
xticklabels([])

%% save figures

if ~isempty(save_data_directory)
    mkdir(save_data_directory)
    cd(save_data_directory)

    image_string = strcat('bar_performance_all_',num2str(size(performance,2)));
    saveas(1111,[image_string '_datasets.svg']);
    saveas(1111,[image_string '_datasets.fig']);
    saveas(1111,[image_string '_datasets.pdf']);
end
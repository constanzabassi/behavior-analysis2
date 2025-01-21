function [output_mat, output_mat2] = get_SVM_across_datasets(info,acc,shuff_acc,plot_info,savepath,varargin)
output_mat = [];
output_mat2 = [];
for m = 1:length(info.chosen_mice)
    
figure(m);clf;

for ce = 4
     hold on;
    %title(info.mouse_date{1,m})
    
    temp1 = vertcat(acc{1,m}{1:10,1:50,ce});
    temp2 = vertcat(shuff_acc{1,m}{1:10,1:50,ce});
    output_mat{m,ce}.accuracy = temp1; %gives num subsample iterations x timepoints
    output_mat{m,ce}.shuff_accuracy = temp2;
    
    % find squared error from the mean
    SEM= std(output_mat{m,ce}.accuracy)/sqrt(size(output_mat{m,ce}.accuracy,1));
    h1(1) = shadedErrorBar(1:size(output_mat{m,ce}.accuracy,2),mean(output_mat{m,ce}.accuracy,1), SEM, 'lineProps',{'color', plot_info.colors(1,:)});

    SEM2= std(output_mat{m,ce}.shuff_accuracy)/sqrt(size(output_mat{m,ce}.shuff_accuracy,1));
    shadedErrorBar(1:size(output_mat{m,ce}.shuff_accuracy,2),mean(output_mat{m,ce}.shuff_accuracy,1), SEM2, 'lineProps',{'color', [0.2 0.2 0.2]*ce});

    if nargin > 5
        temp3 = vertcat(varargin{1,1}{1,1}{1,m}{1:10,1:50,ce});
        temp4 = vertcat(varargin{1,1}{1,2}{1,m}{1:10,1:50,ce});
        output_mat2{m,ce}.accuracy = temp3; %gives num subsample iterations x timepoints
        output_mat2{m,ce}.shuff_accuracy = temp4;

        % find squared error from the mean
        SEM= std(output_mat2{m,ce}.accuracy)/sqrt(size(output_mat2{m,ce}.accuracy,1));
        h1(2) = shadedErrorBar(1:size(output_mat2{m,ce}.accuracy,2),mean(output_mat2{m,ce}.accuracy,1), SEM, 'lineProps',{'color', plot_info.colors(2,:)});

        SEM2= std(output_mat2{m,ce}.shuff_accuracy)/sqrt(size(output_mat2{m,ce}.shuff_accuracy,1));
        shadedErrorBar(1:size(output_mat2{m,ce}.shuff_accuracy,2),mean(output_mat2{m,ce}.shuff_accuracy,1), SEM2, 'lineProps',{'color', [0.2 0.2 0.2]*ce});

    end


    if ~isempty(plot_info.minmax)
        ylim([plot_info.minmax(1) plot_info.minmax(2)])
    end
    if ~isempty(plot_info.xlims)
        xlim([plot_info.xlims(1) plot_info.xlims(2)])
    end
    for i = 1:length(plot_info.event_onsets)
        xline(plot_info.event_onsets(i),'--k','LineWidth',1.5)
        if i == 4
            xline(plot_info.event_onsets(i),'--k',{'turn onset'},'LineWidth',1.5)
        end
    end
yline(.5,'--k');
ylabel({'% Accuracy'})
legend([h1(:).mainLine], plot_info.labels,'location','northeast','Box', 'off'); 


end
hold off
set(gca, 'box', 'off')
set(gca,'fontsize', 14)
end
%save_figs
if ~isempty(savepath)
    mkdir(savepath);
    cd(savepath);
    for m = 1:length(info.chosen_mice)
        str = [info.mouse_date{1,info.chosen_mice(m)} '_' info.task_event_type];
        if ismember('/',info.mouse_date{1,info.chosen_mice(m)})
            str = erase(info.mouse_date{1,info.chosen_mice(m)},'/');
        else
            str = erase(info.mouse_date{1,info.chosen_mice(m)},'\');
        end
        saveas(m,strcat(savepath,'SVM_glm_inputs_overtime_',str,'.svg'));
        saveas(m,strcat(savepath,'SVM_glm_inputs_overtime_',str,'.png'));
    end
    save('info','info');
end

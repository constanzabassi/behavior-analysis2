function individual_cell_plots(aligned_data, cel_id, all_conditions,alignment,event_onsets)
% Number of things to plot
num_plots = length(alignment.conditions);  % Change this value based on your requirement

% Calculate the number of rows and columns for the tiled layout
rows = ceil(sqrt(num_plots));
columns = ceil(num_plots / rows);

% Create a tiled layout
tiledlayout(rows, columns);

for cel = 1:length(cel_id)
    ce = cel_id(cel);
    for c = alignment.conditions
        
        nexttile
        hold on
        title(strcat(all_conditions{c,3},' cell: ',num2str(cel_id)));
        cel_data = squeeze(aligned_data(all_conditions{c,1},ce,:)); 

        for tr  = 1:size(cel_data,1)
            plot(cel_data(tr,:),'color',[0.7 0.7 0.7] );
        end
            plot(mean(cel_data(tr,:),1),'k','LineWidth',1.2);

        for i = 1:length(event_onsets)
            xline(event_onsets(i),'--k','LineWidth',1.5)
        end
        hold off
    end
end
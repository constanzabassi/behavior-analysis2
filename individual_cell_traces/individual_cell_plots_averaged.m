function individual_cell_plots_averaged(aligned_data, cel_id, all_conditions,alignment,event_onsets)

for cel = 1:length(cel_id)
    ce = cel_id(cel);
    hold on
    for con = 1:length(alignment.conditions)
        c = alignment.conditions(con);
        
        cel_data = squeeze(aligned_data(all_conditions{c,1},ce,:)); 

        if con == 1
            plot(smooth(mean(cel_data,1),3,'boxcar'),'color',[0.5 0.5 0.5],'LineWidth',2);
%             SEM= std(cel_data)/sqrt(size(cel_data,1));
%             shadedErrorBar(1:size(cel_data,2),mean(cel_data,1), SEM, 'lineProps',{'color',[0.5 0.5 0.5]});
        else
            plot(smooth(mean(cel_data,1),3,'boxcar'),'k','LineWidth',2);
%             SEM= std(cel_data)/sqrt(size(cel_data,1));
%             shadedErrorBar(1:size(cel_data,2),mean(cel_data,1), SEM, 'lineProps',{'color','k'});
        end

        for i = 1:length(event_onsets)
            xline(event_onsets(i),'--k','LineWidth',1.5)
        end
        
    end
    set(gca, 'box', 'off', 'xtick', [],'ytick', [])
    axis off
    ylim([-0.6 2.5])
    hold off
end
function plot_frc_dynamics(max_cel_avg,all_celltypes,binss,new_onsets,plot_info, info,saveorno)
figure(55);clf;
tiledlayout(3,3)
for m = 1:size(max_cel_avg,1)
    nexttile
    
    frc=histcounts([max_cel_avg{m,:}],1:length(binss))./length(find([max_cel_avg{m,:}]));
    
    hold on;
    title(info.mouse_date(m))
    plot(frc,'LineWidth',1.5,'color',plot_info.colors_celltype(4,:)); %4 is all celltypes together
    for i = 1:length(new_onsets)
        xline(new_onsets(i),'--k','LineWidth',1.5)
    end
    ylabel({'Fraction neurons'; 'with max activity'})
    hold off
end

%%
figure(56);clf;
tiledlayout(3,3)

possible_celltypes = fieldnames(all_celltypes{1,1});

for m = 1:size(max_cel_avg,1)
    nexttile
    hold on;
    title(info.mouse_date(m))
    for ce = 1:3
        if ce < 4
            frc=histcounts([max_cel_avg{m,all_celltypes{1,m}.(possible_celltypes{ce})}],1:length(binss))./length(find([max_cel_avg{m,all_celltypes{1,m}.(possible_celltypes{ce})}]));
        else
            frc=histcounts([max_cel_avg{m,:}],1:length(binss))./length(find([max_cel_avg{m,:}]));
        end
          
        plot(frc,'LineWidth',1.5,'color',plot_info.colors_celltype(ce,:));

        for i = 1:length(new_onsets)
            xline(new_onsets(i),'--k','LineWidth',1.5)
        end
        
    end
    ylabel({'Fraction neurons'; 'with max activity'})
    hold off
end

if saveorno == 1
    mkdir([info.savepath '\frc_dynamics'])
    cd([info.savepath '\frc_dynamics'])
    max_cel_mode = max_cel_avg;
    save('max_cel_mode','max_cel_mode');
    
    %save_figs
    saveas(55,strcat('frc_dynamics_all.svg'));
    saveas(55,strcat('frc_dynamics_all.png'));
    
    saveas(56,strcat('frc_dynamics_separated.svg'));
    saveas(56,strcat('frc_dynamics_separated.svg'));
end


% for m = 1:length(imaging_st)
%     str = info.mouse_date{1,m} ;
%     if ismember('/',info.mouse_date{1,m})
%         str = erase(info.mouse_date{1,m},'/');
%     else
%         str = erase(info.mouse_date{1,m},'\');
%     end
%     saveas(m,strcat('SVM_overtime_',str,'.svg'));
%     saveas(m,strcat('SVM_overtime_',str,'.png'));
% end
function plot_ct_event(pyr_mean_activity,som_mean_activity,pv_mean_activity,save_yn)

frames=size(pyr_mean_activity,3); 
num_ds=size(pyr_mean_activity,1); 

%%  PYR ACTIVITY DURING EVENTS
figure(99)
hold on 
set(gcf,'color','w')

% Pyr during SOM 
x = linspace(1,frames,frames)'; 
y = squeeze(nanmean(pyr_mean_activity(:,1,:)));
dy = squeeze(nanstd(pyr_mean_activity(:,1,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 1 .8],'linestyle','none');
line(x,y,'Color','g','LineStyle','--')
[~,maxpoint]=max(y)
xline(maxpoint,'Color','c','HandleVisibility','off')

% Pyr during PV
x = linspace(1,frames,frames)';
y = squeeze(nanmean(pyr_mean_activity(:,2,:)));
dy = squeeze(nanstd(pyr_mean_activity(:,2,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 1 .8],'linestyle','none');
line(x,y,'Color','g')
[~,maxpoint]=max(y)
xline(maxpoint,'Color','m','HandleVisibility','off')

legend({'','SOM events','','PV events'},'location','northwest')
ylabel('Pyramidal Population Activity')
xlabel('Time from Event (s)')

set(gca,'xtick',1:60:frames)
set(gca,'xticklabel',-4:2:2)

yl = ylim;
xline(121,'--k','HandleVisibility','off')
axis square
set(gca,'fontsize',14)
title('Pyramidal Population Activity During SOM and PV Events')


%% PV ACTIVITY DURING EVENTS 
figure(100)
clf
set(gcf,'color','w')
hold on
% PV during SOM 
x = linspace(1,frames,frames)';
y = squeeze(nanmean(pv_mean_activity(:,1,:)));
dy = squeeze(nanstd(pv_mean_activity(:,1,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[1 .8 .8],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','r','LineStyle','--')
[~,maxpoint]=max(y);
xline(maxpoint,'Color','c','HandleVisibility','off')


% PV during PV 
x = linspace(1,frames,frames)';
y = squeeze(nanmean(pv_mean_activity(:,2,:)));
dy = squeeze(nanstd(pv_mean_activity(:,2,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[1 .8 .8],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','Red')
[~,maxpoint]=max(y);
xline(maxpoint,'Color','m','HandleVisibility','off')

%--- PLOT 
legend({'SOM events','PV events'},'location','northwest')
ylabel('PV Population Activity')
xlabel('Time from Event (s)')
set(gca,'xtick',1:60:frames)
set(gca,'xticklabel',-4:2:2)
yl = ylim;
xline(121,'--k','HandleVisibility','off')
axis square
set(gca,'fontsize',14)
title('PV Population Activity During SOM and PV Events')

%% SOM ACTIVITY DURING EVENTS 
figure(101)
clf
set(gcf,'color','w')
%SOM during SOM 
x = linspace(1,frames,frames)';
y = squeeze(nanmean(som_mean_activity(:,1,:)));
dy = squeeze(nanstd(som_mean_activity(:,1,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 .8 1],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','Blue','LineStyle','--')
hold on
[~,maxpoint]=max(y);
xline(maxpoint,'Color','c','HandleVisibility','off')

% SOM during PV 
x = linspace(1,frames,frames)';
y = squeeze(nanmean(som_mean_activity(:,2,:)));
dy = squeeze(nanstd(som_mean_activity(:,2,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 .8 1],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','b')
[~,maxpoint]=max(y);
xline(maxpoint,'Color','m','HandleVisibility','off')

legend({'SOM events','PV events'},'location','northwest')
ylabel('SOM Population activity')
xlabel('Time from Event (s)')
set(gca,'xtick',1:60:frames)
set(gca,'xticklabel',-4:2:2)
yl = ylim;
xline(121,'--k','HandleVisibility','off')
axis square
set(gca,'fontsize',14)
title('SOM Population Activity During SOM and PV Events')


%% SAVE

if strcmp(save_yn,'save')
    saveas(99,'Pyr Population Activity During SOM and PV Events','pdf')
    saveas(99,'Pyr Population Activity During SOM and PV Events','fig')

    saveas(100,'PV Population Activity During SOM and PV Events','pdf')
    saveas(100,'PV Population Activity During SOM and PV Events','fig')

    saveas(101,'SOM Population Activity During SOM and PV Events','pdf')
    saveas(101,'SOM Population Activity During SOM and PV Events','fig')
end

%% 



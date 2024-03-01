function[SOMe,PVe,MIXe]= plot_allct_event(pyr_mean_activity,som_mean_activity,pv_mean_activity,save_yn)

frames=size(pyr_mean_activity,3); 
num_ds=size(pyr_mean_activity,1); 
med= median(1:frames);
scaled_start=med-15; 
scaled_end= med+45; 


%% ALL ACTIVITY DURING SOM EVENTS 
figure(102)
clf
set(gcf,'color','w')
% SOM ----
x = linspace(1,frames,frames)';
y = squeeze(nanmean(som_mean_activity(:,1,:)));
dy = squeeze(nanstd(som_mean_activity(:,1,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 .8 1],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','Blue','LineStyle','--')
hold on
% PV ----
x = linspace(1,frames,frames)';
y = squeeze(nanmean(pv_mean_activity(:,1,:)));
dy = squeeze(nanstd(pv_mean_activity(:,1,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[1 .8 .8],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','Red')
% PYR ----
x = linspace(1,frames,frames)';
y = squeeze(nanmean(pyr_mean_activity(:,1,:)));
dy = squeeze(nanstd(pyr_mean_activity(:,1,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 1 .8],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','Green')

% PLOT 
legend({'SOM activity','PV activity','Pyr activity'},'location','northwest')
ylabel('Population activity')
xlabel('Time from SOM event (s)')
set(gca,'xtick',1:60:frames)
set(gca,'xticklabel',-4:2:2)
yl = ylim;
plot([121 121],yl,'--k','HandleVisibility','off')

set(gca,'fontsize',14)
title('SOM PV and Pyr Population Activity During SOM Events')
axis([0 241 -1 2.5])
axis square

%% ALL ACTIVITIES DURING PV EVENTS
figure(103)
clf
set(gcf,'color','w')
x = linspace(1,frames,frames)';
y = squeeze(nanmean(som_mean_activity(:,2,:)));
dy = squeeze(nanstd(som_mean_activity(:,2,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 .8 1],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','Blue')
hold on
x = linspace(1,frames,frames)';
y = squeeze(nanmean(pv_mean_activity(:,2,:)));
dy = squeeze(nanstd(pv_mean_activity(:,2,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[1 .8 .8],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','Red')
x = linspace(1,241,241)';
y = squeeze(nanmean(pyr_mean_activity(:,2,:)));
dy = squeeze(nanstd(pyr_mean_activity(:,2,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 1 .8],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','Green')
legend({'SOM activity','PV activity','Pyr activity'},'location','northwest')
ylabel('Population activity')
xlabel('Time from PV event (s)')
set(gca,'xtick',1:60:frames)
set(gca,'xticklabel',-4:2:2)
%yl = ylim;
plot([121 121],yl,'--k','HandleVisibility','off')

axis square
axis([0 241 -1 2.5])
set(gca,'fontsize',14)
title('SOM PV and Pyr Population Activity During PV Events')

%% ALL ACTIVITIES DURING MIXED EVENTS
figure(55)
clf
set(gcf,'color','w')
x = linspace(1,frames,frames)';
y = squeeze(nanmean(som_mean_activity(:,3,:)));
dy = squeeze(nanstd(som_mean_activity(:,3,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 .8 1],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','Blue')
hold on
x = linspace(1,frames,frames)';
y = squeeze(nanmean(pv_mean_activity(:,3,:)));
dy = squeeze(nanstd(pv_mean_activity(:,3,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[1 .8 .8],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','Red')
x = linspace(1,241,241)';
y = squeeze(nanmean(pyr_mean_activity(:,3,:)));
dy = squeeze(nanstd(pyr_mean_activity(:,3,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 1 .8],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','Green')
legend({'SOM activity','PV activity','Pyr activity'},'location','northwest')
ylabel('Population activity')
xlabel('Time from PV event (s)')
set(gca,'xtick',1:60:frames)
set(gca,'xticklabel',-4:2:2)
%yl = ylim;
plot([121 121],yl,'--k','HandleVisibility','off')

axis square
axis([0 241 -1 2.5])
set(gca,'fontsize',14)
title('SOM PV and Pyr Population Activity During Mixed Events')

%% SCALED ACTIVITIES DURING SOM EVENTS 
figure(104)
clf
set(gcf,'color','w')
% SOM-----
x=linspace(1,scaled_end-scaled_start,scaled_end-scaled_start+1)';
y = squeeze(nanmean(som_mean_activity(:,1,scaled_start:scaled_end)));
%y = y./max(y);
%y=zscore(y); 
y=(y-min(y))/ (max(y)-min(y)); 

dy = squeeze(nanstd(som_mean_activity(:,1,scaled_start:scaled_end)))./sqrt(num_ds).*max(y);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 .8 1],'linestyle','none','HandleVisibility','off','FaceAlpha',.5);
line(x,y,'Color','Blue')
hold on
SOMe(1,:,:)=som_mean_activity(:,1,scaled_start:scaled_end); 

% PV------
x=linspace(1,scaled_end-scaled_start,scaled_end-scaled_start+1)';
y = squeeze(nanmean(pv_mean_activity(:,1,scaled_start:scaled_end)));
%y = y./max(y);
%y=zscore(y); 
y=(y-min(y))/ (max(y)-min(y)); 
dy = squeeze(nanstd(pv_mean_activity(:,1,scaled_start:scaled_end)))./sqrt(num_ds).*max(y);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[1 .8 .8],'linestyle','none','HandleVisibility','off','FaceAlpha',.5);
line(x,y,'Color','Red','LineStyle','--')
SOMe(2,:,:)=pv_mean_activity(:,1,scaled_start:scaled_end); 

% PYR-----
x=linspace(1,scaled_end-scaled_start,scaled_end-scaled_start+1)';
y = squeeze(nanmean(pyr_mean_activity(:,1,scaled_start:scaled_end)));
%y = y./max(y);
%y=zscore(y); 
y=(y-min(y))/ (max(y)-min(y)); 
dy = squeeze(nanstd(pyr_mean_activity(:,1,scaled_start:scaled_end)))./sqrt(num_ds).*max(y);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 1 .8],'linestyle','none','HandleVisibility','off','FaceAlpha',.5);
line(x,y,'Color','Green','LineStyle','--')

SOMe(3,:,:)=pyr_mean_activity(:,1,scaled_start:scaled_end); 

% PLOT----
legend({'SOM activity','PV activity','Pyr activity'},'location','northwest')
ylabel('Normalized Population activity')
xlabel('Time from SOM event (s)')
set(gca,'xtick',1:15:scaled_end-scaled_start+1)
set(gca,'xticklabel',-.5:.5:1)
yl = ylim;
%plot([61 61],yl,'--k','HandleVisibility','off')
axis square
set(gca,'fontsize',14)
title('SOM PV and Pyr Population Activity During SOM Events (Scaled)')

%% SCALED ACTIVITIES DURING PV EVENTS 

figure(105)
clf
set(gcf,'color','w')

% SOM-----
x=linspace(1,scaled_end-scaled_start,scaled_end-scaled_start+1)';
y = squeeze(nanmean(som_mean_activity(:,2,scaled_start:scaled_end)));
%y = y./max(y);
%y=zscore(y); 
y=(y-min(y))/ (max(y)-min(y)); 
dy = squeeze(nanstd(som_mean_activity(:,2,scaled_start:scaled_end)))./sqrt(num_ds).*max(y);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 .8 1],'linestyle','none','HandleVisibility','off','FaceAlpha',.5);
line(x,y,'Color','Blue')
hold on
PVe(1,:,:)=som_mean_activity(:,2,scaled_start:scaled_end); 
% PV------
x=linspace(1,scaled_end-scaled_start,scaled_end-scaled_start+1)';
y = squeeze(nanmean(pv_mean_activity(:,2,scaled_start:scaled_end)));
%y = y./max(y);
%y=zscore(y); 
y=(y-min(y))/ (max(y)-min(y)); 
dy = squeeze(nanstd(pv_mean_activity(:,2,scaled_start:scaled_end)))./sqrt(num_ds).*max(y);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[1 .8 .8],'linestyle','none','HandleVisibility','off','FaceAlpha',.5);
line(x,y,'Color','Red')
PVe(2,:,:)=pv_mean_activity(:,2,scaled_start:scaled_end); 
% PYR-----
x=linspace(1,scaled_end-scaled_start,scaled_end-scaled_start+1)';
y = squeeze(nanmean(pyr_mean_activity(:,2,scaled_start:scaled_end)));
%y = y./max(y);
%y=zscore(y); 
y=(y-min(y))/ (max(y)-min(y)); 
dy = squeeze(nanstd(pyr_mean_activity(:,2,scaled_start:scaled_end)))./sqrt(num_ds).*max(y);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 1 .8],'linestyle','none','HandleVisibility','off','FaceAlpha',.5);
line(x,y,'Color','Green')
PVe(3,:,:)=pyr_mean_activity(:,2,scaled_start:scaled_end); 

% PLOT------
legend({'SOM activity','PV activity','Pyr activity'},'location','northwest')
ylabel('Normalized Population activity')
xlabel('Time from PV event (s)')
set(gca,'xtick',1:15:scaled_end-scaled_start+1)
set(gca,'xticklabel',-.5:.5:1)
yl = ylim;
%plot([61 61],yl,'--k','HandleVisibility','off')
axis square
set(gca,'fontsize',14)
title('SOM PV and Pyr Population Activity During PV Events (Scaled)')

%% SCALED ACTIVITIES DURING MIXED EVENTS
figure(106)
clf
set(gcf,'color','w')

% SOM-----
x=linspace(1,scaled_end-scaled_start,scaled_end-scaled_start+1)';
y = squeeze(nanmean(som_mean_activity(:,3,scaled_start:scaled_end)));
%y = y./max(y);
%y=zscore(y); 
y=(y-min(y))/ (max(y)-min(y)); 
dy = squeeze(nanstd(som_mean_activity(:,3,scaled_start:scaled_end)))./sqrt(num_ds).*max(y);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 .8 1],'linestyle','none','HandleVisibility','off','FaceAlpha',.5);
line(x,y,'Color','Blue')
hold on
MIXe(1,:,:)=som_mean_activity(:,3,scaled_start:scaled_end); 


% PV------
x=linspace(1,scaled_end-scaled_start,scaled_end-scaled_start+1)';
y = squeeze(nanmean(pv_mean_activity(:,3,scaled_start:scaled_end)));
%y = y./max(y);
%y=zscore(y); 
y=(y-min(y))/ (max(y)-min(y)); 
dy = squeeze(nanstd(pv_mean_activity(:,3,scaled_start:scaled_end)))./sqrt(num_ds).*max(y);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[1 .8 .8],'linestyle','none','HandleVisibility','off','FaceAlpha',.5);
line(x,y,'Color','Red')
MIXe(2,:,:)=pv_mean_activity(:,3,scaled_start:scaled_end); 



% PYR-----
x=linspace(1,scaled_end-scaled_start,scaled_end-scaled_start+1)';
y = squeeze(nanmean(pyr_mean_activity(:,3,scaled_start:scaled_end)));
%y = y./max(y);
%y=zscore(y); 
y=(y-min(y))/ (max(y)-min(y)); 
dy = squeeze(nanstd(pyr_mean_activity(:,3,scaled_start:scaled_end)))./sqrt(num_ds).*max(y);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 1 .8],'linestyle','none','HandleVisibility','off','FaceAlpha',.5);
line(x,y,'Color','Green')
MIXe(3,:,:)=pyr_mean_activity(:,3,scaled_start:scaled_end); 

% PLOT------
legend({'SOM activity','PV activity','Pyr activity'},'location','northwest')
ylabel('Normalized Population activity')
xlabel('Time from PV event (s)')
set(gca,'xtick',1:15:scaled_end-scaled_start+1)
set(gca,'xticklabel',-.5:.5:1)
yl = ylim;
%plot([61 61],yl,'--k','HandleVisibility','off')
axis square
set(gca,'fontsize',14)
title('SOM PV and Pyr Population Activity During Mixed Events (Scaled)')


%% SAVE

if strcmp(save_yn,'save')
    saveas(102,'SOM PV Pyr Population Activity During SOM Events','pdf')
    saveas(102,'SOM PV Pyr Population Activity During SOM Events','fig')
    
    saveas(103,'SOM PV Pyr Population Activity During PV Events','pdf')
    saveas(103,'SOM PV Pyr Population Activity During PV Events','fig')
    
    saveas(104,'SOM PV Pyr Population Activity During SOM Events Scaled','pdf')
    saveas(104,'SOM PV Pyr Population Activity During SOM Events Scaled','fig')

    saveas(105,'SOM PV Pyr Population Activity During PV Events Scaled','pdf')
    saveas(105,'SOM PV Pyr Population Activity During PV Events Scaled','fig')

end

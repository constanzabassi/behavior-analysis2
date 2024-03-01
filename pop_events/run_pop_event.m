%% RUN EVENT IDENTIFICATION!
popevent_params.peaks = [1,90,2,300,10]; %'MinPeakHeight',cp(1),'MinPeakDistance',cp(2),'MinPeakProminence',cp(3),'MaxPeakWidth',cp(4),'MinPeakWidth',cp(5));
%[1,2,10];%'MinPeakHeight',cp(1),'MinPeakProminence',cp(2),'MinPeakWidth',cp(3));
popevent_params.activity_type ='dff_avg';

ds_events = get_ds_events(info,mouse,all_celltypes,popevent_params.peaks,popevent_params.activity_type);

%% GET MEAN ACTIVITY BY EVENTS
% divided into ds x condition x time matrices 
event_frame = 120;
[pyr_mean_activity,som_mean_activity,pv_mean_activity,velo,ds_speed_xc] = get_mean_activity(info,ds_events,mouse,all_celltypes,event_frame,2); 
%% PLOT ACTIVITY OF EACH CELL TYPE FOR EACH EVENT
plot_ct_event(pyr_mean_activity,som_mean_activity,pv_mean_activity,'nosave')

%% PLOT ACTIVITY OF ALL CELL TYPES DURING EVENTS
plot_allct_event(pyr_mean_activity,som_mean_activity,pv_mean_activity,'nosave')
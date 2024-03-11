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
%% DETERMINE ONSET OF EVENTS RELATIVE TO TRIAL EVENTS!
% all_frames from all_frames = frames_relative2general(info,imaging_st)
load([info.savepath '/data_info/all_frames.mat']);
%[event_sums,cat_array, ~] = get_event_relative2task(all_frames,ds_events); %rough alignment (only using frames in maze, reward or ITI
[event_sums,cat_array, ~] = get_event_relative2task_updated (all_frames,imaging_st,ds_events);

load([info.savepath '/data_info/plot_info.mat']);
[event_stats] = errorbar_events2task(event_sums,plot_info,[info.savepath '/pop_event']);

figure(334);clf;
subplot(2,1,1);title('SOM events');imagesc(event_sums.som);ylabel('Datasets');xticks([1:4]);xticklabels({'Stim','Turn','Reward','ITI'});
subplot(2,1,2);title('PV events');imagesc(event_sums.pv);ylabel('Datasets');xticks([1:4]);xticklabels({'Stim','Turn','Reward','ITI'});
saveas(334,'event_sums_across_datasets.png')


base = 'X:\Potter et al datasets\';

conditions = {'SOM', 'PV'};
% MAKE SO THAT THERE IS EXCLUSION CRITERION FOR SOM AND PV EVENTS
% what is events_per_min supposed to be about? 

event_frame = 120;
load('Y:\Christian\Processed Data\Event Analysis\standard_ds_onsets.mat')


%% GET MEAN ACTIVITY BY EVENTS
% divided into ds x condition x time matrices 

[pyr_mean_activity,som_mean_activity,pv_mean_activity,velo,ds_speed_xc] = get_mean_activity(base,ds_events,event_frame,2); 
%% PLOT ACTIVITY OF EACH CELL TYPE FOR EACH EVENT
plot_ct_event(pyr_mean_activity,som_mean_activity,pv_mean_activity,'nosave')

%% PLOT ACTIVITY OF ALL CELL TYPES DURING EVENTS
plot_allct_event(pyr_mean_activity,som_mean_activity,pv_mean_activity,'nosave')

%%  PLOT MEAN VELOCITY DURING CHANGES

plot_velocity_event(velo,ds_speed_xc,ds_events,' Acceleration','nosave')
%add condition to look at deltaV

%% STATISTICS

% % [p, observeddifference, effectsize] = permutationTest(sample1, sample2, permutations [, varargin])
% %%first comparing the activity of each population across the 2 event types
% [SOM_peak_activity,SOM_peak_activity_time] = max(squeeze(mean(som_mean_activity(:,1,:))));
% [p, observeddifference, effectsize] = permutationTest(squeeze(som_mean_activity(:,1,SOM_peak_activity_time)), squeeze(som_mean_activity(:,2,SOM_peak_activity_time)), 1000)
% [p, observeddifference, effectsize] = permutationTest(squeeze(pv_mean_activity(:,1,SOM_peak_activity_time)), squeeze(pv_mean_activity(:,2,SOM_peak_activity_time)), 1000)
% [p, observeddifference, effectsize] = permutationTest(squeeze(pyr_mean_activity(:,1,SOM_peak_activity_time)), squeeze(pyr_mean_activity(:,2,SOM_peak_activity_time)), 1000)
% 
% [PV_peak_activity,PV_peak_activity_time] = max(squeeze(mean(pv_mean_activity(:,2,:))));
% [p, observeddifference, effectsize] = permutationTest(squeeze(som_mean_activity(:,1,PV_peak_activity_time)), squeeze(som_mean_activity(:,2,PV_peak_activity_time)), 1000)
% [p, observeddifference, effectsize] = permutationTest(squeeze(pv_mean_activity(:,1,PV_peak_activity_time)), squeeze(pv_mean_activity(:,2,PV_peak_activity_time)), 1000)
% [p, observeddifference, effectsize] = permutationTest(squeeze(pyr_mean_activity(:,1,PV_peak_activity_time)), squeeze(pyr_mean_activity(:,2,PV_peak_activity_time)), 1000)
% 
% %%next compare the activity of each population before and after event onset
% [p, observeddifference, effectsize] = permutationTest(squeeze(som_mean_activity(:,1,SOM_peak_activity_time)), squeeze(som_mean_activity(:,1,1)), 1000)
% [p, observeddifference, effectsize] = permutationTest(squeeze(pv_mean_activity(:,1,SOM_peak_activity_time)), squeeze(pv_mean_activity(:,1,1)), 1000)
% [p, observeddifference, effectsize] = permutationTest(squeeze(pyr_mean_activity(:,1,SOM_peak_activity_time)), squeeze(pyr_mean_activity(:,1,1)), 1000)
% 
% 
% %%next compare the activity of each population before and after event onset
% [p, observeddifference, effectsize] = permutationTest(squeeze(som_mean_activity(:,2,PV_peak_activity_time)), squeeze(som_mean_activity(:,2,1)), 1000)
% [p, observeddifference, effectsize] = permutationTest(squeeze(pv_mean_activity(:,2,PV_peak_activity_time)), squeeze(pv_mean_activity(:,2,1)), 1000)
% [p, observeddifference, effectsize] = permutationTest(squeeze(pyr_mean_activity(:,2,PV_peak_activity_time)), squeeze(pyr_mean_activity(:,2,1)), 1000)

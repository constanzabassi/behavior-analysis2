%% make preliminary plots of data!
% put code into path
selected_folder = uigetdir;
addpath(genpath(selected_folder))
%%
%1) plot example trial first
ex_trial = 66;
data = imaging(ex_trial).z_dff;

min_max = [-0.5 2];
sorting_type = 1; %1 by time, any other number by max value
figure(1);clf;
hold on
make_heatmap(data,min_max,sorting_type);
plot(rescale(imaging(ex_trial).movement_in_imaging_time.stimulus,0,size(data,1)),'-w');
hold off

%% 2) make avg plots of all data aligned to specific events (stimulus, turn,reward)

%make plots based on conditions align based on onset first 
%1) align data (trials,cells,frames)
[aligned_stimulus,imaging_array,align_info] = align_behavior_data (imaging,'z_dff','stimulus');
[aligned_turn,imaging_array,align_info] = align_behavior_data (imaging,'z_dff','turn');
[aligned_reward,imaging_array,align_info] = align_behavior_data (imaging,'z_dff','reward');

figure(2);clf;
tiledlayout(1,4,"TileSpacing",'compact')
nexttile
hold on
title('first stimulus onset')
make_heatmap(squeeze(mean(aligned_stimulus,1)),min_max,sorting_type,align_info.stim_onset);
hold off

nexttile
hold on
title('turn onset')
make_heatmap(squeeze(mean(aligned_turn,1)),min_max,sorting_type,align_info.turn_onset);
hold off

nexttile
hold on
title('reward onset')
make_heatmap(squeeze(mean(aligned_reward,1)),min_max,sorting_type,align_info.reward_onset);
hold off

nexttile
hold on
title('stimulus and turn onsets')
make_heatmap([squeeze(mean(aligned_stimulus,1)),squeeze(mean(aligned_turn,1))],min_max,sorting_type,align_info.stim_onset,align_info.min_length+align_info.reward_onset);
hold off

%% 3) divide data into correct/incorrect, left/right, stim/no stim
[all_conditions, condition_array_trials] = divide_trials (imaging);
imaging_conditions = align_data_per_condition(imaging,all_conditions,'z_dff','reward');
make_condition_heatmaps (imaging_conditions,min_max,sorting_type,all_conditions); %plot mean for each condition


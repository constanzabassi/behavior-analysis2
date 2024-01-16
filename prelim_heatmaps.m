%% make preliminary plots of data!
% put code into path
selected_folder = uigetdir;
addpath(genpath(selected_folder))
%%
%1) plot example trial first
ex_trial = 197;
data = imaging(ex_trial).z_dff;

plot_info.min_max = [-0.5 2];
plot_info.sorting_type = 1; %1 by time, any other number by max value
plot_info.xlabel = 'Frames';
plot_info.ylabel = 'Neurons';

figure(1);clf;
hold on
title(['Example trial: ' num2str(ex_trial)])
make_heatmap(data,plot_info,1);
plot(rescale(imaging(ex_trial).movement_in_imaging_time.stimulus,0,size(data,1)),'-w');
plot(rescale(imaging(ex_trial).movement_in_imaging_time.is_reward,0,size(data,1)),'-r');
plot(rescale(imaging(ex_trial).movement_in_imaging_time.in_ITI,0,size(data,1)),'-g');
plot(rescale(imaging(ex_trial).movement_in_imaging_time.pure_tones,0,size(data,1)),'-g');
plot(rescale(imaging(ex_trial).movement_in_imaging_time.y_position,0,size(data,1)),'-m');
ylabel('Neurons')
xlabel('Frames')
hold off

%% 2) make avg plots of all data aligned to specific events (stimulus, turn,reward)

%make plots based on conditions align based on onset first 
%1) align data (trials,cells,frames)
alignment.data_type = 'z_dff';
align_info = find_align_info(imaging,30); %find min # of frames per event
alignment.type = 'stimulus';
[aligned_stimulus,imaging_array,align_info] = align_behavior_data_prelim (imaging,align_info,alignment);
alignment.type = 'turn';
[aligned_turn,imaging_array,align_info] = align_behavior_data_prelim (imaging,align_info,alignment);
alignment.type = 'reward';
[aligned_reward,imaging_array,align_info] = align_behavior_data_prelim (imaging,align_info,alignment);

figure(2);clf;
tiledlayout(1,4,"TileSpacing",'compact')
nexttile
hold on
title('first stimulus onset')
make_heatmap(squeeze(mean(aligned_stimulus,1)),plot_info,align_info.stimulus_onset,align_info.stimulus_onset);
hold off

nexttile
hold on
title('turn onset')
make_heatmap(squeeze(mean(aligned_turn,1)),plot_info,align_info.turn_onset,align_info.turn_onset);
hold off

nexttile
hold on
title('reward onset')
make_heatmap(squeeze(mean(aligned_reward,1)),plot_info,align_info.reward_onset,align_info.reward_onset);
hold off

nexttile
hold on
title('stimulus and turn onsets')
make_heatmap([squeeze(mean(aligned_stimulus,1)),NaN(size(aligned_stimulus,2),3),squeeze(mean(aligned_turn,1))],plot_info,align_info.stimulus_onset,align_info.stimulus_onset,align_info.min_length+align_info.turn_onset+3); %+ length of maze and +3 for NaN
hold off

%% 3) divide data into correct/incorrect, left/right, stim/no stim and plot the mean
[all_conditions, condition_array_trials] = divide_trials (imaging);
alignment.type = 'stimulus'; %'reward','turn','stimulus'
imaging_conditions = align_data_per_condition(imaging,all_conditions,alignment,[]);

figure(4);clf;
make_condition_heatmaps (imaging_conditions,plot_info,all_conditions,alignment,[]); %plot mean for each condition


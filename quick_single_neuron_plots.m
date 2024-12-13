
ex_m = 4;
ex_imaging = imaging_st{1,ex_m };
alignment.data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'

[align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
[aligned_imaging,imaging_array,align_info] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
event_onsets = determine_onsets(left_padding,right_padding,[1:6]);
[all_conditions, condition_array_trials] = divide_trials (ex_imaging); %divide trials into all possible conditions

%%
%  'HA2-1L_2023-05-05': {'pyr': [119, 80, 199, 156, 26],
%   'som': [2, 5, 10, 13, 6],
%   'pv': [10, 0, 7, 8, 1]},
informative_neurons = [105, 2, 9, 338, 182]+1;
neuron_to_plot = all_celltypes{1, ex_m }.pyr_cells(informative_neurons(4)); %pyr 106
figure(88);clf;
subplot(1,2,1)
title('Left Correct trials')
%left correct trials opto and control
hold on
imagesc(squeeze(aligned_imaging([all_conditions{5,1}],neuron_to_plot,:)));
for i = 1:length(event_onsets)
    xline(event_onsets(i),'-w','LineWidth',1.5)
end

set_current_fig;
subplot(1,2,2)
title('Right Correct trials')
hold on
imagesc(squeeze(aligned_imaging([all_conditions{7,1}],neuron_to_plot,:)));
for i = 1:length(event_onsets)
    xline(event_onsets(i),'-w','LineWidth',1.5)
end
hold off
set_current_fig;

% make_heatmap(squeeze(mean(aligned_imaging)),plot_info,event_onsets(1),event_onsets);

%% passive
%passive_st = load('V:\Connie\results\passive\data_info\imaging_st.mat').imaging_st;
alignment.type = 'stimulus';
mdl_param.field_to_predict = [3,4];
ex_imaging_passive = passive{1,ex_m };
[align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging_passive,30,2);
[passive_data,~,~] = align_behavior_data (ex_imaging_passive,align_info,alignment_frames,left_padding,right_padding,alignment); % sample_data is n_trials x n_cells x n_frames
event_onsets = determine_onsets(left_padding,right_padding,[1:3]);
%get trials

fieldss = fieldnames(ex_imaging(1).virmen_trial_info);
[~, condition_array] = divide_trials_updated (ex_imaging_passive,{fieldss{mdl_param.field_to_predict}});

%left trials
left_tr = find(condition_array(:,2) ==1 & condition_array(:,3) ==0);
right_tr = find(condition_array(:,2) ==0 & condition_array(:,3) ==0);
%%

%
%  'HA2-1L_2023-05-05': {'pyr': [119, 80, 199, 156, 26],
%   'som': [2, 5, 10, 13, 6],
%   'pv': [10, 0, 7, 8, 1]},
neuron_to_plot = all_celltypes{1, ex_m }.pyr_cells(81); 

figure(88);clf;
subplot(1,2,1)
title('Left Correct trials')
%left correct trials opto and control
hold on
imagesc(squeeze(aligned_imaging([all_conditions{5,1}],neuron_to_plot,:)));
for i = 1:length(event_onsets)
    xline(event_onsets(i),'-w','LineWidth',1.5)
end

set_current_fig;
subplot(1,2,2)
title('Right Correct trials')
hold on
imagesc(squeeze(aligned_imaging([all_conditions{7,1}],neuron_to_plot,:)));
for i = 1:length(event_onsets)
    xline(event_onsets(i),'-w','LineWidth',1.5)
end
hold off
set_current_fig;


figure(89);clf;
subplot(1,2,1)
title('Left trials passive')
%left correct trials opto and control
hold on
imagesc(squeeze(passive_data([left_tr],neuron_to_plot,:)));
for i = 1:length(event_onsets)
    xline(event_onsets(i),'-w','LineWidth',1.5)
end

set_current_fig;
subplot(1,2,2)
title('Right trials passive')
hold on
imagesc(squeeze(passive_data([right_tr],neuron_to_plot,:)));
for i = 1:length(event_onsets)
    xline(event_onsets(i),'-w','LineWidth',1.5)
end
hold off
set_current_fig;
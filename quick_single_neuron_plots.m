load('V:\Connie\results\behavior_updated\data_info\info.mat')
load('V:\Connie\results\behavior_updated\data_info\plot_info.mat')
load('V:\Connie\results\behavior_updated\data_info\task_info.mat')
load('V:\Connie\results\behavior_updated\data_info\all_celltypes.mat')
load('V:\Connie\results\behavior_updated\data_info\all_frames.mat')
load('V:\Connie\results\behavior_updated\data_info\imaging_st.mat')
%%
% sig = load('V:\Connie\results\glm_decoding\prelim\passive\significant_neurons_data.mat'); %none
sig = load('V:\Connie\results\glm_decoding\prelim\passive\significant_neurons_data.mat'); %0.1
%%
ex_m = 1;
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
informative_neurons = [42,  51,  75,  77,  78,  79,  98, 126, 149, 203, 226, 237, 244,248, 258, 300, 304, 307, 318, 323]+1;
neuron_to_plot = all_celltypes{1, ex_m }.pyr_cells(informative_neurons(1)); %pyr 106
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
passive_st = load('V:\Connie\results\passive\data_info\imaging_st.mat').imaging_st;
alignment.type = 'stimulus';
mdl_param.field_to_predict = [3,4];
ex_imaging_passive = passive_st{1,ex_m };
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
cell_ex = 11;
%sort by peaks
% top = [1, 13, 14, 18, 25, 26, 31, 34, 37, 42, 49, 56, 62, 65, 76, 77, 79, 80, 82, 87, 88, 90, 92, 98, 103, 108, 111, 112, 127, 141, 146, 165, 172, 181, 191, 193, 198, 203, 214, 215, 226, 227, 229, 232, 237, 244, 257, 260, 261, 263, 268, 271, 287, 294, 295, 300, 305, 314, 315, 318, 326];
% [a,b] = sort(top)
% cell_ex = b(end-3);
% informative_neurons = sig.HA11_1R_2023_05_05.pyr.indices;
neuron_to_plot = all_celltypes{1, ex_m }.pyr_cells(informative_neurons(cell_ex)); %pyr 106
informative_neurons = [42,  51,  75,  77,  78,  79,  98, 126, 149, 203, 226, 237, 244,248, 258, 300, 304, 307, 318, 323]+1;
informative_peaks = [0.06093128 0.06288881 0.0602526  0.06305552 0.06261113 0.06077094 0.07970873 0.07410653 0.06040351 0.10620771 0.10361535 0.0639753 0.09420181 0.07870833 0.09098404 0.06936493 0.07426267 0.09156709 0.0780108  0.06940708];
%%
cell_ex = 1;
informative_neurons = [5];
informative_peaks = 0.06710303;
neuron_to_plot = all_celltypes{1, ex_m }.som_cells(informative_neurons(cell_ex)); %pyr 106

%%
%print(num2str(sig.HA11_1R_2023_05_05.pyr.peaks(cell_ex)))
% neuron_to_plot = all_celltypes{1, ex_m }.pyr_cells(81); 

figure(88);clf;
sgtitle(informative_peaks(cell_ex))
subplot(2,2,1)
title('Left Correct trials')
%left correct trials opto and control
hold on
imagesc(squeeze(aligned_imaging([all_conditions{5,1}],neuron_to_plot,:)));
for i = 1:length(event_onsets)
    xline(event_onsets(i),'-w','LineWidth',1.5)
end

set_current_fig;
subplot(2,2,2)
title('Right Correct trials')
hold on
imagesc(squeeze(aligned_imaging([all_conditions{7,1}],neuron_to_plot,:)));
for i = 1:length(event_onsets)
    xline(event_onsets(i),'-w','LineWidth',1.5)
end
hold off
set_current_fig;


%figure(89);clf;
subplot(2,2,3)
title('Left trials passive')
%left correct trials opto and control
hold on
imagesc(squeeze(passive_data([left_tr],neuron_to_plot,:)));
for i = 1:length(event_onsets)
    xline(event_onsets(i),'-w','LineWidth',1.5)
end

set_current_fig;
subplot(2,2,4)
title('Right trials passive')
hold on
imagesc(squeeze(passive_data([right_tr],neuron_to_plot,:)));
for i = 1:length(event_onsets)
    xline(event_onsets(i),'-w','LineWidth',1.5)
end
hold off
set_current_fig;
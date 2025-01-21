addpath(genpath('C:\Code\Github\behavior-analysis2\classifier'))
addpath(genpath('C:\Code\Github\behavior-analysis2'))

%code below to find these numbers although should be the same each time!
passive_events = [7,39,71];%
active_events = [7,39,71,132,146];%
load('V:\Connie\results\opto_2024\context\data_info\info.mat');

%% LOAD THE DATA!
%choice: [0 1 2 3 4 5 6 7 9 10 12 13 14 15 16 17 18 19 20 21 23 24]+1 %to add 11 
% sound: [1 3 4 5 7 9 12 13 14 16 17 18 19 20 21 23 24]+1 %to add 0/2/6/10/11/15

% outcome:[0     1     3     4     5     6     9    10    12    13    14
% 15    16    17    18    23    24]+1 to add 11/19
%photostim: setdiff(1:25,[11,25]) % to add 6?/11 (25 is control)
current_mice =[1 3 4 5 7 9 12 13 14 16 17 18 19 20 21 23 24]+1 ;%setdiff(1:25,[6,11,25]) ;%%[0     1     3     4     6     7     8    12    13    14    15    17    18    20    21    22    23]+1; PHOTOSTIM%[2     3     4     5     6     8    10    13    14    15    16    17    18    19    21    22    24    25]; SOUNDS%setdiff(1:25,[9,23,12]);

info.chosen_mice = current_mice;
info.task_event_type = 'sound_category';

acc_active = load_SVM_results(info,'GLM_3nmf_pre',info.task_event_type,'acc');
shuff_acc_active = load_SVM_results(info,'GLM_3nmf_pre',info.task_event_type,'shuff_acc');

info.chosen_mice = 1;
all_model_outputs = load_SVM_results(info,'GLM_3nmf_pre','sound_category','all_model_outputs');
info.chosen_mice = current_mice;
%adjust event onsets to bins!
event_onsets = find(histcounts(active_events,all_model_outputs{1,1}{1}.binns+active_events(1)));%find(histcounts(all_model_outputs{1,1}{1}.event_onset,all_model_outputs{1,1}{1}.binns+mdl_param.event_onset(1)));

if strcmp('sound_category',info.task_event_type) || strcmp('photostim',info.task_event_type)
    acc_passive = load_SVM_results(info,'GLM_3nmf_passive',info.task_event_type,'acc');
    shuff_acc_passive = load_SVM_results(info,'GLM_3nmf_passive',info.task_event_type,'shuff_acc');
    info.chosen_mice = 1;

%     all_model_outputs = load_SVM_results(info,'GLM_3nmf_pre','sound_category','all_model_outputs');
    all_model_outputs = load_SVM_results(info,'GLM_3nmf_passive','sound_category','all_model_outputs');
    info.chosen_mice = current_mice;

    
    %adjust event onsets to bins!
%     event_onsets = find(histcounts(passive_events,all_model_outputs{1,1}{1}.binns+passive_events(1)));%find(histcounts(all_model_outputs{1,1}{1}.event_onset,all_model_outputs{1,1}{1}.binns+mdl_param.event_onset(1)));
    event_onsets = find(histcounts(active_events,all_model_outputs{1,1}{1}.binns+active_events(1)));%find(histcounts(all_model_outputs{1,1}{1}.event_onset,all_model_outputs{1,1}{1}.binns+mdl_param.event_onset(1)));

end

%%
plot_info.colors = [0.282, 0.239, 0.545;0.482, 0.408, 0.933];% [0.780, 0.082, 0.522;1.000, 0.412, 0.706]--'mediumvioletred', 'hotpink'; %[0.275,0.510,0.706;0.529,0.808,0.980];-- 'steelblue', 'lightskyblue'   %[0.545, 0.271, 0.075; 1 0.549 0]--brown and orange %[0.282, 0.239, 0.545;0.482, 0.408, 0.933];--'darkslateblue','mediumslateblue'
plot_info.minmax = [0.4,.9];
plot_info.xlims = [1,length(all_model_outputs{1,1}{1}.binns)]; %32 or 55
plot_info.event_onsets = event_onsets;

savepath = ['V:\Connie\results\SVM\' info.task_event_type '\'];

if strcmp('sound_category',info.task_event_type) || strcmp('photostim',info.task_event_type)
    plot_info.labels = {'Active','Passive'};
    [svm_mat, svm_mat2] = get_SVM_across_datasets(info,acc_active,shuff_acc_active,plot_info,savepath,{acc_passive,shuff_acc_passive});
else
    plot_info.labels = {'Active'};
    [svm_mat, svm_mat2] = get_SVM_across_datasets(info,acc_active,shuff_acc_active,plot_info,savepath);
end
%%
% Initialize the new cell array C
if ~isempty(svm_mat2)
    svm_acc= cell(length(svm_mat), 2);
else
    svm_acc= cell(length(svm_mat), 1);
end


% Loop through the rows to merge A and B
for i = 1:length(svm_mat)
    svm_acc{i, 1}.accuracy = svm_mat{i, 4}.accuracy(:,1:length(all_model_outputs{1,1}{1}.binns)); % Combine row from A
    svm_acc{i, 1}.shuff_accuracy = svm_mat{i, 4}.shuff_accuracy(:,1:length(all_model_outputs{1,1}{1}.binns)); % Combine row from A
    if ~isempty(svm_mat2)
        svm_acc{i, 2}.accuracy = svm_mat2{i, 4}.accuracy(:,1:length(all_model_outputs{1,1}{1}.binns)); % Combine row from B
        svm_acc{i, 2}.shuff_accuracy = svm_mat2{i, 4}.shuff_accuracy(:,1:length(all_model_outputs{1,1}{1}.binns)); % Combine row from B
    end
end
plot_info.colors_celltype = plot_info.colors;

%use passive because shorter
mdl_param = all_model_outputs{1,1}{1};
save_string = info.task_event_type;
% all_model_outputs = load_SVM_results(info,'GLM_3nmf_passive',info.task_event_type,'all_model_outputs');
plot_svm_across_datasets(svm_acc,plot_info,plot_info.event_onsets,mdl_param,save_string,savepath,[0.4,.7]);movegui(gcf,'center')

%% to determine events
if alignment.active_passive == 2
    load('V:\Connie\ProcessedData\HA11-1R\2023-05-05\passive\imaging.mat')
    [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging,30,2);
    events = determine_onsets(left_padding,right_padding,1:3);
        alignment.type = 'stimulus';
    alignment.data_type = 'deconv';
    [aligned_imaging,imaging_array,align_info] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment); % sample_data is n_trials x n_cells x n_frames

else
    load('V:\Connie\ProcessedData\HA11-1R\2023-05-05\VR\imaging.mat')
    [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging,30);
    events = determine_onsets(left_padding,right_padding,1:5);
    alignment.type = 'pre';
    alignment.data_type = 'deconv';
    [aligned_imaging,imaging_array,align_info] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment); % sample_data is n_trials x n_cells x n_frames
end

mdl_param.event_onset = events(4);
if alignment.active_passive == 2
 frame_length =  events(3)+right_padding(3)-mdl_param.event_onset;%150 outcome?;%for choice; %used to be 281 with update is 260
else
frame_length =  events(5)+right_padding(5)-mdl_param.event_onset;%150 outcome?;%for choice; %used to be 281 with update is 260
end

mdl_param.frames_around = -mdl_param.event_onset+1:frame_length; %-mdl_param.event_onset+1:(frame_length)-mdl_param.event_onset+1;%-mdl_param.event_onset+1:mdl_param.event_onset-51 == -140:90; %frames around onset 
mdl_param.binns = mdl_param.frames_around(1):3:mdl_param.frames_around(end); %bins in terms of event onset

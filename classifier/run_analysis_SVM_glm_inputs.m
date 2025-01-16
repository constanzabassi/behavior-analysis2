
%code below to find these numbers although should be the same each time!
passive_events = [7,39,71];%
active_events = [7,39,71,132,146];%
load('V:\Connie\results\opto_2024\context\data_info\info.mat');
info.chosen_mice = 1;

all_model_outputs = load_SVM_results(info,'GLM_3nmf_pre','sound_category','all_model_outputs');
all_model_outputs = load_SVM_results(info,'GLM_3nmf_passive','sound_category','all_model_outputs');

%adjust event onsets to bins!
event_onsets = find(histcounts(passive_events,all_model_outputs{1,1}{1}.binns+passive_events(1)));%find(histcounts(all_model_outputs{1,1}{1}.event_onset,all_model_outputs{1,1}{1}.binns+mdl_param.event_onset(1)));
event_onsets = find(histcounts(active_events,all_model_outputs{1,1}{1}.binns+active_events(1)));%find(histcounts(all_model_outputs{1,1}{1}.event_onset,all_model_outputs{1,1}{1}.binns+mdl_param.event_onset(1)));

%% LOAD THE DATA!
info.chosen_mice = setdiff(1:25,[9,23,12]);
info.task_event_type = 'sound_category';

acc_active = load_SVM_results(info,'GLM_3nmf_pre',info.task_event_type,'acc');
shuff_acc_active = load_SVM_results(info,'GLM_3nmf_pre',info.task_event_type,'shuff_acc');

acc_passive = load_SVM_results(info,'GLM_3nmf_passive',info.task_event_type,'acc');
shuff_acc_passive = load_SVM_results(info,'GLM_3nmf_passive',info.task_event_type,'shuff_acc');

%%
plot_info.colors = [0.282, 0.239, 0.545;0.482, 0.408, 0.933];%'darkslateblue','mediumslateblue'
plot_info.minmax = [0.4,1];
plot_info.xlims = [1,32]; %32 or 55
plot_info.event_onsets = event_onsets;
savepath = [];

[svm_mat, svm_mat2] = get_SVM_across_datasets(info,acc_active,shuff_acc_active,plot_info,savepath,{acc_passive,shuff_acc_passive});

%%
% Initialize the new cell array C
svm_acc= cell(22, 2);

% Loop through the rows to merge A and B
for i = 1:22
    svm_acc{i, 1}.accuracy = svm_mat{i, 4}.accuracy(:,1:32); % Combine row from A
    svm_acc{i, 2}.accuracy = svm_mat2{i, 4}.accuracy(:,1:32); % Combine row from B
    svm_acc{i, 1}.shuff_accuracy = svm_mat{i, 4}.shuff_accuracy(:,1:32); % Combine row from A
    svm_acc{i, 2}.shuff_accuracy = svm_mat2{i, 4}.shuff_accuracy(:,1:32); % Combine row from B

end
plot_info.colors_celltype = plot_info.colors;
plot_info.labels = {"Active","Passive"};

%use passive because shorter
mdl_param = all_model_outputs{1,1}{1}
info.chosen_mice = 1;
all_model_outputs = load_SVM_results(info,'GLM_3nmf_passive','sound_category','all_model_outputs');
plot_svm_across_datasets(svm_acc,plot_info,plot_info.event_onsets,mdl_param,[],[],[0.4,.9]);movegui(gcf,'center')

% %% to determine events
% if alignment.active_passive == 2
%     load('V:\Connie\ProcessedData\HA11-1R\2023-05-05\passive\imaging.mat')
%     [align_info,alignment_frames,left_padding,right_padding] = find_align_info (imaging,30,2);
%     events = determine_onsets(left_padding,right_padding,1:3);
% else
%     load('V:\Connie\ProcessedData\HA11-1R\2023-05-05\VR\imaging.mat')
%     [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging,30);
%     events = determine_onsets(left_padding,right_padding,1:5);
% end
% 
% mdl_param.event_onset = events(1);
% if alignment.active_passive == 2
%  frame_length =  events(3)+right_padding(3)-mdl_param.event_onset;%150 outcome?;%for choice; %used to be 281 with update is 260
% else
% frame_length =  events(5)+right_padding(5)-mdl_param.event_onset;%150 outcome?;%for choice; %used to be 281 with update is 260
% end
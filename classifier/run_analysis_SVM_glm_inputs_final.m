addpath(genpath('C:\Code\Github\behavior-analysis2\classifier'))
addpath(genpath('C:\Code\Github\behavior-analysis2'))


load('V:\Connie\results\opto_2024\context\data_info\info.mat');
info.task_event_type = 'sound_category';
%code below to find these numbers although should be the same each time!
[current_mice,onset_id, active_events, passive_events] = default_data_info(info.task_event_type);

do_passive = 0;
if do_passive == 0
    acc_passive = [];
    shuff_acc_passive = [];
end
%% 1) load data
info.chosen_mice = current_mice;
[acc_active, shuff_acc_active, beta_active, acc_active_top, shuff_acc_active_top] = wrapper_load_all_svm_data(info, 'GLM_3nmf_pre', info.task_event_type, '_top', '_1');
% [acc_passive, shuff_acc_passive, beta_passive, acc_passive_top, shuff_acc_passive_top] = wrapper_load_all_svm_data(info, 'GLM_3nmf_passive', task_event_type, '_top', '_1')

info.chosen_mice = 2;
all_model_outputs = load_SVM_results(info,'GLM_3nmf_pre','sound_category','all_model_outputs');
info.chosen_mice = current_mice;
event_onsets = find(histcounts(active_events,all_model_outputs{1,1}{1}.binns+active_events(1)));%find(histcounts(all_model_outputs{1,1}{1}.event_onset,all_model_outputs{1,1}{1}.binns+mdl_param.event_onset(1)));

%% plot individual datasets and find means across shuffles
doplot = 0;

savepath = ['V:\Connie\results\SVM_1_wtop\' info.task_event_type '\'];%['V:\Connie\results\SVM_1\' info.task_event_type '\'];
info.savepath = savepath;

[svm_mat, svm_mat2] = wrapper_plot_svm_acc_trace_individual_datasets(info, acc_active, shuff_acc_active, acc_passive, shuff_acc_passive, all_model_outputs, savepath, doplot, event_onsets);

%% plot all datasets together
%use passive because shorter
if do_passive == 1
    all_model_outputs = load_SVM_results(info,'GLM_3nmf_passive',info.task_event_type,'all_model_outputs');
end

mdl_param = all_model_outputs{1,1}{1};
save_string = info.task_event_type;

wrapper_plot_svm_acc_trace_all_datasets(svm_mat, mdl_param, save_string, savepath, [.45,.8],svm_mat2,event_onsets);

%% PLOT BETA WEIGHTS
load('V:\Connie\results\opto_2024\context\data_info\all_celltypes.mat');
all_celltypes_updated = all_celltypes(info.chosen_mice);
info.event_onsets = event_onsets;

[beta_mat,beta_mat_pass] = wrapper_mean_betas(info,beta_active,[]); %mean across iterations

%
bin_id = event_onsets(onset_id); %time when to get betas from
wrapper_plot_betas_distributions(info,bin_id, beta_mat, all_celltypes_updated, plot_info, mdl_param, onset_id, [],[]);

% PLOT WEIGHT EVOLUTION OVER TIME
info.savestr = 'betas';
plot_weights_over_time([1:55], event_onsets(onset_id), beta_mat,all_celltypes_updated,plot_info,mdl_param.data_type,info,[1:3],mdl_param);




%classify data

% get inputs for classifier
alignment.data_type = 'dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
mdl_param.event_onset = 176; %relative to aligned data this are the events in aligned data:(7,42,77,141,176,201)
mdl_param.frames_around = -mdl_param.event_onset+1:231-mdl_param.event_onset;%-mdl_param.event_onset+1:mdl_param.event_onset-51 == -140:90; %frames around onset 
mdl_param.bin = 3; %bin size in terms of frames
mdl_param.binns = mdl_param.frames_around(1):mdl_param.bin:mdl_param.frames_around(end); %bins in terms of event onset
mdl_param.fields_to_balance = [1,2]; %{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4
mdl_param.field_to_predict = 1; %{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4


mdl_param.data_type = alignment.data_type;

mdl_param.num_iterations = 25; %number of times to subsample

plot_info.colors_celltype = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04 % red  
                            0 0 0.5]; %dark purple

info.savestr = 'outcome_25sub'; %how to save current run
%% RUN CLASSIFIER
[svm, svm_mat] = run_classifier(imaging_st,all_celltypes,mdl_param, alignment,plot_info,info);

%% plot weight distribution across celltypes for model run with all cells
[betas] = compare_svm_weights(svm); %uses ce = 4 which is all cells to get betas
onset = find(histcounts(svm{1,1,4}.mdl_param.event_onset,svm{1,1,4}.mdl_param.binns+svm{1,1,4}.mdl_param.event_onset)); %gives onset bin of event

plot_dist_weights(onset, betas,all_celltypes,plot_info,svm,svm_info);

%% average across datasets
[~,~,left_padding,right_padding] = find_align_info (imaging_st{1,1},30);
mdl_param.event_onset_true = determine_onsets(left_padding,right_padding,[1:6]);
event_onsets = find(histcounts(mdl_param.event_onset_true,mdl_param.binns+mdl_param.event_onset));

plot_svm_across_datasets(svm_mat,plot_info,event_onsets,'_is_stim_sub25_',['V:/Connie/results/behavior/svm']);
%% TESTING SVM REGULARIZATION PARAMETERS
og_svm = output; %load which one you want to rerun
info.savestr = 'box_10_choice_from_attempt2'; %update save string
[output2, output_mat2] = rerun_classifier(og_svm, imaging_st, alignment,plot_info,info);


%classify data

% get inputs for classifier
alignment.data_type = 'dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
mdl_param.event_onset = 141; %relative to aligned data
mdl_param.frames_around = -140:90; %frames around onset 
mdl_param.bin = 3; %bin size in terms of frames
mdl_param.binns = mdl_param.frames_around(1):mdl_param.bin:mdl_param.frames_around(end);

mdl_param.data_type = alignment.data_type;

mdl_param.num_iterations = 5; %number of times to subsample

plot_info.colors_celltype = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04]; % red  

info.savestr = 'attempt_1_nooverlap'; %how to save current run
%% RUN CLASSIFIER
[svm, svm_mat] = run_classifier(imaging_st,all_celltypes,mdl_param, alignment,plot_info,info);
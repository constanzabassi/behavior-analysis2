%classify data

% get inputs for classifier
alignment.data_type = 'dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
mdl_param.event_onset = 7; %relative to aligned data this are the events in aligned data:(7,42,77,141,176,201)
mdl_param.frames_around = -mdl_param.event_onset+1:90;%-mdl_param.event_onset+1:mdl_param.event_onset-51 == -140:90; %frames around onset 
mdl_param.bin = 3; %bin size in terms of frames
mdl_param.binns = mdl_param.frames_around(1):mdl_param.bin:mdl_param.frames_around(end); %bins in terms of event onset
%event_onset+current_frame:event_onset+current_frame+bin

mdl_param.data_type = alignment.data_type;

mdl_param.num_iterations = 5; %number of times to subsample

plot_info.colors_celltype = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04 % red  
                            0 0 0.5]; %dark purple

info.savestr = 'attempt_2_nooverlap_condition'; %how to save current run
%% RUN CLASSIFIER
[svm, svm_mat] = run_classifier(imaging_st,all_celltypes,mdl_param, alignment,plot_info,info);

%% plot weight distribution across celltypes for model run with all cells
[betas] = compare_svm_weights(output); %uses ce = 4 which is all cells to get betas
onset = find(histcounts(output{1,1,4}.mdl_param.event_onset,output{1,1,4}.mdl_param.binns+output{1,1,4}.mdl_param.event_onset)); %gives onset bin of event

plot_dist_weights(onset, betas,all_celltypes,plot_info,output);


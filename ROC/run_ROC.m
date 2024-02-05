% CODE TO RUN ROC ANALYSIS BASED ON NAJAFI 2020 PAPER
% use avetrialAlign_setVars to get the input vars.
% function choicePref_ROC(traces_al_sm, ipsiTrs, contraTrs, makeplots, eventI_stimOn, useEqualNumTrs, doChoicePref, doshfl)
% https://github.com/farznaj/imaging_decisionMaking_exc_inh/blob/master/imaging/avetrialAlign_caMean.m
% https://github.com/farznaj/imaging_decisionMaking_exc_inh/blob/master/imaging/choicePref_ROC.m
alignment.data_type = 'dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'

plot_info.colors_celltype = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04 % red  
                            0 0 0.5]; %dark purple

%everything will be saved inside roc_mdl
roc_mdl.savestr = 'avg_deconv';
roc_mdl.event_onset = 141;
roc_mdl.frames = roc_mdl.event_onset-11:roc_mdl.event_onset-1; %using 10 frames before turn onset (finds avg of these frames)
roc_mdl.shuff_num = 50;

%FOR RUNNING MODEL OVER TIME!
roc_mdl.bin_size = 3;
roc_mdl.binss = roc_mdl.event_onset-31:roc_mdl.bin_size:roc_mdl.event_onset+30; %1 sec before and after onset



%% RUN ROC ACROSS DATASETS FINDING MEAN IN BIN roc_mdl.frames
[roc_mdl] = compute_roc_choice (imaging_st,alignment,roc_mdl,info,plot_info,all_celltypes,1); %last value is whether to shuffle datasets or not
%% PLOT EXAMPLE CELLS
ex_mouse = 1;
alignment.field_to_separate = [1,2]; %1) correct, 2) left turn, 3) condition, 4)is_stim_trial
alignment.conditions = [3,4]; %of conditions separated list out which ones to plot
alignment.data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
alignment.number = [1:6]; %'reward','turn','stimulus'

plot_example_cells(imaging_st,alignment,ex_mouse,roc_mdl); %sorts cells based on roc choice preference

%% RUN ROC ACROSS DATASETS OVER TIME!
[roc_mdl] = compute_roc_choice_overtime (imaging_st,alignment,roc_mdl,info,plot_info,all_celltypes,1);


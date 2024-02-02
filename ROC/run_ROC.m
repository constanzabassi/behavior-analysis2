% CODE TO RUN ROC ANALYSIS BASED ON NAJAFI 2020 PAPER
% use avetrialAlign_setVars to get the input vars.
% function choicePref_ROC(traces_al_sm, ipsiTrs, contraTrs, makeplots, eventI_stimOn, useEqualNumTrs, doChoicePref, doshfl)
% https://github.com/farznaj/imaging_decisionMaking_exc_inh/blob/master/imaging/avetrialAlign_caMean.m
% https://github.com/farznaj/imaging_decisionMaking_exc_inh/blob/master/imaging/choicePref_ROC.m
alignment.data_type = 'dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'

%everything will be saved inside roc_mdl
roc_mdl.frames = 130:140; %using 10 frames before turn onset (finds avg of these frames)
roc_mdl.shuff_num = 50;

%% RUN ROC ACROSS DATASETS
[roc_mdl] = compute_roc_choice (imaging_st,alignment,roc_mdl,info,1); %last value is whether to shuffle datasets or not
%% PLOT EXAMPLE CELLS
ex_mouse = 6;
alignment.field_to_separate = [1,2]; %1) correct, 2) left turn, 3) condition, 4)is_stim_trial
alignment.conditions = [3,4]; %of conditions separated list out which ones to plot
alignment.data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
alignment.number = [1:6]; %'reward','turn','stimulus'

plot_example_cells(imaging_st,alignment,ex_mouse,roc_mdl); %sorts cells based on roc choice preference


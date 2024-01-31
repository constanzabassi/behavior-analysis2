% CODE TO RUN ROC ANALYSIS BASED ON NAJAFI 2020 PAPER
% use avetrialAlign_setVars to get the input vars.
% function choicePref_ROC(traces_al_sm, ipsiTrs, contraTrs, makeplots, eventI_stimOn, useEqualNumTrs, doChoicePref, doshfl)
% https://github.com/farznaj/imaging_decisionMaking_exc_inh/blob/master/imaging/avetrialAlign_caMean.m
% https://github.com/farznaj/imaging_decisionMaking_exc_inh/blob/master/imaging/choicePref_ROC.m
alignment.data_type = 'dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'

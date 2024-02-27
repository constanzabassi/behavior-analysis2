%% find nice cell traces to show based on SVM betas!
%1) load svm 
[betas] = compare_svm_weights(svm);
onset = find(histcounts(svm{1,1,4}.mdl_param.event_onset,svm{1,1,4}.mdl_param.binns+svm{1,1,4}.mdl_param.event_onset)); %gives onset bin of event
bins_chosen = onset-5:onset+5;

%%
ex_mouse = 4;
ex_imaging = imaging_st{1,ex_mouse};

alignment.conditions = [3,4]; %[5,7] is control
alignment.data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
alignment.number = [1:6]; %'reward','turn','stimulus'

[align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
[aligned_imaging,imaging_array,align_info] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
event_onsets = determine_onsets(left_padding,right_padding,[1:6]);
fieldss = fieldnames(ex_imaging(1).virmen_trial_info);
field_to_separate = {fieldss{1:2}};

[all_conditions, condition_array_trials] = divide_trials_updated (ex_imaging,field_to_separate); %divide trials into specific conditions
%chosen_cells = [216,117,240,227,257,54];
chosen_cells = 1:10
for c = chosen_cells %[a,b] =max(output{1,1,2}.mdl{140}.Beta); 
    cel_id = (c)+40;%roc_mdl.pos_sig{1,ex_mouse}(c);
    figure(c);clf;
    individual_cell_plots_averaged(aligned_imaging, cel_id, all_conditions,alignment,event_onsets)
end
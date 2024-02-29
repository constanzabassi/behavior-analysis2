%% find nice cell traces to show based on SVM betas!
%1) load svm 
[betas] = compare_svm_weights(svm);
onset = find(histcounts(svm{1,1,4}.mdl_param.event_onset,svm{1,1,4}.mdl_param.binns+svm{1,1,4}.mdl_param.event_onset)); %gives onset bin of event
bins_chosen = onset:onset+5; %in terms of bins!

[avg_beta,beta_cel] = find_avg_svm_beta (betas,all_celltypes,bins_chosen);

best_cels = find_top_cels(beta_cel,num_cells);
%%
ex_mouse = 2;
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

% chosen_cells = all_celltypes{1,ex_mouse}.pyr_cells(best_cels.pyr(ex_mouse,:));
chosen_cells = all_celltypes{1,ex_mouse}.pv_cells(best_cels.pv(ex_mouse,:));
chosen_cells = all_celltypes{1,ex_mouse}.som_cells(best_cels.som(ex_mouse,:));

for c = 1:length(chosen_cells) %[a,b] =max(output{1,1,2}.mdl{140}.Beta); 
    cel_id = chosen_cells(c);%roc_mdl.pos_sig{1,ex_mouse}(c);
    figure(c);clf;
    individual_cell_plots_averaged(aligned_imaging, cel_id, all_conditions,alignment,event_onsets)

%     figure(c+10);clf; imagesc(squeeze(aligned_imaging(all_conditions{3,1},cel_id,:)));
end
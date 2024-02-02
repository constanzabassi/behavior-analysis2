function plot_example_cells(imaging_st,alignment,ex_mouse,roc_mdl)


ex_imaging = imaging_st{1,ex_mouse};
[align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
[aligned_imaging,imaging_array,align_info] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
event_onsets = determine_onsets(left_padding,right_padding,[1:6]);
fieldss = fieldnames(ex_imaging(1).virmen_trial_info);
fields_to_separate = {fieldss{alignment.field_to_separate}};

[all_conditions, condition_array_trials] = divide_trials_updated (ex_imaging,fields_to_separate); %divide trials into specific conditions

%sort roc cells based on positive preference
[b] = sort(roc_mdl.pos_sig{1,ex_mouse});

for c = 1:10 %[a,b] =max(output{1,1,2}.mdl{140}.Beta); 
    cel_id = b(c);%roc_mdl.pos_sig{1,ex_mouse}(c);
    figure(c);clf;
    choic_pref = roc_mdl.choice_Pref{1,ex_mouse}(cel_id);
    individual_cell_plots(aligned_imaging, cel_id, all_conditions,alignment,event_onsets,choic_pref);
end
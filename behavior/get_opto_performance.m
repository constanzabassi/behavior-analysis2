
% behav_param.num_iterations = 5;
% behav_param.fields_to_balance = [3,4];%{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4
% alignment.data_type = 'dff';% 'dff', 'z_dff', else it's deconvolved
% alignment.type = 'all'; %'reward','turn','stimulus','ITI'
function performance = get_opto_performance(imaging_st,behav_param,alignment)
for it = 1:behav_param.num_iterations
    it
    for m = 1:length(imaging_st)
        m
        ex_imaging = imaging_st{1,m};
        [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
        [aligned_imaging,imaging_array,~] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
        [selected_trials,~,~] = get_balanced_field_trials(ex_imaging,behav_param.fields_to_balance);
        [~, condition_array] = divide_trials_updated (ex_imaging,{'correct','left_turn','condition','is_stim_trial'});
        trial_ids = find(selected_trials);
        trial_ids_opto = trial_ids(find(condition_array(trial_ids,4)));
        trial_ids_ctrl = trial_ids(find(condition_array(trial_ids,4)==0));

        correct_or_no = condition_array(trial_ids,2);
        left_or_no = condition_array(trial_ids,3);
        performance(it,m).correct_all = sum(correct_or_no)/length(correct_or_no);
        performance(it,m).left_all = sum(left_or_no)/length(correct_or_no);
        performance(it,m).correct_opto = sum(condition_array(trial_ids_opto,2))/length(trial_ids_opto);
        performance(it,m).left_opto = sum(condition_array(trial_ids_opto,3))/length(trial_ids_opto);
        performance(it,m).correct_ctrl = sum(condition_array(trial_ids_ctrl,2))/length(trial_ids_ctrl);
        performance(it,m).left_ctrl = sum(condition_array(trial_ids_ctrl,3))/length(trial_ids_ctrl);
        performance(it,m).trial_ids_opto = trial_ids_opto;
        performance(it,m).trial_ids_ctrl = trial_ids_ctrl;
        
    end
end
function performance = get_opto_performance_selected_trials(imaging_st,behav_param,alignment,specified_trials)
for it = 1;
    for m = 1:length(imaging_st)
        m
        ex_imaging = imaging_st{1,m};
        [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
        [aligned_imaging,imaging_array,~] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);

        %         [selected_trials,~,~] = get_balanced_field_trials(ex_imaging,behav_param.fields_to_balance);
        %%% BALANCING FIRST FEW TRIALS TOO LAZY TO WRITE NEW FUNCTION
            imaging = ex_imaging;
            fieldss = fieldnames(imaging(1).virmen_trial_info);
            empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
            good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
            
            selected_field_num = behav_param.fields_to_balance;
            selected_trials = false(1, length(good_trials));
            virmen_trial_info = [imaging(good_trials).virmen_trial_info];
            
            if length(selected_field_num)==1
                condition = [virmen_trial_info.(fieldss{selected_field_num})];
                
                unique_cond = unique(condition);
                for c = 1:length(unique_cond)
                    conds{c} = find(condition == unique_cond(c));
                end
                
                
                % make sure that each of these groups is equally represented in
                % the training trials, to ensure that stimulus category and
                % behavioural choice are uncorrelated.
                
                smallest_set_size = min(cellfun(@length ,conds));
                lc_selected = conds{1};
                rc_selected = conds{2};
                selected_trials(lc_selected(specified_trials)) = true;
                selected_trials(rc_selected(specified_trials)) = true;
                
                smallest_set_size
            else
                if strcmp(fieldss{selected_field_num(1)},'condition')
                    condition = rem([virmen_trial_info.(fieldss{selected_field_num(1)})],2);
                    condition2 = [virmen_trial_info.(fieldss{selected_field_num(2)})];
                elseif strcmp(fieldss{selected_field_num(2)},'condition')
                    condition = [virmen_trial_info.(fieldss{selected_field_num(1)})];
                    condition2 = rem([virmen_trial_info.(fieldss{selected_field_num(2)})],2);
                else
                    condition = [virmen_trial_info.(fieldss{selected_field_num(1)})];
                    condition2 = [virmen_trial_info.(fieldss{selected_field_num(2)})];
                end
                
                lc = condition & condition2;% [1,1]
                li = condition & ~condition2;% [1,0]
                rc = ~condition & condition2;% [0,1]
                ri = ~condition & ~condition2;% [0,0]
                
                % make sure that each of these groups is equally represented in
                % the training trials, to ensure that stimulus category and
                % behavioural choice are uncorrelated.
                
                smallest_set_size = min([nnz(lc), nnz(li), nnz(rc), nnz(ri)]);
                smallest_set_size
                lc_selected = find(lc);
                li_selected = find(li);
                rc_selected = find(rc);
                ri_selected = find(ri);
                selected_trials(lc_selected(specified_trials)) = true;
                selected_trials(li_selected(specified_trials)) = true;
                selected_trials(rc_selected(specified_trials)) = true;
                selected_trials(ri_selected(specified_trials)) = true;
            
            end
            
            
        %%% 

        [~, condition_array] = divide_trials_updated (ex_imaging,{'correct','left_turn','condition','is_stim_trial'});
        trial_ids = find(selected_trials);
        trial_ids_opto = trial_ids(find(condition_array(trial_ids,5)));
        trial_ids_ctrl = trial_ids(find(condition_array(trial_ids,5)==0));

        correct_or_no = condition_array(trial_ids,2);
        left_or_no = condition_array(trial_ids,3);
        turn_onsets = [imaging_array.turn_frame];
        performance(it,m).correct_all = sum(correct_or_no)/length(correct_or_no);
        performance(it,m).left_all = sum(left_or_no)/length(correct_or_no);
        performance(it,m).turn_onset_all = turn_onsets;

        performance(it,m).correct_opto = sum(condition_array(trial_ids_opto,2))/length(trial_ids_opto);
        performance(it,m).left_opto = sum(condition_array(trial_ids_opto,3))/length(trial_ids_opto);
        performance(it,m).correct_ctrl = sum(condition_array(trial_ids_ctrl,2))/length(trial_ids_ctrl);
        performance(it,m).left_ctrl = sum(condition_array(trial_ids_ctrl,3))/length(trial_ids_ctrl);
        performance(it,m).turn_onset_opto = turn_onsets(trial_ids_opto);
        performance(it,m).turn_onset_ctrl = turn_onsets(trial_ids_ctrl);

        performance(it,m).trial_ids_opto = trial_ids_opto;
        performance(it,m).trial_ids_ctrl = trial_ids_ctrl;
    end
    end
end
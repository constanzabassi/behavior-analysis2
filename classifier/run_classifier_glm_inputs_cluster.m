%% SVM predict choice using cell type activity
function [acc] = run_classifier_glm_inputs_cluster(current_mouse , save_string_glm,all_celltypes,mdl_param, alignment,info)
possible_celltypes = fieldnames(all_celltypes{1,1});

acc = {};
shuff_acc = {};
for m = current_mouse
%     ss = info.server(m);
%     ss = ss {1,1};
info.mouse_date{1,m} = strrep(info.mouse_date{1,m}, '\', '/');
    base = strcat('/ix/crunyan/cdb66/Data/',num2str(info.mouse_date{1,m}),'/',save_string_glm,'/');

%load GLM data!
for splits = 1:10
dir_base = strcat(base,'/prepost trial cv 73 #', num2str(splits));
base_testing = strcat(dir_base, '/test');
% Process training and testing data
load(strcat(dir_base, '/condition_array_trials.mat'));
% Load imaging data
if alignment.active_passive == 1
    base_imaging = strcat('/ix/crunyan/cdb66/Data/',num2str(info.mouse_date{1,m}),'/VR/');
else
    base_imaging = strcat('/ix/crunyan/cdb66/Data/',num2str(info.mouse_date{1,m}),'/passive/');
end
load(strcat(base_imaging,'/imaging.mat'));
train_imaging_spk = make_imaging_from_trials(condition_array_trials, imaging);

%For some reason I saved them differently for active vs passive
if alignment.active_passive == 1
    load(strcat(base_testing, '/condition_array_trials.mat'));
    test_imaging_spk = make_imaging_from_trials(condition_array_trials, imaging);
else
    load(strcat(dir_base, '/condition_array_trials_test.mat'));
    test_imaging_spk = make_imaging_from_trials(condition_array_trials_test, imaging);
end

%load minimum # of trials!!
if contains(dir_base, 'passive')
        % Replace "passive" with "pre"
    newDir = strrep(dir_base, 'passive', 'pre');
    load(strcat(newDir,'/sound_trials.mat'));
else
    load(strcat(dir_base,'/sound_trials.mat'));
end

if contains(dir_base, 'passive')
    % Replace "passive" with "pre"
    newDir = strrep(dir_base, 'passive', 'pre');
    load(strcat(newDir,'/photostim_trials.mat'));
else
    load(strcat(dir_base,'/photostim_trials.mat'));
end

%could consider using the exact same trials as original decoder (but would
%not work for shuffled bc the trials ids are shuffled
%find(decoder_results.aligned.shuffled.photostim(1).cat_results.alignment.trials_used.train);
% disp(['Saving path: ' info.savepath '/SVM_' alignment.data_type '_' info.savestr]);
    for it = 1:mdl_param.num_iterations
%         it
%     for m = 1:length(imaging_st)
        count = 0;
%         m
        for ce = 1:4 %4th will be all cells together no subsamples!
            count = count+1;
            mdl_param.mouse = m;
            %do current split
%             ex_imaging = imaging_st{1,m};
            imaging_train_input = train_imaging_spk; %imaging_st{1,m};
            imaging_test_input = test_imaging_spk;
            
%             %original code
%             if single_event == 1
%                 [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30,1);
%             else
%                 [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
%             end

            if alignment.active_passive == 2
                [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging_train_input,30,alignment.active_passive);
                [align_info_test,alignment_frames_test,left_padding_t,right_padding_t] = find_align_info_updated (imaging_test_input,30,alignment.active_passive);
            else
                [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging_train_input,30);
                [align_info_test,alignment_frames_test,left_padding_t,right_padding_t] = find_align_info_updated (imaging_test_input,30);
            end
            [aligned_imaging,imaging_array,align_info] = align_behavior_data (imaging_train_input,align_info,alignment_frames,left_padding,right_padding,alignment); % sample_data is n_trials x n_cells x n_frames
            [aligned_imaging_test,imaging_array_test,align_info_test] = align_behavior_data (imaging_test_input,align_info_test,alignment_frames_test,left_padding,right_padding,alignment); % sample_data is n_trials x n_cells x n_frames

%             [aligned_imaging,imaging_array,align_info] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
            
%             [all_conditions, condition_array_trials] = divide_trials(imaging_train_input); % (ex_imaging); %divide trials into all possible conditions
            %  condition_array_trials (trial_ids, correct or not, left or not, stim or not)
                        
            %subsample cells!
            if ce <4
                num_observations_needed = min(cellfun(@length,struct2cell(all_celltypes{1,m}))); %min number of cells 
                sub_data = subsample_fun(all_celltypes{1,m}.(possible_celltypes{ce}),num_observations_needed);
                mdl_param.mdl_cells = sub_data;
            else
                mdl_param.mdl_cells = 1:sum(cellfun(@length,struct2cell(all_celltypes{1,m}))); %all cells together
            end
            %BALANCE TRIALS!!! THIS IS THE PART THAT MIGHT DIFFER FROM WHAT I HAD BEFORE (COPYING TO GLM DECODER CODE)            
            if count == 1 %keep the trials the same across cell types!
                %load same trials used in glm!!!
                if mdl_param.field_to_predict == 1
                    load(strcat(base,'/decoding/',num2str(splits),'_1/decoder_results_regular_outcome.mat'));
                    selected_trials = decoder_results.aligned.outcome(it).results.alignment.trials_used.train;
                    selected_trials_test = decoder_results.aligned.outcome(it).results.alignment.trials_used.test;
                    mdl_param.selected_trials = selected_trials;
                    mdl_param.selected_trials_test = selected_trials_test;
                elseif mdl_param.field_to_predict == 2
                    load(strcat(base,'/decoding/',num2str(splits),'_1/decoder_results_regular_choice.mat'));
                    selected_trials = decoder_results.aligned.choice(it).results.alignment.trials_used.train;
                    selected_trials_test = decoder_results.aligned.choice(it).results.alignment.trials_used.test;
                    mdl_param.selected_trials = selected_trials;
                    mdl_param.selected_trials_test = selected_trials_test;
                elseif mdl_param.field_to_predict == 3
                    load(strcat(base,'/decoding/',num2str(splits),'_1/decoder_results_regular_sound_category.mat'));
                    selected_trials = decoder_results.aligned.sound_category(it).results.alignment.trials_used.train;
                    selected_trials_test = decoder_results.aligned.sound_category(it).results.alignment.trials_used.test;
                    mdl_param.selected_trials = selected_trials;
                    mdl_param.selected_trials_test = selected_trials_test;
                elseif mdl_param.field_to_predict == 4
                    load(strcat(base,'/decoding/',num2str(splits),'_1/decoder_results_regular_photostim.mat'));
                    selected_trials = decoder_results.aligned.photostim(it).results.alignment.trials_used.train;
                    selected_trials_test = decoder_results.aligned.photostim(it).results.alignment.trials_used.test;
                    mdl_param.selected_trials = selected_trials;
                    mdl_param.selected_trials_test = selected_trials_test;
                end
                
                %[selected_trials,~,~] = get_balanced_field_trials(ex_imaging,mdl_param.fields_to_balance);
                
%                 %mdl_param.fields_to_balance = [1,2]; %{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4
%                 if mdl_param.field_to_predict == 3
%                     
%                     min_trials = sound_trials;
%                     if alignment.single_balance == 1
%                          if alignment.active_passive == 1
%                             field_indices = [2,3]; % %virmen fields in order: {'correct'1 }{'left_turn'2} {'condition'3}{'is_stim_trial'4}
%         %                      %varagin would have directory of sound_trials or photostim_trials
%                               %only balance the thing we are predicting for the test!
%                             field_indices_test = [3];
%                             if length(min_trials)>2
%                                 min_trials(2) = min_trials(3) *2;
%                                 min_trials(3) = [];
%                             else
%                                 min_trials(2) = min_trials(2) *2;
%                             end
%             
%                         else %PASSIVE
%                             field_indices = [3]; % %NO LEFT TURN
%                             field_indices_test = [3];
%                             if length(min_trials)>2
%                                 min_trials(2) = min_trials(3);
%                                 min_trials(3) = [];
%                             end
%                             min_trials = min_trials*2;
%                         end
%                     else
%                         if alignment.active_passive == 1
%                             field_indices = [2,3]; % %virmen fields in order: {'correct'1 }{'left_turn'2} {'condition'3}{'is_stim_trial'4}
%                             field_indices_test = [2,3];
%             
%                         else %PASSIVE
%                             field_indices = [3]; % %NO LEFT TURN
%                             field_indices_test = [3];
%                             min_trials = sound_trials*2; %train,test (*2 because only balancing one thing)
%                         end
%                     end
%                 elseif mdl_param.field_to_predict == 2 %decouple choice and stimuli
%                     field_indices = [2,3];
%                     if alignment.single_balance == 1
%                         field_indices_test = [2];
%                         %adding this so shuffles are not including too many trials
%                         
%                         if length(min_trials)>2
%                             min_trials(2) = min_trials(3) *2;
%                             min_trials(3) = [];
%                         else
%                             min_trials(2) = min_trials(2) *2;
%                         end
%                     else
%                         field_indices_test = [2,3];
%                         %adding this so shuffles are not including too many trials
%                         
%                          %varagin would have directory of sound_trials or photostim_trials
%                         min_trials = sound_trials;
%                     end
%                 elseif  mdl_param.field_to_predict == 1
%                     field_indices = [1,2];
%                     if alignment.single_balance == 1
%                         field_indices_test = [1];
%                         %adding this so shuffles are not including too many trials
%                         
%                         if length(min_trials)>2
%                             min_trials(2) = min_trials(3) *2;
%                             min_trials(3) = [];
%                         else
%                             min_trials(2) = min_trials(2) *2;
%                         end
%                     else
%                         field_indices_test = [1,2];
%                         min_trials = sound_trials;
%                     end
%                 elseif mdl_param.field_to_predict == 4
%                     field_indices = [3,4];
%                     min_trials = photostim_trials;
%                     if alignment.single_balance == 1
%                     %only balance the thing we are predicting for the test!
%                         field_indices_test = [4];
%                         if length(min_trials)>2
%                             min_trials(2) = min_trials(3) *2;
%                             min_trials(3) = [];
%                             else
%                                 min_trials(2) = min_trials(2) *2;
%                         end
%                     else
%                         field_indices_test = [3,4];
%                         min_trials(2) = min_trials(2);
%                     end
%                 end
%                 % Create a temporary imaging structure with only fitting trials
%                 temp_imaging = imaging_train_input(fitting_trials);
%                 
%                 % Get balanced trials (using min)
%                 
%                     [selected_trials, ~, ~, ~] = get_balanced_field_trials(temp_imaging, field_indices,min_trials(1));
%                     %only needed for test here bc of comparisons across models need
%                     %same number of trials!
%                     temp_imaging_test = imaging_test(testing_trials);
%                     [selected_trials_test, ~, ~, ~] = get_balanced_field_trials(temp_imaging_test, field_indices_test,min_trials(2));
%                     test_trial_indices = find(testing_trials);
%                     selected_original_indices_t = test_trial_indices(selected_trials_test);
%                     new_testing_trials(selected_original_indices_t) = true;
%                     n_testing_trials =   nnz(new_testing_trials);
%                     testing_trials = new_testing_trials;
%                     imaging_test = imaging_test(testing_trials);
% 
% 
% 
% 

            else %MAKE SURE YOU USE THE SAME TRIALS ACROSS CELL TYPES 
                mdl_param.selected_trials = selected_trials;
            end
            mdl_param.selected_trials = selected_trials;
    
            %get X and Y ready for classifier
            fieldss = fieldnames(imaging_train_input(1).virmen_trial_info);
%             [~, condition_array] = divide_trials_updated (ex_imaging,{fieldss{mdl_param.field_to_predict}});
            [~, condition_array] = divide_trials_updated (imaging_train_input,{fieldss{mdl_param.field_to_predict}});
            mdl_Y = condition_array(find(mdl_param.selected_trials),2);%condition_array_trials_t(find(mdl_param.selected_trials),2); %get trained Y labels
            mdl_X = aligned_imaging(find(mdl_param.selected_trials),:,:);

            %repeat for test trials!
            [~, condition_array_test] = divide_trials_updated (imaging_test_input,{fieldss{mdl_param.field_to_predict}});
            mdl_Y_test = condition_array_test(find(mdl_param.selected_trials_test),2);%condition_array_trials_t(find(mdl_param.selected_trials),2); %get trained Y labels
            mdl_X_test = aligned_imaging_test(find(mdl_param.selected_trials_test),:,:);
            
            fprintf(['split #: ', num2str(splits),' || subsample #: ', num2str(it),' || mouse :' , num2str(info.mouse_date{1,m}), ' ||    celltype :' num2str(ce), ' ||  size Y : ' num2str(size(mdl_Y)) ' || size X : '  num2str(size(mdl_X)) '\n']);
            output{splits,it,ce} = classify_over_time_glm_inputs(mdl_X,mdl_Y, mdl_param,mdl_X_test,mdl_Y_test);
            
            % gete accuracy!
            acc{splits,it,ce} = output{splits,it,ce}.accuracy;
            shuff_acc{splits,it,ce} = output{splits,it,ce}.shuff_accuracy;
            %get betas across all celltypes
            if ce == 4
                for bin = 1:length(output{splits,it,ce}.mdl)
                    betas{splits,it,bin} = output{splits,it,ce}.mdl{1,bin}.Beta;     
                end
            end
            clear output
            all_model_outputs{splits,it,ce} = mdl_param;
        end
    end
end
end

%convert output to matrix form for easier indexing
%% Save the output

%save info variables
%output{1,1,1}.info = info; %save in the first one

% mkdir([info.savepath '/SVM_' alignment.data_type '_' info.savestr])
% cd([info.savepath '/SVM_' alignment.data_type '_' info.savestr])
cd(strcat(base,'/decoding/'))

if mdl_param.field_to_predict == 1
    save_string = 'outcome';
elseif mdl_param.field_to_predict == 2
    save_string = 'choice';
elseif mdl_param.field_to_predict == 3
    save_string = 'sound_category';
elseif mdl_param.field_to_predict == 4
    save_string = 'photostim';
end


svm_info = info;
save(strcat(save_string,'_svm_info'),'svm_info','-v7.3');
save(strcat(save_string,'_betas'),'betas','-v7.3');
save(strcat(save_string,'_all_model_outputs'),'all_model_outputs','-v7.3');
save(strcat(save_string,'_acc'),'acc','-v7.3');
save(strcat(save_string,'_shuff_acc'),'shuff_acc','-v7.3');


%SAVE SVM OUTPUT! TOO LARGE!!!!!!!!!!
% save(strcat(save_string,'_output'),'output','-v7.3');



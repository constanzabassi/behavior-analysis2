% function roc_analysis (imaging_st
%% Compute choice preference for each neuron at each time point during a trial (only correct trials)

roc_mdl.frames = 131:141; %using 30 frames before turn onset
doChoicePref=0;
%1) get correct trials only (match left and right correct trials)
%2) align data (include datapoints up to turning point
%3) compute ROC

for m = 1%:length(imaging_st)
    count = 0;
    m
    %mdl_param.mouse = m;
    ex_imaging = imaging_st{1,m};
        
    [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
    [aligned_imaging,~,~] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
    
    [~, condition_array_trials] = divide_trials (ex_imaging); %divide trials into all possible conditions
    
    [selected_trials,lc,rc] = get_balanced_correct_trials(condition_array_trials); %balances left and right choice for correct 
    %left is ipsi, right is contra 
    ipsiTrs = lc;
    contraTrs = rc;

    %save trials used
    all_lc{m} = lc;
    all_rc{m} = rc;

    % initiate variables
    choicePref_all = NaN(numfrs, size(aligned_imaging, 2)); %frames x neurons
    targets = [zeros(numfrs, length(ipsiTrs)), ones(numfrs, length(contraTrs))]; %frames x trials

    %update aligned imaging to contain specific frames
    new_aligned_imaging = aligned_imaging(:,:,roc_mdl.frames);
    numfrs = size(new_aligned_imaging, 3); %frames


    for cel = 1:size(aligned_imaging, 2) %loop for cell
        cel
        traces_i = squeeze(new_aligned_imaging(ipsiTrs, cel, :)); % trials x frames
        traces_c = squeeze(new_aligned_imaging(contraTrs, cel, :)); % trials x frames

        outputs = [traces_i; traces_c]; % ipsi is asigned 0 and contra is asigned 1 in "targets". so assumption is ipsi response is lower than contra. so auc>.5 (choicePref>0) happens when ipsi resp<contra, and auc<.5 (choicePref<0) happens when ipsi>contra.
        outputs = outputs'; %transpose so it is trials x frames

        %compute ROC
        [tpr,fpr,thresholds] = roc(targets,outputs); % 

        if numfrs > 1
            % auc = trapz([0, fpr{fr}, 1], [0, tpr{fr}, 1]); % choice pref measure for each neuron at each frame
            auc = cellfun(@(x,y)trapz([0, x, 1], [0, y, 1]), fpr, tpr); % [fpr, tpr] = [0 0] and [1 1] will be always valid and you need them to measure auc correctly.
        else
            auc = trapz([0, fpr, 1], [0, tpr, 1]);
        end
        
        if doChoicePref==1 % otherwise we go with values of auc.
            choicePref =  2*(auc-0.5);
        else % we are interested in auc values 
            choicePref = auc;
        end
        %     figure; plot(choicePref) % look at choicePref for neuron in over time (all frames)
        choicePref_all(:,cel) = choicePref; % frames x neurons
    end

    %save variables across datasets
    choice_Pref{m} = choicePref_all;
    
end 
roc_mdl.lc = all_lc;
roc_mdl.rc = all_rc;
figure(1);clf;plotroc(targets,outputs);

%%
auc_values = choicePref_all%(11,:);
% % Create a kernel density estimate
% [f, x] = ksdensity(auc_values);
% 
% % Normalize to get the fraction of neurons
% fraction_of_neurons = f / sum(f);
% 
% % Plotting the line
% figure;
% plot(x, fraction_of_neurons, 'LineWidth', 2);
% 
% % Adding labels and title
% xlabel('AUC Values');
% ylabel('Fraction of Neurons');
% title('Fraction of Neurons vs AUC Values');

% Plotting the histogram
%figure;
histogram(auc_values, 'Normalization', 'probability', 'EdgeColor', 'w', 'LineWidth', 2);

% Adding labels and title
xlabel('AUC Values');
ylabel('Fraction of Neurons');
title('Fraction of Neurons vs AUC Values');
hold off
%% SHUFFLE TARGET LABELS!
if shuff == 1
     choicePref_all_shuff = nan([size(choicePref_all), roc_mdl.shuff_num]); % frames x neurons x num shuffles

    for num_shuff = 1:roc_mdl.shuff_num
        num_shuff
        for m = 1%:length(imaging_st)
            count = 0;
            m
            %mdl_param.mouse = m;
            ex_imaging = imaging_st{1,m};
                
            [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
            [aligned_imaging,~,~] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
            
            [~, condition_array_trials] = divide_trials (ex_imaging); %divide trials into all possible conditions
            
            [selected_trials,lc,rc] = get_balanced_correct_trials(condition_array_trials); %balances left and right choice for correct 
            %left is ipsi, right is contra 
            ipsiTrs = lc;
            contraTrs = rc;
        
            %save trials used
            roc_mdl.lc = lc;
            roc_mdl.rc = rc;
            
            % initiate variables
            % shuffle tr labels, keeping the number of ipsi and contra untouched!
            targets = [zeros(numfrs, length(ipsiTrs)), ones(numfrs, length(contraTrs))]; %frames x trials            
            shuffLabels = randperm(size(targets,2)); %shuffle trial labels
            targets = targets(:,shuffLabels); 
            
        
            %update aligned imaging to contain specific frames
            new_aligned_imaging = squeeze(mean(aligned_imaging(:,:,roc_mdl.frames),3));
            numfrs = 1;%size(new_aligned_imaging, 3); %frames
        
        
            for cel = 1:size(aligned_imaging, 2) %loop for cell
                cel
                traces_i = squeeze(new_aligned_imaging(ipsiTrs, cel, :)); % trials x frames
                traces_c = squeeze(new_aligned_imaging(contraTrs, cel, :)); % trials x frames
        
                outputs = [traces_i; traces_c]; % ipsi is asigned 0 and contra is asigned 1 in "targets". so assumption is ipsi response is lower than contra. so auc>.5 (choicePref>0) happens when ipsi resp<contra, and auc<.5 (choicePref<0) happens when ipsi>contra.
                outputs = outputs'; %transpose so it is trials x frames
        
                %compute ROC
                [tpr,fpr,thresholds] = roc(targets,outputs); % 
        
                if numfrs > 1
                    % auc = trapz([0, fpr{fr}, 1], [0, tpr{fr}, 1]); % choice pref measure for each neuron at each frame
                    auc = cellfun(@(x,y)trapz([0, x, 1], [0, y, 1]), fpr, tpr); % [fpr, tpr] = [0 0] and [1 1] will be always valid and you need them to measure auc correctly.
                else
                    auc = trapz([0, fpr, 1], [0, tpr, 1]);
                end
                
                if doChoicePref==1 % otherwise we go with values of auc.
                    choicePref =  2*(auc-0.5);
                else % we are interested in auc values 
                    choicePref = auc;
                end
                %     figure; plot(choicePref) % look at choicePref for neuron in over time (all frames)
                choicePref_all(:,cel) = choicePref; % frames x neurons
            end
            choicePref_all_shuff(:,:,num_shuff) = choicePref_all; % frames x neurons x num shuffles
        end 
    end
end

    fprintf('%d %d %d: Size of choicePref_all_shfl (fr x units x samps)\n', size(choicePref_all_shfl))    
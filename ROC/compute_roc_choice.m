% function roc_analysis (imaging_st)
%% Compute choice preference for each neuron at each time point during a trial (only correct trials)

roc_mdl.frames = 110:140; %using 30 frames before turn onset
%1) get correct trials only (match left and right correct trials)
%2) align data (include datapoints up to turning point
%3) compute ROC

for m = 1:length(imaging_st)
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
    numfrs = 1;%length(roc_mdl.frames); %frames
    choicePref_all = NaN(numfrs, size(aligned_imaging, 2)); %frames x neurons
    auc_all = NaN(numfrs, size(aligned_imaging, 2)); %frames x neurons
    targets = [zeros(numfrs, length(ipsiTrs)), ones(numfrs, length(contraTrs))]; %frames x trials

    %update aligned imaging to contain specific frames
    new_aligned_imaging = squeeze(mean(aligned_imaging(:,:,roc_mdl.frames),3));
    


    for cel = 1:size(new_aligned_imaging, 2) %loop for cell
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
        
        auc_all(:,cel) = auc; % frames x neurons
        choicePref_all(:,cel) = 2*(auc-0.5); % frames x neurons
    end

    %save variables across datasets
    choice_Pref{m} = choicePref_all;
    roc_mdl.choice_Pref{m} = choicePref_all;
    roc_mdl.auc{m} = auc_all;
    %plot ROC for each dataset
%     figure;
    
    roc_plot = plotroc(targets,outputs);
    
end 
hold off
roc_mdl.lc = all_lc;
roc_mdl.rc = all_rc;


%%
%plot auc!
ex_mouse = 2;
possible_celltypes = fieldnames(all_celltypes{1,1});

auc_values = roc_mdl.auc{1,ex_mouse};%(1,:);

% Plotting the histogram
figure(7);clf;
hold on
for ce = 1:3
    histogram(auc_values(all_celltypes{1,ex_mouse}.(possible_celltypes{ce})), 'Normalization', 'probability', 'EdgeColor', 'w', 'FaceColor',plot_info.colors_celltype(ce,:),'LineWidth', 2,'binWidth',0.1);
end
hold off

% Adding labels and title
xlabel('AUC Values');
ylabel('Fraction of Neurons');
title('Fraction of Neurons vs AUC Values');
hold off

%% SHUFFLE TARGET LABELS!
if shuff == 1
    for m = 1:length(imaging_st)
        choicePref_all_shuff = nan([size(choice_Pref{m}), roc_mdl.shuff_num]); % frames x neurons x num shuffles
        auc_all_shuff = nan([size(choice_Pref{m}), roc_mdl.shuff_num]); % frames x neurons x num shuffles
        auc_all = [];choicePref_all = [];
        m
        for num_shuff = 1:roc_mdl.shuff_num
                num_shuff
            
            %mdl_param.mouse = m;
            ex_imaging = imaging_st{1,m};
                
            [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
            [aligned_imaging,~,~] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
            
            %load same trials used for real roc analysis
            ipsiTrs = roc_mdl.lc{1,m};
            contraTrs = roc_mdl.rc{1,m};
            
            % initiate variables
            % shuffle tr labels, keeping the number of ipsi and contra untouched!
            numfrs = 1;%length(roc_mdl.frames); %frames
            targets = [zeros(numfrs, length(ipsiTrs)), ones(numfrs, length(contraTrs))]; %frames x trials            
            shuffLabels = randperm(size(targets,2)); %shuffle trial labels
            targets = targets(:,shuffLabels); 
            
            %update aligned imaging to contain specific frames
            new_aligned_imaging = squeeze(mean(aligned_imaging(:,:,roc_mdl.frames),3));
            
        
            for cel = 1:size(new_aligned_imaging, 2) %loop for cell
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
                
                auc_all(:,cel) = auc; % frames x neurons
                choicePref_all(:,cel) = 2*(auc-0.5); % frames x neurons

            end
            %save variables across datasets
            choicePref_all_shuff(:,:,num_shuff) = choicePref_all; % frames x neurons x num shuffles
            auc_all_shuff(:,:,num_shuff) = auc_all;
            

        end 

        choicePref_shuff{m} = choicePref_all_shuff;
        roc_mdl.choice_Pref_shuff{m} = choicePref_all_shuff;
        roc_mdl.auc_shuff{m} = auc_all_shuff;
    
    end
    
end %goes with if statement

fprintf('%d %d %d: Size of choicePref_all_shuff (frames x cells x num shuffs)\n', size(choicePref_all_shuff));

%determine significant cells!!
if shuff == 1
    for m = 1:length(roc_mdl.auc)
        real_values = roc_mdl.choice_Pref{1,m};
        shuff_values = squeeze([roc_mdl.choice_Pref_shuff{1,m}(1,:,:)]);
        [pos_sig,neg_sig] = determine_sig_cells(real_values,shuff_values);
        roc_mdl.pos_sig{m} = find(pos_sig);
        roc_mdl.neg_sig{m} = find(neg_sig);
    end
end

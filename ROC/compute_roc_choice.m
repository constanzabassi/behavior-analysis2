function [roc_mdl] = compute_roc_choice (imaging_st,alignment,roc_mdl,info,plot_info,all_celltypes,shuff)
%% Compute choice preference for each neuron at each time point during a trial (only correct trials)

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
    
    [~,lc,rc] = get_balanced_correct_trials(condition_array_trials); %balances left and right choice for correct 
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
    figure;
    roc_plot = plotroc(targets,outputs);
    
end 
hold off
roc_mdl.lc = all_lc;
roc_mdl.rc = all_rc;


%%
%plot auc!
figure(50);clf;
[rows,columns] = determine_num_tiles(length(imaging_st));
tiledlayout(rows,columns);

hold on;
for m = 1:length(imaging_st)
ex_mouse = m;
% possible_celltypes = fieldnames(all_celltypes{1,1});

auc_values = roc_mdl.auc{1,ex_mouse};%(1,:);

% Plotting the histogram
nexttile

histogram(auc_values, 'Normalization', 'probability', 'EdgeColor', 'w', 'FaceColor',[0 0 0.5],'LineWidth', 2,'binWidth',0.1);


% hold on
% for ce = 1:3
%     histogram(auc_values(all_celltypes{1,ex_mouse}.(possible_celltypes{ce})), 'Normalization', 'probability', 'EdgeColor', 'w', 'FaceColor',plot_info.colors_celltype(ce,:),'LineWidth', 2,'binWidth',0.1);
% end
% hold off

% Adding labels and title
xlabel('AUC Values');
ylabel('Fraction of Neurons');
xlim([0 1])
title(info.mouse_date(m));

end
hold off

%% plot auc looking specified by celltypes!
figure(500);clf;
[rows,columns] = determine_num_tiles(length(imaging_st));
tiledlayout(rows,columns);
edges = 0.2:0.1:0.8;
possible_celltypes = fieldnames(all_celltypes{1,1});

hold on;
for m = 1:length(imaging_st)
    ex_mouse = m;
    
    auc_values = roc_mdl.auc{1,ex_mouse};%(1,:);
    
    % Plotting the histogram
    nexttile
    
    hold on
    for ce = 1:3
%         mean_data = mean(all_data(all_celltypes{1,m}.(possible_celltypes{ce}),:),2); %find mean for specified cells across all subsamples
%         [mean_prob]= get_hist(mean_data,edges);
    %     [across_prob] = get_hist(all_data(all_celltypes{1,m}.(possible_celltypes{ce}),:),edges);%cellfun(@(x) get_hist(x,edges),{all_data(all_celltypes{1,m}.(possible_celltypes{ce}),:)},'UniformOutput',false);%probability values for each cell across subsamples
          [mean_prob]= get_hist(auc_values(all_celltypes{1,m}.(possible_celltypes{ce})),edges);
          plot(edges,mean_prob,'color', plot_info.colors_celltype(ce,:),'LineWidth', 1.5)
    
    %     SEM= std(across_prob')/sqrt(size(across_prob,2)); %frames/num iterations
    %     shadedErrorBar(edges,mean_prob, SEM, 'lineProps',{'color', plot_info.colors_celltype(ce,:),'LineWidth', 1.5});end
    end
    hold off
    % Adding labels and title
    xlabel('AUC Values');
    ylabel('Fraction of Neurons');
%     xlim([0 1])
    title(info.mouse_date(m));

xline(0.5,'--k')
end

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
%                 cel
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

%save alignment parameters
roc_mdl.alignment = alignment;
roc_mdl.info = info;

mkdir([info.savepath '/ROC/' roc_mdl.savestr]);
cd([info.savepath '/ROC/' roc_mdl.savestr]);
save('roc_mdl','roc_mdl');
saveas(50,'AUC_across_mice.png');
saveas(500,'AUC_across_mice_celltypes.png');

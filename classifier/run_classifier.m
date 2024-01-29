%% SVM predict choice using cell type activity
function output = run_classifier(imaging_st,all_celltypes,mdl_param, alignment,plot_info)
possible_celltypes = fieldnames(all_celltypes{1,1});

for it = 1:num_iterations
    for m = 1:8
        count = 0;
        m
        for ce = 1:3
            count = count+1;
            mdl_param.mouse = m;
            ex_imaging = imaging_st{1,m};
            
            [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
            [aligned_imaging,imaging_array,align_info] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
            
            [all_conditions, condition_array_trials] = divide_trials (ex_imaging); %divide trials into all possible conditions
            %  condition_array_trials (trial_ids, correct or not, left or not, stim or not)
            
            % [train_imaging, test_imaging,all_trials] = split_imaging_train_test_cb(ex_imaging,condition_array_trials,0.7,0,0);
            
            mdl_param.mdl_cells = all_celltypes{1,m}.(possible_celltypes{ce}); %which cell type to use
            %subsample cells!
            sub_data = subsample_fun(data,num_observations_needed)
            
%             %use training data
%             % [align_info,alignment_frames,left_padding,right_padding] = find_align_info (train_imaging,30);
%             % [aligned_imaging,imaging_array,align_info] = align_behavior_data (train_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
%             % [all_conditions_t, condition_array_trials_t] = divide_trials (train_imaging); %divide trials into all possible conditions
            
            if count == 1 %keep the trials the same across cell types!
                selected_trials = subsample_trials_to_decorrelate_choice_and_category(ex_imaging,condition_array_trials);%(condition_array_trials_t);
            else
                mdl_param.selected_trials = selected_trials;
            end
            mdl_param.selected_trials = selected_trials;
    
            %get X and Y ready for classifier
            mdl_Y = condition_array_trials(find(mdl_param.selected_trials),3);%condition_array_trials_t(find(mdl_param.selected_trials),2); %get trained Y labels
            mdl_X = aligned_imaging(find(mdl_param.selected_trials),:,:);
            
            fprintf(['size Y : ' num2str(size(mdl_Y)) ' || size X : '  num2str(size(mdl_X)) '\n']);
            output{m,ce} = classify_over_time(mdl_X,mdl_Y, mdl_param);
        end
    end
end

%% make quick figure plots!
event_onsets = determine_onsets(left_padding,right_padding,[1:6]);
for m = 1:8
ex_mouse = m;
figure(m);clf;
subplot(2,1,1)
for ce = 1:3
    hold on; 
    title(info.mouse_date{1,m})

    plot(output{ex_mouse,ce}.accuracy,'color',plot_info.colors_celltypes(ce,:));
    plot(output{ex_mouse,ce}.shuff_accuracy,'color',[0.2 0.2 0.2]*ce);

    for i = 1:length(event_onsets)
        xline(event_onsets(i),'--k','LineWidth',1.5)
        if i == 4
            xline(event_onsets(i),'--k',{'turn onset'},'LineWidth',1.5)
        end
    end
yline(.5,'-k');
end
hold off

subplot(2,1,2)
for ce = 1:3
    hold on; 
    plot(smooth(output{ex_mouse,ce}.accuracy,3, 'boxcar'),'color',plot_info.colors_celltypes(ce,:));
    plot(smooth(output{ex_mouse,ce}.shuff_accuracy,3, 'boxcar'),'color',[0.2 0.2 0.2]*ce);

    for i = 1:length(event_onsets)
        xline(event_onsets(i),'--k','LineWidth',1.5)
        if i == 4
            xline(event_onsets(i),'--k',{'turn onset'},'LineWidth',1.5)
        end
    end
yline(.5,'-k');
end
hold off
movegui(gcf,'center')
end
%% SVM predict choice using cell type activity
% 1) align data
ex_mouse = 2;
mdl_param.mouse = ex_mouse;
%ex_imaging = imaging_st{1,ex_mouse};
alignment.data_type = 'deconv';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'

[align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
[aligned_imaging,imaging_array,align_info] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
event_onsets = determine_onsets(left_padding,right_padding,[1:6]);
[all_conditions, condition_array_trials] = divide_trials (ex_imaging); %divide trials into all possible conditions
%  condition_array_trials (trial_ids, correct or not, left or not, stim or not)

% [train_imaging, test_imaging,all_trials] = split_imaging_train_test_cb(ex_imaging,condition_array_trials,0.7,0,0);


mdl_param.mdl_cells = all_celltypes{1,ex_mouse}.pyr_cells; %choose cells; %which cell type to use
mdl_param.event_onset = 141; %relative to aligned data
mdl_param.frames_around = -140:90; %frames around onset 
mdl_param.bin = 3; %bin size in terms of frames
mdl_param.data_type = alignment.data_type;

%use training data
% [align_info,alignment_frames,left_padding,right_padding] = find_align_info (train_imaging,30);
% [aligned_imaging,imaging_array,align_info] = align_behavior_data (train_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
% [all_conditions_t, condition_array_trials_t] = divide_trials (train_imaging); %divide trials into all possible conditions

% selected_trials = subsample_trials_to_decorrelate_choice_and_category(condition_array_trials_t);
mdl_param.selected_trials = selected_trials;

%get X and Y ready for classifier
mdl_Y = condition_array_trials_t(find(mdl_param.selected_trials),2); %get trained Y labels
mdl_X = aligned_imaging(find(mdl_param.selected_trials),:,:);

fprintf(['size Y : ' num2str(size(mdl_Y)) ' || size X : '  num2str(size(mdl_X)) '\n']);
output_pyr_deconv = classify_over_time(mdl_X,mdl_Y, mdl_param);
%%
figure(5);clf;

subplot(2,1,1)
title([(info.mouse_date(ex_mouse)) ' z-scored dff'])
hold on; plot(output_pv_dff.accuracy,'-r');
plot(output_pv_dff.shuff_accuracy,'color',[0.7 0.7 0.7]);
plot(output_som_dff.accuracy,'-b');
plot(output_som_dff.shuff_accuracy,'color',[0.5 0.5 0.5]);
plot(output_pyr_dff.accuracy,'-g');
plot(output_pyr_dff.shuff_accuracy,'color',[0.3 0.3 0.3]);
for i = 1:length(event_onsets)
    xline(event_onsets(i),'--k','LineWidth',1.5)
end
yline(.5,'-k');
hold off

subplot(2,1,2)
title([(info.mouse_date(ex_mouse)) ' z-scored dff smoothed 3 frames'])
hold on; plot(smooth(output_pv_dff.accuracy,3, 'boxcar'),'-r');
plot(smooth(output_pv_dff.shuff_accuracy,3, 'boxcar'),'color',[0.7 0.7 0.7]);
plot(smooth(output_som_dff.accuracy,3, 'boxcar'),'-b');
plot(smooth(output_som_dff.shuff_accuracy,3, 'boxcar'),'color',[0.5 0.5 0.5]);
plot(smooth(output_pyr_dff.accuracy,3, 'boxcar'),'-g');
plot(smooth(output_pyr_dff.shuff_accuracy,3, 'boxcar'),'color',[0.3 0.3 0.3]);
for i = 1:length(event_onsets)
    xline(event_onsets(i),'--k','LineWidth',1.5)
end
yline(.5,'-k');
hold off

%
figure(6);clf;

subplot(2,1,1)
title([(info.mouse_date(ex_mouse)) ' z-scored deconv raw'])
hold on; plot(output_pv_deconv.accuracy,'-r');
plot(output_pv_dff.shuff_accuracy,'color',[0.7 0.7 0.7]);
plot(output_som_deconv.accuracy,'-b');
plot(output_som_deconv.shuff_accuracy,'color',[0.5 0.5 0.5]);
plot(output_pyr_deconv.accuracy,'-g');
plot(output_pyr_deconv.shuff_accuracy,'color',[0.3 0.3 0.3]);
for i = 1:length(event_onsets)
    xline(event_onsets(i),'--k','LineWidth',1.5)
end
yline(.5,'-k');
hold off

subplot(2,1,2)
title([(info.mouse_date(ex_mouse)) ' z-scored deconv smoothed 3 frames'])
hold on; plot(smooth(output_pv_deconv.accuracy,3, 'boxcar'),'-r');
plot(smooth(output_pv_deconv.shuff_accuracy,3, 'boxcar'),'color',[0.7 0.7 0.7]);
plot(smooth(output_som_deconv.accuracy,3, 'boxcar'),'-b');
plot(smooth(output_som_deconv.shuff_accuracy,3, 'boxcar'),'color',[0.5 0.5 0.5]);
plot(smooth(output_pyr_deconv.accuracy,3, 'boxcar'),'-g');
plot(smooth(output_pyr_deconv.shuff_accuracy,3, 'boxcar'),'color',[0.3 0.3 0.3]);
for i = 1:length(event_onsets)
    xline(event_onsets(i),'--k','LineWidth',1.5)
end
yline(.5,'-k');
hold off


function [aligned_data_updated, alignment, trial_info_vr_updated]= process_align_w_bad_frames(info,aligned_data,frames_used,trial_info_vr,alignment)
load('V:\Connie\results\opto_sound_2025\context\sound_info\active_all_trial_info.mat');
updated_structure = {};
aligned_data_updated = {};
aligned_data_updated_temp = {};

for dataset_index = 1:length(info.mouse_date)
fprintf('Processing dataset %d/%d...\n', dataset_index, length(info.mouse_date));
    ss = info.server{dataset_index};  % Assume serverid is a cell array.
    base_path = fullfile(num2str(ss), 'Connie', 'ProcessedData', info.mouse_date{dataset_index});
    
    %%% 1) Load Data %%%
    load(fullfile(base_path, 'alignment_info.mat'));
    current_file_lengths = [0,cumsum(cellfun(@(x) length(x), {alignment_info.frame_times}))];
    load(fullfile(base_path, 'context_stim', 'updated', 'context_tr.mat')); %trials separated by context
    load(fullfile(base_path, 'context_stim', 'updated', 'bad_frames.mat'));
    
    %%% 2) Select Appropriate Frames Variable %%%
    load(fullfile(base_path, 'VR', ['imaging.mat']));


    %%% Current mouse data
    current_trial_info = trial_info_vr{dataset_index};%all_trial_info(dataset_index).opto;
    current_trial_info_ctrl = all_trial_info(dataset_index).ctrl;

    current_bad_frames = bad_frames(context_tr{1,1},:); %stim
    current_bad_frames = bad_frames(context_tr{1,2},:); %ctrl
    current_frames_used = frames_used{dataset_index};
    check_bad_frames = [];
    frames_to_interp = [2,6];
    for trial = 1:size(aligned_data.deconv{1,dataset_index},1)
%         current_trial_id = trial_info_vr{dataset_index}(trial).trial_id;
%         current_frames = imaging(current_trial_id).frame_id+current_file_lengths(imaging(current_trial_id).file_num);
%         check_bad_frames = [check_bad_frames,current_frames_used(trial,60)+current_frames(1)];
        before_frames = 1:60 - frames_to_interp(1);
        after_frames = 60+frames_to_interp(2):size(current_frames_used,2);
        aligned_data_updated_temp.deconv = aligned_data.deconv{1, dataset_index}(:,:,[before_frames,after_frames]);
        aligned_data_updated_temp.dff = aligned_data.dff{1, dataset_index}(:,:,[before_frames,after_frames]);
    end
    figure(dataset_index);clf; imagesc(squeeze(mean(aligned_data_updated_temp.deconv)))
    part1 = alignment.event_onsets(1) - frames_to_interp(1);                % [1 x N]
    part2 = alignment.event_onsets(2:6) - sum(frames_to_interp);         % [5 x 1]
    alignment.event_onsets_updated = [part1(:); part2(:)];     % [N+5 x 1]


    %separate into stim and control
    [~,opto_trials] = intersect([trial_info_vr{1,dataset_index}(:).trial_id],[all_trial_info(1).opto(:).trial_id]);
    [~,ctrl_trials] = intersect([trial_info_vr{1,dataset_index}(:).trial_id],[all_trial_info(1).ctrl(:).trial_id]);

    aligned_data_updated.deconv{dataset_index}.stim = aligned_data_updated_temp.deconv(opto_trials,:,:);
    aligned_data_updated.dff{dataset_index}.stim = aligned_data_updated_temp.dff(opto_trials,:,:);

    aligned_data_updated.deconv{dataset_index}.ctrl = aligned_data_updated_temp.deconv(ctrl_trials,:,:);
    aligned_data_updated.dff{dataset_index}.ctrl = aligned_data_updated_temp.dff(ctrl_trials,:,:);

    trial_info_vr_updated(dataset_index).opto = trial_info_vr{1,dataset_index}(opto_trials);
    trial_info_vr_updated(dataset_index).ctrl = trial_info_vr{1,dataset_index}(ctrl_trials);


end

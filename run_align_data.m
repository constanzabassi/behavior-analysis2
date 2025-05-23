%% behavior analysis of datasets
% [all_celltypes,imaging_st,info,plot_info] = load_organized_datasets('V:\Connie\results\behavior\data_info'); 

%% 2)pool imaging data structure from multiple datasets and organize it
[all_celltypes,imaging_st,mouse,cat_imaging] = pool_imaging(info.mouse_date,info.server);
[imaging_st,info.eliminated_trials] = eliminate_trials(imaging_st,7,800);
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
alignment.data_type = 'deconv'; %'reward','turn','stimulus','ITI'
plot_info.xlabel_events = {'sound','sound','sound','turn','reward','ITI'};
alignment.events = {'sound','sound','sound','turn','reward','ITI'};
[aligned_data_all,all_conditions_all,num_trials,alignment, frames_used_per_mouse, aligned_data_structure, trial_info_all]= align_multiple_datasets_includeITI(imaging_st,alignment);

%% check bad_frames and concatenate based on them separate structure into stim and control!
[aligned_data_updated, alignment, trial_info_vr_updated]= process_align_w_bad_frames(info,aligned_data_structure,frames_used_per_mouse, trial_info_all,alignment);

%% save structure
save_dir = 'W:\Connie\results\VR2025\data_info';
mkdir(save_dir);
cd(save_dir);
save('aligned_data_structure','aligned_data_structure','-v7.3');
save('frames_used_per_mouse','frames_used_per_mouse');
save('trial_info_all','trial_info_all');
% save('alignment','alignment');

%% save structure that is organized
cd(save_dir);
save('aligned_data_updated','aligned_data_updated','-v7.3');
save('trial_info_vr_updated','trial_info_vr_updated');
save('alignment','alignment');



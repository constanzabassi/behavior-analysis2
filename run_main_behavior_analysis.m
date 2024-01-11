%% behavior analysis of datasets
addpath(genpath('C:\Code\Github\behavior-analysis'))

%1) choose datasets
info.mouse_date={'HA11-1R/2023-05-05','HA11-1R/2023-04-13','HA10-1L/2023-04-10','HA10-1L/2023-04-17','HA2-1L/2023-04-12','HA2-1L/2023-05-05','HA1-00/2023-06-29','HE4-1L1R\2023-08-24'}; %mice with behavioral responses ,'GS9-1L/2023-01-16','GS8-00/2022-12-20','HA13-1L/2023-02-24','GE3-00/2022-10-20','HA10-1L/2023-03-27-session2'

info.server = {'V:','V:','V:','V:','V:','V:','V:','W:'};%\\runyan-fs-01\Runyan2';
info.savepath = 'V:/Connie/results/VR';%'Y:\Connie\results\PVSOM_opto\lab_meetingmay2023'; %'Y:\Connie\results\opto_figs_sfn'

%% 2)pool imaging data structure from multiple datasets and organize it
[all_celltypes,imaging_st,mouse,cat_imaging] = pool_imaging(info.mouse_date,info.server);
 
%organize so that all mice are within one variable  
[num_cells,sorted_cells] = organize_pooled_celltypes(mouse,all_celltypes);

%% 3) heatmaps of average across all datasets! also plots sorted values based on last condition (correct/left/stim)

plot_info.min_max = [-0.25 1];
plot_info.sorting_type = 1; % 1 by time, any other number by max value
plot_info.xlabel = 'Frames';
plot_info.ylabel = 'Neurons';

alignment.data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'stimulus'; %'reward','turn','stimulus', 'ITI'
alignment.cell_type = 'pyr';

make_conditionheatmaps_celltypes(imaging_st,cat_imaging,alignment,plot_info,all_celltypes);
%make_conditionheatmaps_celltypes(imaging_st,[],alignment,plot_info,all_celltypes); %plots invidual datasets!


%% 4) plot invididual mice average across conditions with concatenated alignment
ex_imaging = imaging_st{1,7};
[align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
[aligned_imaging,imaging_array,align_info] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,data_type,'all');
event_onsets = determine_onsets(left_padding,right_padding,[1:6]);
[all_conditions, condition_array_trials] = divide_trials (ex_imaging); %divide trials into all possible conditions
figure(88);clf;
make_heatmap(squeeze(mean(aligned_imaging)),plot_info,event_onsets(1),event_onsets);

%% 5) plot heatmap averaged across datasets/ index into specific conditions
alignment.conditions = [1,8];
alignment.data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
alignment.number = [1:6]; %'reward','turn','stimulus'
alignment.cells = cellfun(@(x) x.pv_cells,all_celltypes,'UniformOutput',false);
figure(89);clf;
heatmaps_across_mice (imaging_st,plot_info,alignment,[]);



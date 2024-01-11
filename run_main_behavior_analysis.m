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

min_max = [-0.25 1];
sorting_type = 1; % 1 by time, any other number by max value
data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment_type = 'stimulus'; %'reward','turn','stimulus'
cell_type = 'som';

make_conditionheatmaps_celltypes(imaging_st,cat_imaging,alignment_type,data_type,sorting_type,min_max,all_celltypes,cell_type);
%make_conditionheatmaps_celltypes(imaging_st,[],alignment_type,data_type,sorting_type,min_max,all_celltypes,cell_type); %plots invidual datasets!


%% 4) plot invididual mice average across conditions with concatenated alignment
ex_imaging = imaging_st{1,7};
[align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
[aligned_imaging,imaging_array,align_info] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,data_type,'all');
event_onsets = determine_onsets(left_padding,right_padding,[1:6]);
[all_conditions, condition_array_trials] = divide_trials (ex_imaging); %divide trials into all possible conditions
figure(88);clf;
make_heatmap(squeeze(mean(aligned_imaging)),[-.25 1],1,event_onsets(1),event_onsets);

%% 5) plot heatmap averaged across datasets/ index into specific conditions
conditions = [6,8];
alignment.data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
alignment.number = [1:6]; %'reward','turn','stimulus'
cell_type = cellfun(@(x) x.som_cells,all_celltypes,'UniformOutput',false);
figure(89);clf;
heatmaps_across_mice (imaging_st,min_max,sorting_type,conditions,alignment,cell_type,[]);



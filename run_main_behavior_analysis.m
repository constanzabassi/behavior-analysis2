%% behavior analysis of datasets
addpath(genpath('C:\Code\Github\behavior-analysis'))

%1) choose datasets
info.mouse_date={'HA11-1R/2023-05-05','HA11-1R/2023-04-13','HA2-1L/2023-04-12','HA2-1L/2023-05-05','HA1-00/2023-06-29','HA1-00/2023-08-28','HE4-1L1R/2023-08-21','HE4-1L1R/2023-08-24'}; %mice with behavioral responses ,'GS9-1L/2023-01-16','GS8-00/2022-12-20','HA13-1L/2023-02-24','GE3-00/2022-10-20','HA10-1L/2023-03-27-session2'

info.server = {'V:','V:','V:','V:','V:','W:','W:','W:'};%\\runyan-fs-01\Runyan2';
info.savepath = 'V:/Connie/results/behavior';%'Y:\Connie\results\PVSOM_opto\lab_meetingmay2023'; %'Y:\Connie\results\opto_figs_sfn'

%% 2)pool imaging data structure from multiple datasets and organize it
[all_celltypes,imaging_st,mouse,cat_imaging] = pool_imaging(info.mouse_date,info.server);
[imaging_st,info.eliminated_trials] = eliminate_trials(imaging_st,7,800);

%organize so that all mice are within one variable  
[num_cells,sorted_cells] = organize_pooled_celltypes(mouse,all_celltypes);

save_info(info,all_celltypes,imaging_st,info.savepath);


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
ex_imaging = imaging_st{1,16};
alignment.data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'

[align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
[aligned_imaging,imaging_array,align_info] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
event_onsets = determine_onsets(left_padding,right_padding,[1:6]);
[all_conditions, condition_array_trials] = divide_trials (ex_imaging); %divide trials into all possible conditions
figure(88);clf;
make_heatmap(squeeze(mean(aligned_imaging)),plot_info,event_onsets(1),event_onsets);

%% 5) plot heatmap averaged across datasets/ index into specific conditions
alignment.conditions = [5,7];
alignment.data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
plot_info.min_max = [-0.5 2];
alignment.number = [1:6]; %'reward','turn','stimulus'
alignment.cells = cellfun(@(x) x.pyr_cells,all_celltypes,'UniformOutput',false);
figure(89);clf;
heatmaps_across_mice (imaging_st,plot_info,alignment,[]);

%% 5.5)figures for mellon fellowship

figure(90);clf;
colormap viridis
alignment.conditions = [5];
alignment.data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
plot_info.min_max = [-0.25 1.5];
alignment.number = [1:6]; %'reward','turn','stimulus'
alignment.cells = [cellfun(@(x) x.pyr_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.som_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.pv_cells,all_celltypes,'UniformOutput',false)];
alignment.title = {'PYR','SOM','PV'};
plot_info.xlabel = [];

save_data_directory = [info.savepath '\heatmaps'];%'W:\Connie\results\context_stim\spike_rates';%[];

heatmaps_across_mice_mellon (imaging_st,plot_info,alignment,[]);
heatmaps_all_celltypes (imaging_st,plot_info,alignment,[],save_data_directory);


if ~isempty(save_data_directory)
    mkdir(save_data_directory)
    cd(save_data_directory)

    image_string = strcat('heatmaps_condition_',num2str(alignment.conditions,3));
    saveas(90,[image_string '_datasets.svg']);
    saveas(90,[image_string '_datasets.fig']);
    saveas(90,[image_string '_datasets.pdf']);
end

%% 6) trying spatial binning
alignment.data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment.fields = [1:5,12];
alignment.spatial_percent = 2;
alignment.conditions = [5,7];

figure(90);clf;
tiledlayout(2,4)
hold on
for m = 1:length(imaging_st)
ex_imaging = imaging_st{1,m};
alignment.cell_ids = 1:num_cells(m);

[spatially_aligned_data,mean_data,trial_indices] = spatial_alignment(ex_imaging,alignment);

plot_info.min_max = [-0.1 1];
plot_info.sorting_type = 1; % 1 by time, any other number by max value
plot_info.xlabel = 'Position bin';
plot_info.ylabel = 'Neurons';

nexttile
make_heatmap(squeeze(nanmean(spatially_aligned_data)),plot_info,1);
spatially_aligned_data =[];
end
hold off

figure(91);clf;
mouse_data_conditions =heatmap_spatial_aligned_across_mice(imaging_st,alignment,plot_info);

%%
figure(92);clf;
plot_info.xlabel = 'Frames';
mouse_data_conditions2 = heatmaps_across_mice_celltypes (imaging_st,plot_info,alignment);
%% plot average traces of individual cells
ex_mouse = 9;
ex_imaging = imaging_st{1,ex_mouse};

alignment.conditions = [3,4]; %[5,7] is control
alignment.data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
alignment.number = [1:6]; %'reward','turn','stimulus'

[align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
[aligned_imaging,imaging_array,align_info] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
event_onsets = determine_onsets(left_padding,right_padding,[1:6]);
fieldss = fieldnames(ex_imaging(1).virmen_trial_info);
field_to_separate = {fieldss{1:2}};

[all_conditions, condition_array_trials] = divide_trials_updated (ex_imaging,field_to_separate); %divide trials into specific conditions

for c = 1:7 %[a,b] =max(output{1,1,2}.mdl{140}.Beta); 
    cel_id = (c);%roc_mdl.pos_sig{1,ex_mouse}(c);
    figure(c);clf;
    individual_cell_plots(aligned_imaging, cel_id, all_conditions,alignment,event_onsets)
end


%%
figure(122);clf;
tiledlayout(3,3)
hold on
for m = 1:8
    nexttile
    imaging = imaging_st{1,m};
    plot_xy_position(imaging);
end
hold off

%% dynamics characterization, determine the peak activity across datasets across all trial types





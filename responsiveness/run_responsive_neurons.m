% 1) load data
% [all_celltypes,imaging_st,info,plot_info] = load_organized_datasets('V:\Connie\results\behavior_updated\data_info'); 
%%
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
alignment.data_type = 'deconv'; %'reward','turn','stimulus','ITI'
plot_info.xlabel_events = {'sound','sound','sound','turn','reward','ITI'};

%% align all datasets inside imaging st
[aligned_data_all,all_conditions_all,num_trials,alignment]= align_multiple_datasets(imaging_st,alignment);

%% normalize data?
params.normalization = 'zscore'; %'zscore', 'norm', 'center', 'scale', 'range', or 'medianiqr'
params.smooth = {}; %{frames,'boxcar' or 'gauss'} or {}
all_aligned = organize_aligned_datasets(aligned_data_all,params);

%% define stimulus, turn, reward, ITI periods

task_period = define_trial_task_periods(alignment);

%% responsive neurons- compares activity within and outside task period (same number of frames)
params.num_shuff = 100;
params.p_thr = 0.05; 
for m = 1:length(all_aligned)
    m
    current_aligned_dataset = all_aligned{1,m};
    [responsive_neuron{m},responsive_neuron2{m},neuron_zscores{m}] = find_responsive_neurons(task_period,current_aligned_dataset,params);
end
%% unpack responsive and put into cell type categories
num_responsive = unpack_responsive(responsive_neuron2, all_celltypes); %datasets,task_periods,celltypes
%% make plot
boxplot_percent_responsive(num_responsive,plot_info,info,1); %last is save or no
cd([info.savepath '/responsive'])
save('num_responsive','num_responsive');
save('responsive_neuron2','responsive_neuron2');

%% testing other methods
params.num_shuff = 1000;
params.num_boot = 1000;
params.p_thr = 0.05;
celltype_list= {'pyr_cells','som_cells','pv_cells'};
[z_scores, pvals] = bootstrap_zscore_celltypes(all_aligned, all_celltypes, task_period, celltype_list, params.num_boot);

plot_zscore_comparisons(z_scores, pvals, {'pyr_cells','som_cells','pv_cells'}, 1, []); %'./results/responsive_cells'

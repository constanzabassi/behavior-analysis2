alignment.type = 'all'; %'reward','turn','stimulus','ITI'
alignment.data_type = 'dff'; %'reward','turn','stimulus','ITI'

%% align all datasets inside imaging st
[aligned_data_all,all_conditions_all,num_trials]= align_multiple_datasets(imaging_st,alignment);

%% normalize data?
params.normalization = 'zscore'; %'zscore', 'norm', 'center', 'scale', 'range', or 'medianiqr'
params.smooth = {}; %{frames,'boxcar' or 'gauss'} or {}
all_aligned = organize_aligned_datasets(aligned_data_all,params);

%% define stimulus, turn, reward, ITI periods
alignment.left_padding = [6     1     1    30     4     1]; 
alignment.right_padding = [33    33    33    30    23    80]; 

task_period = define_trial_task_periods(alignment);

%% responsive neurons- compares activity within and outside task period (same number of frames)
params.num_shuff = 100;
params.p_thr = 0.05; 
for m = 1:length(all_aligned)
    m
    current_aligned_dataset = all_aligned{1,m};
    [responsive_neuron{m},responsive_neuron2{m}] = find_responsive_neurons(task_period,current_aligned_dataset,params);
end
%% unpack responsive and put into cell type categories
num_responsive = unpack_responsive(responsive_neuron, all_celltypes); %datasets,task_periods,celltypes
%% make plot
boxplot_percent_responsive;

%% FIGURE ONE?
%% PLOT HEATMAP FOR SPECIFIC CONDITION

alignment.conditions = []; %empty to run all conditions [5:8];
alignment.data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
plot_info.min_max = [-0.25 1];
alignment.number = [1:6]; %'reward','turn','stimulus'
alignment.cells = [cellfun(@(x) x.pyr_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.som_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.pv_cells,all_celltypes,'UniformOutput',false)];
alignment.title = {'PYR','SOM','PV'};
plot_info.xlabel = [];
plot_info.sorting_type = 1;
plot_info.ylabel = 'Frames';
plot_info.xlabel_events = {'sound','sound','sound','turn','reward','ITI'};
bin_size = 3;

% figure(90);clf;
% colormap viridis
% heatmaps_all_celltypes (imaging_st,plot_info,alignment,[],[info.savepath '\heatmaps']);
% set(gcf,'Position',[23 177 500 420]);
% 
% % make plot of grand avg of dff across celltypes!
% plot_traces_across_celltypes(imaging_st,all_celltypes,alignment,dynamics_info,plot_info,info);


figure(90);clf;
colormap viridis
%plot heatmaps and grand avg
mouse_data_conditions = heatmaps_avg_combined_all_celltypes (imaging_st,plot_info,alignment,[],[info.savepath '\heatmaps'],bin_size);%last number is bin size
figure(90);clf;
colormap viridis
mouse_data_conditions = heatmaps_avg_combined_all_celltypes_extra_fields (imaging_st,plot_info,alignment,[],[info.savepath '\heatmaps'],bin_size,'y_velocity',[]);

% alignment.number = 6; %just ITI
% alignment.type = 'ITI';
% mouse_data_conditions = scatter_avg_combined_all_celltypes_extra_fields (imaging_st,plot_info,alignment,[],[],bin_size,'y_velocity',[]);
%% DYNAMICS PLOT OF FRACTION OF CELLS
plot_info.colors_celltype = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04 % red  
                            0 0 0.5]; %dark purple

dynamics_info.bin_size = 5;
dynamics_info.conditions = []; %1:8 for stim or empty to do all conditions!
[dynamics_info.max_cel_avg,dynamics_info.new_onsets,dynamics_info.binss] = peak_times_avg (imaging_st,alignment,dynamics_info);
%[dynamics_info.max_cel_mode,dynamics_info.freq,~, dynamics_info.binss,dynamics_info.new_onsets] = fraction_dynamics (imaging_st,alignment,dynamics_info); 
  
plot_frc_dynamics(dynamics_info.max_cel_avg,dynamics_info,all_celltypes,plot_info, info,0); %last is save or not


%% make cdf plot using the peaks found
dynamics_info.bin_size = 1;
[dynamics_info.max_cel_avg,dynamics_info.new_onsets,dynamics_info.binss] = peak_times_avg (imaging_st,alignment,dynamics_info);
% p_cdf =  cdf_peak_times(dynamics_info.max_cel_mode,dynamics_info,all_celltypes,plot_info,[]);
[dynamics_info.p_cdf,dynamics_info.KW_peaks] =  cdf_peak_times(dynamics_info.max_cel_avg,dynamics_info,all_celltypes,plot_info,info);

%% define stimulus, turn, reward, ITI periods
% alignment.left_padding = [6     1     1    30     4     1]; 
% alignment.right_padding = [33    33    33    30    23    80]; 
% 
% task_period = define_trial_task_periods(alignment);
% 
% 
% alignment.conditions = [1:8];
% 
% figure(90);clf;
% colormap viridis
% heatmaps_all_celltypes (imaging_st,plot_info,alignment,[],[]);
% set(gcf,'Position',[23 177 683 420]);



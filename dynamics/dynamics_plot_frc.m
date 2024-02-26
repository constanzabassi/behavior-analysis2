%% FIGURE ONE?
%% PLOT HEATMAP FOR SPECIFIC CONDITION

alignment.conditions = [5];
alignment.data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
plot_info.min_max = [-0.25 1.5];
alignment.number = [1:6]; %'reward','turn','stimulus'
alignment.cells = [cellfun(@(x) x.pyr_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.som_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.pv_cells,all_celltypes,'UniformOutput',false)];
alignment.title = {'PYR','SOM','PV'};
plot_info.xlabel = [];

figure(90);clf;
colormap viridis
heatmaps_all_celltypes (imaging_st,plot_info,alignment,[],[info.savepath '\heatmaps']);
set(gcf,'Position',[23 177 683 420]);


%% DYNAMICS PLOT OF FRACTION OF CELLS
plot_info.colors_celltype = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04 % red  
                            0 0 0.5]; %dark purple
dynamics_info.bin_size = 3;
dynamics_info.conditions = 5; %1:8 for stim or empty to do all conditions!
[dynamics_info.max_cel_mode,dynamics_info.freq,~, dynamics_info.binss,dynamics_info.new_onsets] = fraction_dynamics (imaging_st,alignment,dynamics_info); 

plot_frc_dynamics(dynamics_info,all_celltypes,plot_info, info,1); %last is save or not

%% make plot of grand avg of dff across celltypes!

plot_traces_across_celltypes(imaging_st,all_celltypes,alignment,dynamics_info,plot_info,info);

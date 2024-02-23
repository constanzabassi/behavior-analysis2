%% DYNAMICS PLOT OF FRACTION OF CELLS
plot_info.colors_celltype = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04 % red  
                            0 0 0.5]; %dark purple

bin_size = 3;
[max_cel_mode,freq,~, binss,new_onsets] = fraction_dynamics (imaging_st,alignment,bin_size); %last number is bin size

plot_frc_dynamics(max_cel_mode,all_celltypes,binss,new_onsets,plot_info, info,1); %last is save or not

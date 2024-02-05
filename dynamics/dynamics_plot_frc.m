
bin_size = 3;
[max_cel_mode,freq,~, binss,new_onsets] = fraction_dynamics (imaging_st,alignment,bin_size); %last number is bin size

plot_frc_dynamics(max_cel_mode,all_celltypes,binss,new_onsets,plot_info, info,1); %last is save or not

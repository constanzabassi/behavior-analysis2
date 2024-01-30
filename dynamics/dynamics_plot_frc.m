[max_cel_mode,freq,~, binss,new_onsets] = fraction_dynamics (imaging_st,alignment,3);

plot_frc_dynamics(max_cel_mode,all_celltypes,binss,new_onsets,plot_info, info,0); %last is save or not

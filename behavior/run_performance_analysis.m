%% performance analysis

behav_param.num_iterations = 5;
behav_param.fields_to_balance = [3,4];%{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4
alignment.data_type = 'dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'

performance = get_opto_performance(imaging_st_cat,behav_param,alignment);

%% make plots

[behav_param.p_val] = plot_performance(performance(:,[1:8,10:24]),[info.savepath '/performance_analysis']);
save('behav_param','behav_param');

plot_performance_all_bar(performance,[info.savepath '/performance_analysis']);
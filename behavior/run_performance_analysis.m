%% performance analysis

behav_param.num_iterations = 5;
behav_param.fields_to_balance = [3,4];%{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4
alignment.data_type = 'dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'

performance = get_opto_performance(imaging_st,behav_param,alignment);

%% make plots
%take control mouse out
chosen_mice = setdiff(1:length(imaging_st),find(strcmp(info.mouse_date,'HE1-00\2023-05-30')));

[behav_param.p_val] = plot_performance(performance(:,chosen_mice),[info.savepath '/performance_analysis']);
save('behav_param','behav_param');

plot_performance_all_bar(performance,[info.savepath '/performance_analysis']);
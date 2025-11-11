%% compare cellypes during active context
event_names = {'sound_category','choice','outcome'};
do_passive = 0;
for event = 1:length(event_names)
    %full population plots
    
    savepath = ['W:\Connie\results\Bassi2025\fig2\SVM_1\full_population\' event_names{event} '\']; 
    plot_final_svm_traces_boxplots('full',event_names{event},do_passive,savepath);
    
    %nmatch population plots
    savepath = ['W:\Connie\results\Bassi2025\fig2\SVM_1\' event_names{event} '\']; %['V:\Connie\results\SVM_1_wtop\active_passive\' info.task_event_type '\'];%['V:\Connie\results\SVM_1\' info.task_event_type '\'];
    plot_final_svm_traces_boxplots('nmatch',event_names{event},do_passive,savepath);

end

%% compare active/passive stim/ctrl

% 'W:\Connie\results\Bassi2025\fig2\SVM_1\opto_ctrl'
event_names = {'sound_category'};
do_passive = 1;
for event = 1:length(event_names)
    %nmatch population plots (comaparing active and passive)
    savepath = ['W:\Connie\results\Bassi2025\fig2\SVM_1\' event_names{event} '\'];
    plot_final_svm_traces_boxplots('nmatch',event_names{event},do_passive,savepath); %plots the All population
    
    %comparing stim vs control!
    savepath = ['W:\Connie\results\Bassi2025\fig2\SVM_1\opto_ctrl'];
    plot_final_svm_traces_boxplots('stimctrl',event_names{event},do_passive,savepath); %plots the All population
end

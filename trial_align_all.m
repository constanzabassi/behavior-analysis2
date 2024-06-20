alignment.conditions = []; %empty to run all conditions
alignment.data_type = 'dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
plot_info.min_max = [-0.25 1];
alignment.number = [1:6]; %'reward','turn','stimulus'
% alignment.cells = [cellfun(@(x) x.pyr_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.som_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.pv_cells,all_celltypes,'UniformOutput',false)];
alignment.title = {'PYR','SOM','PV'};


for m = 1:size(imaging_st,2)
    m
    imaging = imaging_st{1,m};
    [all_conditions, condition_array_trials] = divide_trials (imaging); %divide trials into all possible conditions   
    [align_info,alignment_frames,left_padding,right_padding] = find_align_info (imaging,30);
    [aligned_imaging] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
    aligned_task_all{m} = aligned_imaging;

    for c = 1:8
        aligned_task{m} = aligned_imaging(all_conditions{c,1},:,:); %use specified trials in the condition array
        aligned_task_conditions{m,c} = aligned_task{m};
    end


%     aligned_task_conditions{m} = align_data_per_condition(imaging,all_conditions,alignment,[]);
% %     aligned_task_conditions{m} = align_data_per_condition(data_matrix,all_conditions,alignment,align_info_input,varagin)
end

task_info.condition_labels = [all_conditions{:,3}];
task_info.event_onsets = event_onsets;

if ~isempty(info.savepath)
    
    cd([info.savepath '/data_info'])

    save('task_info','task_info');
    save('aligned_task','aligned_task');
    save('aligned_task_conditions','aligned_task_conditions', '-v7.3');
end

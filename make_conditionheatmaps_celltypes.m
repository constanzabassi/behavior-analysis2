function make_conditionheatmaps_celltypes(imaging_st,alignment_type,data_type,sorting_type,min_max,all_celltypes,celltype_id)
for m = 1:length(imaging_st)
    imaging = imaging_st{1,m};
    [all_conditions, condition_array_trials] = divide_trials (imaging); %divide trials into all possible conditions
    possible_celltypes = fieldnames(all_celltypes{1,1});
    chosen_celltype = contains(possible_celltypes,celltype_id);
    celltypes_permouse = all_celltypes{1,m}.(possible_celltypes{chosen_celltype});
    imaging_conditions = align_data_per_condition(imaging,all_conditions,data_type,alignment_type,celltypes_permouse); %align data to event
    figure(m*100);clf;
    make_condition_heatmaps (imaging_conditions,min_max,sorting_type,all_conditions,alignment_type); %plot mean for each condition
end

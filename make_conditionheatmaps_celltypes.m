function make_conditionheatmaps_celltypes(imaging_st,cat_imaging,alignment_type,data_type,sorting_type,min_max,all_celltypes,celltype_id)
    if isempty(cat_imaging) %per dataset
        for m = 1:length(imaging_st)
            imaging = imaging_st{1,m};
            [all_conditions, condition_array_trials] = divide_trials (imaging); %divide trials into all possible conditions
            possible_celltypes = fieldnames(all_celltypes{1,1});
            chosen_celltype = contains(possible_celltypes,celltype_id);
            celltypes_permouse = all_celltypes{1,m}.(possible_celltypes{chosen_celltype});
            imaging_conditions = align_data_per_condition(imaging,all_conditions,data_type,alignment_type,[],celltypes_permouse); %align data to event
            figure(m*100);clf;
            make_condition_heatmaps (imaging_conditions,min_max,sorting_type,all_conditions,alignment_type,[]); %plot mean for each condition
        end
    else %across all datasets!

        % align data across all datasets using same set of info (if
        % concatenated together)
        align_info = find_align_info(cat_imaging,30);

        possible_celltypes = fieldnames(all_celltypes{1,1});
        chosen_celltype = contains(possible_celltypes,celltype_id);
        for m = 1:length(all_celltypes)
            imaging = imaging_st{1,m};
            [all_conditions, condition_array_trials] = divide_trials (imaging); %divide trials into all possible conditions
            celltypes_permouse{m} = all_celltypes{1,m}.(possible_celltypes{chosen_celltype});
            imaging_conditions{m} = align_data_per_condition(imaging,all_conditions,data_type,alignment_type,align_info,celltypes_permouse{m}); %align data to event         
        end
        [mean_conditions,imaging_conditions_updated] = find_mean_imaging_conditions(imaging_conditions);
        figure(101);clf;
        make_condition_heatmaps (imaging_conditions_updated,min_max,sorting_type,all_conditions,alignment_type,[]); %plot mean for each condition
    
        figure(102);clf;
        %find alignment event
        align_fieldnames = fieldnames(align_info);
        alignment_event_index = find(strcmp(fieldnames(align_info),strcat(alignment_type,'_onset')));
        alignment_event_onset = align_info.(align_fieldnames{alignment_event_index});
        sorted_values = sort_values (mean_conditions(end,:,:),sorting_type, alignment_event_onset);
        make_condition_heatmaps (imaging_conditions_updated,min_max,sorting_type,all_conditions,alignment_type,sorted_values); %plot mean for each condition
end


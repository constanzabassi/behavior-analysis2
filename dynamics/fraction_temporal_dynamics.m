function output = fraction_temporal_dynamics(imaging_st,all_celltypes,alignment)

for ce = 1:3
    for m = 1:length(imaging_st)
        imaging = imaging_st{1,m};
        [all_conditions, condition_array_trials] = divide_trials (imaging); %divide trials into all possible conditions
        possible_celltypes = fieldnames(all_celltypes{1,1});
        celltypes_permouse = all_celltypes{1,m}.(possible_celltypes{ce});

        %using all trials!
        [align_info,alignment_frames,left_padding,right_padding] = find_align_info (imaging,30);
        [aligned_imaging,imaging_array,align_info] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
        
        [y_axis,inds] = max(aligned_imaging(:,1:end),[],2);
        [~,value] = sort(inds,'ascend'); %sort(y_axis,'ascend');
        imagesc(data1(value,:)); %by time

    end
end

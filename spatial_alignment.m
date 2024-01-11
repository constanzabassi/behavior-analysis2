function [spatially_aligned_data,mean_data,trial_indices] = spatial_alignment(imaging,alignment)
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!

imaging_array = [imaging(good_trials).movement_in_imaging_time]; %convert to array for easier indexing

%figure out how to bin the data!
maze_length = round(max(imaging_array(1).y_position),-2);
bin_width = maze_length*alignment.spatial_percent*0.01; %how many units inside a spatial bin

%get fields and align appropriate ones
fns = fieldnames(imaging_array);
trial_indices = {};

for vr_trial = 1:length(good_trials)
    start_trial = imaging_array(vr_trial).y_position(1);
    end_trial = imaging_array(vr_trial).y_position(imaging_array(vr_trial).turn_frame);
    if isnan(end_trial)
        end_trial = imaging_array(vr_trial).y_position(imaging_array(vr_trial).turn_frame-1);
    end

    %interpolate NaNs in y_position
    non_nan_indices = find(~isnan(imaging_array(vr_trial).y_position));
    y_position_current = interp1(non_nan_indices, imaging_array(vr_trial).y_position(non_nan_indices),1:numel(imaging_array(vr_trial).y_position),'linear');
    bin_edges = start_trial:bin_width:end_trial;
    y_position_current = y_position_current(1:imaging_array(vr_trial).turn_frame);

    %perform spatial binning
    [bin_counts,bin_centers] = histcounts(y_position_current, bin_edges);
    % only use good bins
    bad_bins = find(bin_counts == 0);
    bin_counts(bad_bins) = [];
    bin_centers(bad_bins) = [];
    bin_edges(bad_bins) = [];
    %calculate the mean data for each bin
    mean_data = zeros(length(good_trials),length(alignment.fields),numel(bin_centers));
    spatially_aligned_data = zeros(length(good_trials),length(alignment.cell_ids),numel(bin_centers));
    
    for bin = 1:numel(length(alignment.fields),bin_centers)
            if bin <numel(bin_centers)
                indices_in_bin = find(y_position_current >= bin_edges(bin) & y_position_current < bin_edges(bin + 1));
                trial_indices{vr_trial,bin} = indices_in_bin;
               spatially_aligned_data(vr_trial,:,bin) = nanmean(imaging(good_trials(vr_trial)).(alignment.data_type)(alignment.cell_ids,indices_in_bin),2);
    
                for f = 1:length(alignment.fields)
                    field = alignment.fields(f);
                    current_field = {imaging_array.(fns{field})};   
                    mean_data(vr_trial,f,bin) = nanmean(current_field{1,vr_trial}(indices_in_bin));    
                end
            else
                indices_in_bin = find(y_position_current >= bin_edges(bin));
                trial_indices{vr_trial,bin} = indices_in_bin;
                spatially_aligned_data(vr_trial,:,bin) = nanmean(imaging(good_trials(vr_trial)).(alignment.data_type)(alignment.cell_ids,indices_in_bin),2);
                for f = 1:length(alignment.fields)
                    field = alignment.fields(f);
                    current_field = {imaging_array.(fns{field})};
                    mean_data(vr_trial,f,bin) = nanmean(current_field{1,vr_trial}(indices_in_bin));         
                end
            end
    end

    %Continue alignment in time! from turn onset
end

end




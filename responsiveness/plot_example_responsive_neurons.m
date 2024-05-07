% function plot_example_neurons(dataset,imaging,all_frames,example_cells)

empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
imaging_dff = [imaging(good_trials).z_dff]; %convert to array for easier indexing
imaging_behavior = [imaging(good_trials).movement_in_imaging_time]; %convert to array for easier indexing

total_frames_used_per_trial = cellfun(@length,{imaging_behavior.frame_indices});
total_frames_cumulative = cumsum(total_frames_used_per_trial);
total_frames_event(1,:) = cellfun(@length,{imaging_behavior.maze_frames});
total_frames_event(2,:) = cellfun(@length,{imaging_behavior.reward_frames});
total_frames_event(3,:) = cellfun(@length,{imaging_behavior.iti_frames});

limit_frames(1,:) = [1,total_frames_cumulative(1:end-1)+1]; %start
limit_frames(2,:) = total_frames_cumulative; %end

temp = [];
temp2 = [];
temp3 = [];
ex_trials = 1:6;
for t = ex_trials
    temp = [temp,limit_frames(1,t):limit_frames(1,t)+total_frames_event(1,t)-1];
    temp2 = [temp2,limit_frames(1,t)+total_frames_event(1,t):limit_frames(1,t)+total_frames_event(1,t)+total_frames_event(2,t)-1];
    temp3 = [temp3,limit_frames(1,t)+total_frames_event(1,t)+total_frames_event(2,t):limit_frames(2,t)];
end
%%
figure(23);clf;
num_rows = length(ex_neurons);
num_columns = 1;

hold on
for nn = 1:num_rows

    n = ex_neurons(nn);
    
    subplot(num_rows, num_columns, nn);
    hold on
    % Highlight frames specified in temp
    
    
    ylims = ylim; % Get y-axis limits for drawing boxes
    temp_frames = unique(temp);
    for frame = temp_frames
        frame_idx = frame - limit_frames(1, ex_trials(1)) + 1;
        rectangle('Position', [frame_idx, ylims(1), 1, ylims(2)-ylims(1)], 'FaceColor', [0.7 0.9 1 0.5], 'EdgeColor', 'none'); % Adjust the box color as needed
    end

    temp_frames = unique(temp2);
    for frame = temp_frames
        frame_idx = frame - limit_frames(1, ex_trials(1)) + 1;
        rectangle('Position', [frame_idx, ylims(1), 1, ylims(2)-ylims(1)], 'FaceColor', [0.7 0.6 1 0.5], 'EdgeColor', 'none'); % Adjust the box color as needed
    end

    temp_frames = unique(temp3);
    for frame = temp_frames
        frame_idx = frame - limit_frames(1, ex_trials(1)) + 1;
        rectangle('Position', [frame_idx, ylims(1), 1, ylims(2)-ylims(1)], 'FaceColor', [0.9 1 0.7 0.5], 'EdgeColor', 'none'); % Adjust the box color as needed
    end
    

    plot(imaging_dff(n,limit_frames(1,ex_trials(1)):limit_frames(1,ex_trials(end)+2)),'color','k','LineWidth',0.75); %plot_info.colors_celltype(nn,:)

    xlim([1 length(limit_frames(1,ex_trials(1)):limit_frames(1,ex_trials(end)+2))])
    hold off
    
end
hold off
% function plot_example_neurons(dataset,imaging,all_frames,example_cells)
example_dataset = 9;

empty_trials = find(cellfun(@isempty,{imaging_st{1,example_dataset}.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
imaging_dff = [imaging(good_trials).z_dff]; %convert to array for easier indexing
imaging_deconv = [imaging(good_trials).deconv]; %convert to array for easier indexing

imaging_behavior = [imaging(good_trials).movement_in_imaging_time]; %convert to array for easier indexing

total_frames_used_per_trial = cellfun(@length,{imaging_behavior.frame_indices});
total_frames_cumulative = cumsum(total_frames_used_per_trial);
total_frames_event =[];
total_frames_event(1,:) = cellfun(@length,{imaging_behavior.maze_frames});
total_frames_event(2,:) = cellfun(@length,{imaging_behavior.reward_frames});
total_frames_event(3,:) = cellfun(@length,{imaging_behavior.iti_frames});

limit_frames =[];
limit_frames(1,:) = [1,total_frames_cumulative(1:end-1)+1]; %start
limit_frames(2,:) = total_frames_cumulative; %end

event_to_plot = [1,4,5,6];
for m = 1:25
    for ev = 1:length(event_to_plot)
        example_dataset2 = m;
        temp = [];
        temp2 = [];
        temp3 = [];
        ex_trials = 1:6;
        for t = ex_trials
            temp = [temp,limit_frames(1,t):limit_frames(1,t)+total_frames_event(1,t)-1];
            temp2 = [temp2,limit_frames(1,t)+total_frames_event(1,t):limit_frames(1,t)+total_frames_event(1,t)+total_frames_event(2,t)-1];
            temp3 = [temp3,limit_frames(1,t)+total_frames_event(1,t)+total_frames_event(2,t):limit_frames(2,t)];
        end
        
        ex_neurons = responsive_neuron2{1,example_dataset2}{1,event_to_plot(ev)};
        som_ex{m,ev} = ex_neurons(find(ismember(ex_neurons,all_celltypes{1,example_dataset2}.som_cells)));
        pv_ex{m,ev} = ex_neurons(find(ismember(ex_neurons,all_celltypes{1,example_dataset2}.pv_cells)));
        pyr_ex{m,ev} = ex_neurons(find(ismember(ex_neurons,all_celltypes{1,example_dataset2}.pyr_cells)));
    end
end

temp = [];
temp2 = [];
temp3 = [];
ex_trials = 60:68;%167:175;
for t = ex_trials
    temp = [temp,limit_frames(1,t):limit_frames(1,t)+total_frames_event(1,t)-1];
    temp2 = [temp2,limit_frames(1,t)+total_frames_event(1,t):limit_frames(1,t)+total_frames_event(1,t)+total_frames_event(2,t)-1];
    temp3 = [temp3,limit_frames(1,t)+total_frames_event(1,t)+total_frames_event(2,t):limit_frames(2,t)];
end

save_str = 'event3';
%ex_neurons = [pyr_ex{example_dataset,1}(3),som_ex{example_dataset,1}(2),pv_ex{example_dataset,1}(1)];
% % ex_neurons = [pyr_ex{example_dataset,1}(7),som_ex{example_dataset,1}(3),pv_ex{example_dataset,1}(1)];
ex_neurons = [pyr_ex{example_dataset,4}(6),som_ex{example_dataset,3}(2),pv_ex{example_dataset,3}(5)];
%pyr 4, 13, 30 isnice for turn task// maybe 14
figure(23);clf;
num_rows = length(ex_neurons);
num_columns = 1;

hold on
for nn = 1:num_rows

    n = ex_neurons(nn);
    
    %subplot(num_rows, num_columns, nn);
    hold on
    % Highlight frames specified in temp
    
    
    ylims = [0 30];%ylim; % Get y-axis limits for drawing boxes

    if nn == 1

        %maze frames
        temp_frames = unique(temp);
        for frame = temp_frames
            frame_idx = frame;%frame - limit_frames(1, ex_trials(1)) + 1;
            rectangle('Position', [frame_idx, ylims(1), 1, ylims(2)-ylims(1)], 'FaceColor', [1 1 1 0.5], 'EdgeColor', 'none'); % Adjust the box color as needed [0.7 0.9 1 0.5]
        end
    
        %reward
        temp_frames = unique(temp2);
        for frame = temp_frames
            frame_idx = frame;%frame - limit_frames(1, ex_trials(1)) + 1;
            rectangle('Position', [frame_idx, ylims(1), 1, ylims(2)-ylims(1)], 'FaceColor', [0.5 0.5 0.5 0.5], 'EdgeColor', 'none'); % Adjust the box color as needed [0.0 0.6 0.7 0.5]
        end
    
        %ITI
        temp_frames = unique(temp3);
        for frame = temp_frames
            frame_idx = frame;%frame - limit_frames(1, ex_trials(1)) + 1;
            rectangle('Position', [frame_idx, ylims(1), 1, ylims(2)-ylims(1)], 'FaceColor', [0.8 0.8 0.8 0.5], 'EdgeColor', 'none'); % Adjust the box color as needed
        end
    end
    
    y_offset = nn*7;
     % Plot the imaging data with y_offset
    y_offset_matrix = ones(1, length(limit_frames(1, ex_trials(1)):limit_frames(1, ex_trials(end)) + 2)) * y_offset;
    %plot((limit_frames(1, ex_trials(1)):limit_frames(1, ex_trials(end)) + 2), rescale(imaging_deconv(n, limit_frames(1, ex_trials(1)):limit_frames(1, ex_trials(end)) + 2),0,2) + y_offset,'color', 'k', 'LineWidth', .6);
    plot((limit_frames(1, ex_trials(1)):limit_frames(1, ex_trials(end)) + 2), smooth(imaging_dff(n, limit_frames(1, ex_trials(1)):limit_frames(1, ex_trials(end)) + 2),3,'boxcar') + y_offset,'color', plot_info.colors_celltype(nn,:), 'LineWidth', .6);

    % Adjust x-axis limits
    xlim([limit_frames(1, ex_trials(1)) limit_frames(1, ex_trials(end))])

    plotObjects = get(gca, 'Children');
    yticklabels([])
    xticklabels([])
    
end
hold off
%%
%set_current_fig;
if ~isempty(info.savepath)
    mkdir([ info.savepath '\example_neurons'])
    cd([ info.savepath '\example_neurons'])
    saveas(23,strcat('traces_',num2str(ex_neurons),'_dataset',num2str(example_dataset),'_',save_str,'_datasets.svg'));
    saveas(23,strcat('traces_',num2str(ex_neurons),'_dataset',num2str(example_dataset),'_',save_str,'_datasets.fig'));
end
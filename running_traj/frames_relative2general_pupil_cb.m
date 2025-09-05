function [all_frames,frame_sums,all_frames_block] = frames_relative2general_pupil_cb(mouse_date,server,imaging)

    good_trials = [];

    empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
    good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
    
    load(strcat(server,'/Connie/ProcessedData/',mouse_date,'/alignment_info.mat'));
    previous_frames_sum = 0;  previous_frames = 0;

    frame_sums = cellfun(@(x) length(x),{alignment_info.frame_times});
    vr=[]; block_vr = [];
    for trial = 1:length(good_trials)
        if imaging(good_trials(trial)).file_num == 1
            previous_frames_temp = 0;
        else
            previous_frames_temp = sum(frame_sums(1:imaging(good_trials(trial)).file_num-1));
        end
        
        previous_frames_sum = sum(previous_frames_temp);
        if length(fields(imaging(good_trials(trial)).frame_id_events))> 2
            vr(trial).maze = (imaging(good_trials(trial)).movement_in_imaging_time.maze_frames(1) + imaging(good_trials(trial)).frame_id -1)+previous_frames_sum: (imaging(good_trials(trial)).movement_in_imaging_time.maze_frames(end) + imaging(good_trials(trial)).frame_id -1)+previous_frames_sum;
            vr(trial).reward = (imaging(good_trials(trial)).movement_in_imaging_time.reward_frames(1) + imaging(good_trials(trial)).frame_id -1)+previous_frames_sum: (imaging(good_trials(trial)).movement_in_imaging_time.reward_frames(end) + imaging(good_trials(trial)).frame_id -1)+previous_frames_sum;
            vr(trial).turn = imaging(good_trials(trial)).frame_id(1) -1 + previous_frames_sum + imaging(good_trials(trial)).movement_in_imaging_time.turn_frame;
            vr(trial).ITI = (imaging(good_trials(trial)).movement_in_imaging_time.iti_frames(1) + imaging(good_trials(trial)).frame_id -1)+previous_frames_sum: (imaging(good_trials(trial)).movement_in_imaging_time.iti_frames(end) + imaging(good_trials(trial)).frame_id -1)+previous_frames_sum;
            

            block_vr(trial).maze = imaging(good_trials(trial)).frame_id_events.maze;
            block_vr(trial).ITI = imaging(good_trials(trial)).frame_id_events.iti;
            block_vr(trial).block = imaging(good_trials(trial)).file_num;

        else
            vr(trial).maze = (imaging(good_trials(trial)).movement_in_imaging_time.maze_frames(1) + imaging(good_trials(trial)).frame_id -1)+previous_frames_sum: (imaging(good_trials(trial)).movement_in_imaging_time.maze_frames(end) + imaging(good_trials(trial)).frame_id -1)+previous_frames_sum;
            vr(trial).ITI = (imaging(good_trials(trial)).movement_in_imaging_time.iti_frames(1) + imaging(good_trials(trial)).frame_id -1)+previous_frames_sum: (imaging(good_trials(trial)).movement_in_imaging_time.iti_frames(end) + imaging(good_trials(trial)).frame_id -1)+previous_frames_sum;
            
            block_vr(trial).maze = imaging(good_trials(trial)).frame_id_events.maze;
            block_vr(trial).ITI = imaging(good_trials(trial)).frame_id_events.iti;
            block_vr(trial).block = imaging(good_trials(trial)).file_num;

        end
    end
    all_frames = vr;

    all_frames_block = block_vr;
end

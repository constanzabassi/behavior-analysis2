function [event2tast_sums,cat_array, event_2task] = get_event_relative2task (all_frames,ds_events)
%%% OUTPUT cat_array: trial_id, onset, event, PV or SOM, task event associated with it
% event2tast_sums: datasets x event sums (stimulus/turn/reward/ITI)

%initialize variables
    som_sum = [];
    pv_sum =[];

for m = 1:length(all_frames)
    m
    %
    temp = {all_frames{1,m}.maze};
    temp_turns = [all_frames{1,m}.turn];
    %define relative periods
    task_periods.stimulus =  [cellfun(@(x) x(1),temp);temp_turns-30]'; %using 1 sec before turn to say it's within turn period!
    task_periods.turn = [temp_turns-29;cellfun(@(x) x(end),temp)]';

    % REWARD
    temp = {all_frames{1,m}.reward};
    task_periods.reward = [cellfun(@(x) x(1),temp);cellfun(@(x) x(end),temp)]';

    % ITI
    temp = {all_frames{1,m}.ITI};
    task_periods.ITI = [cellfun(@(x) x(1),temp);cellfun(@(x) x(end),temp)]';
    
    event_task ={};
    for os = 1:length(ds_events(m).onsets)
        current_onset = ds_events(m).onsets(os).onset;
        if ~isempty(find(current_onset>=task_periods.stimulus(:,1) & current_onset <=task_periods.stimulus(:,2)))
            event_task{os} = {find(current_onset>=task_periods.stimulus(:,1) & current_onset <=task_periods.stimulus(:,2)),ds_events(m).onsets(os).onset,ds_events(m).onsets(os).onset,ds_events(m).onsets(os).condition,'stimulus'};
        
        elseif ~isempty(find(current_onset>=task_periods.turn(:,1) & current_onset <=task_periods.turn(:,2)))
            event_task{os} = {find(current_onset>=task_periods.turn(:,1) & current_onset <=task_periods.turn(:,2)),ds_events(m).onsets(os).onset,ds_events(m).onsets(os).onset,ds_events(m).onsets(os).condition,'turn'};

        elseif ~isempty(find(current_onset>=task_periods.reward(:,1) & current_onset <=task_periods.reward(:,2)))
            event_task{os} = {find(current_onset>=task_periods.reward(:,1) & current_onset <=task_periods.reward(:,2)),ds_events(m).onsets(os).onset,ds_events(m).onsets(os).onset,ds_events(m).onsets(os).condition,'reward'};

        elseif ~isempty(find(current_onset>=task_periods.ITI(:,1) & current_onset <=task_periods.ITI(:,2)))
            event_task{os} = {find(current_onset>=task_periods.ITI(:,1) & current_onset <=task_periods.ITI(:,2)),ds_events(m).onsets(os).onset,ds_events(m).onsets(os).onset,ds_events(m).onsets(os).condition,'ITI'};

        end
    end

    event_2task{m} = event_task;
    cat_array{m} = cat(1,event_2task{1,m}{1,:});

    %% sum the events for PV and SOM
    temp = cellfun(@(x) strcmp(x,'SOM'), cat_array{1,m});
    SOM_events = find(temp(:,4));
    temp = cellfun(@(x) strcmp(x,'PV'), cat_array{1,m});
    PV_events = find(temp(:,4));

    %sum for each condition
    temp = cellfun(@(x) strcmp(x,'stimulus'), cat_array{1,m});
    som_all(1,1) = sum(temp(SOM_events,5));
    pv_all(1,1) = sum(temp(PV_events,5));

    temp = cellfun(@(x) strcmp(x,'turn'), cat_array{1,m});
    som_all(1,2) = sum(temp(SOM_events,5));
    pv_all(1,2) = sum(temp(PV_events,5));

    temp = cellfun(@(x) strcmp(x,'reward'), cat_array{1,m});
    som_all(1,3) = sum(temp(SOM_events,5));
    pv_all(1,3) = sum(temp(PV_events,5));

    temp = cellfun(@(x) strcmp(x,'ITI'), cat_array{1,m});
    som_all(1,4) = sum(temp(SOM_events,5));
    pv_all(1,4) = sum(temp(PV_events,5));

    som_sum = [som_sum;som_all];
    pv_sum = [pv_sum;pv_all];

%     imaging = imaging_st{1,m};
%     empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
%     good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
%     imaging_array = [imaging(good_trials).movement_in_imaging_time]; %convert to array for easier indexing
%     imaging_frames = [imaging(good_trials).frame_id_events];
% 
%     
%     %stimulus
%     temp_frames = cellfun(@(x) unique(x),{imaging_frames.maze},'UniformOutput',false);
%     turn_onsets = [imaging_array.turn_frame];
%     period.stimulus = 
%     %turn
%     period.turn = 
%     %reward
%     period.reward = cellfun(@(x) unique(x),{imaging_frames.reward},'UniformOutput',false);
%     %ITI
%     period.ITI = cellfun(@(x) unique(x),{imaging_frames.ITI},'UniformOutput',false)
end
event2tast_sums.som = som_sum;
event2tast_sums.pv = pv_sum;
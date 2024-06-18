function [event2tast_sums,event2task_sums,cat_array, event_2task] = get_event_relative2task_updated (all_frames,imaging_st,ds_events)
%%% OUTPUT cat_array: trial_id, onset, event, PV or SOM, task event associated with it
% event2tast_sums: datasets x event sums (stimulus/turn/reward/ITI)
% event2task_sums: datasets x event sums (stimulus/stimulus2/stimulus3/turn/reward/ITI)

%initialize variables
    som_sum = [];
    pv_sum =[];

    som_sum_v2 = [];
    pv_sum_v2 =[];

for m = 1:length(all_frames)
    m

    %initialize variables
    som_all = [];
    pv_all = [];
    %
%     temp = {all_frames{1,m}.maze};
%     temp_turns = [all_frames{1,m}.turn];
%     %define relative periods
%     task_periods.stimulus =  [cellfun(@(x) x(1),temp);temp_turns-30]'; %using 1 sec before turn to say it's within turn period!
%     task_periods.turn = [temp_turns-29;cellfun(@(x) x(end),temp)]';
% 
%     % REWARD
%     temp = {all_frames{1,m}.reward};
%     task_periods.reward = [cellfun(@(x) x(1),temp);cellfun(@(x) x(end),temp)]';
% 
%     % ITI
%     temp = {all_frames{1,m}.ITI};
%     task_periods.ITI = [cellfun(@(x) x(1),temp);cellfun(@(x) x(end),temp)]';
    
    %reorganize based on actual events!
    imaging = imaging_st{1,m};
    [~,alignment_frames,left_padding,right_padding] = find_align_info (imaging,30);
    event_onsets = determine_onsets(left_padding,right_padding,[1:6]);
    alignment.left_padding = left_padding;
    alignment.right_padding = right_padding;

    onset_frames =[];
    for t = 1:length(alignment_frames)
        onset_frames(:,t) = all_frames{1,m}(t).maze(1)+alignment_frames(:,t)-1; 
    end

    %using whole time period
    for e = 1:size(onset_frames,1)
        if e == 1
            task_periods.stimulus = [onset_frames(e,:);onset_frames(e,:)+24]';
        elseif e == 2
            task_periods.stimulus2 = [onset_frames(e,:);onset_frames(e,:)+24]';
        elseif e == 3
            task_periods.stimulus3 = [onset_frames(e,:);onset_frames(e,:)+24]';
        elseif e == 4
            task_periods.turn = [onset_frames(e,:)-12;onset_frames(e,:)+12]';
        elseif e == 5
            task_periods.reward =[onset_frames(e,:);onset_frames(e,:)+24]';
        elseif e == 6
            task_periods.ITI = [onset_frames(e,:);onset_frames(e,:)+24]';
        end
    end

    
    event_task ={};
    for os = 1:length(ds_events(m).onsets)
        current_onset = ds_events(m).onsets(os).onset;
        if ~isempty(find(current_onset>=task_periods.stimulus(:,1) & current_onset <=task_periods.stimulus(:,2)))
            event_task{os} = {find(current_onset>=task_periods.stimulus(:,1) & current_onset <=task_periods.stimulus(:,2)),ds_events(m).onsets(os).onset,ds_events(m).onsets(os).onset,ds_events(m).onsets(os).condition,'stimulus'};

        elseif ~isempty(find(current_onset>=task_periods.stimulus2(:,1) & current_onset <=task_periods.stimulus2(:,2)))
            event_task{os} = {find(current_onset>=task_periods.stimulus2(:,1) & current_onset <=task_periods.stimulus2(:,2)),ds_events(m).onsets(os).onset,ds_events(m).onsets(os).onset,ds_events(m).onsets(os).condition,'stimulus2'};
        
        elseif ~isempty(find(current_onset>=task_periods.stimulus3(:,1) & current_onset <=task_periods.stimulus3(:,2)))
            event_task{os} = {find(current_onset>=task_periods.stimulus3(:,1) & current_onset <=task_periods.stimulus3(:,2)),ds_events(m).onsets(os).onset,ds_events(m).onsets(os).onset,ds_events(m).onsets(os).condition,'stimulus3'};

        elseif ~isempty(find(current_onset>=task_periods.turn(:,1) & current_onset <=task_periods.turn(:,2)))
            event_task{os} = {find(current_onset>=task_periods.turn(:,1) & current_onset <=task_periods.turn(:,2)),ds_events(m).onsets(os).onset,ds_events(m).onsets(os).onset,ds_events(m).onsets(os).condition,'turn'};

        elseif ~isempty(find(current_onset>=task_periods.reward(:,1) & current_onset <=task_periods.reward(:,2)))
            event_task{os} = {find(current_onset>=task_periods.reward(:,1) & current_onset <=task_periods.reward(:,2)),ds_events(m).onsets(os).onset,ds_events(m).onsets(os).onset,ds_events(m).onsets(os).condition,'reward'};

        elseif ~isempty(find(current_onset>=task_periods.ITI(:,1) & current_onset <=task_periods.ITI(:,2)))
            event_task{os} = {find(current_onset>=task_periods.ITI(:,1) & current_onset <=task_periods.ITI(:,2)),ds_events(m).onsets(os).onset,ds_events(m).onsets(os).onset,ds_events(m).onsets(os).condition,'ITI'};
        
        elseif ~isempty(find(current_onset>=task_periods.stimulus(:,1)-24 & current_onset <task_periods.stimulus(:,1)))
            event_task{os} = {find(current_onset>=task_periods.stimulus(:,1)-24 & current_onset <task_periods.stimulus(:,1)),ds_events(m).onsets(os).onset,ds_events(m).onsets(os).onset,ds_events(m).onsets(os).condition,'ITI_end'};

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



    % include 3 sound repeats
    %sum for each condition
    som_all = [];pv_all = [];
    temp = cellfun(@(x) strcmp(x,'stimulus'), cat_array{1,m});
    som_all(1,1) = sum(temp(SOM_events,5));
    pv_all(1,1) = sum(temp(PV_events,5));
    temp = cellfun(@(x) strcmp(x,'stimulus2'), cat_array{1,m});
    som_all(1,2) = sum(temp(SOM_events,5));
    pv_all(1,2) = sum(temp(PV_events,5));
    temp = cellfun(@(x) strcmp(x,'stimulus3'), cat_array{1,m});
    som_all(1,3) = sum(temp(SOM_events,5));
    pv_all(1,3) = sum(temp(PV_events,5));

    temp = cellfun(@(x) strcmp(x,'turn'), cat_array{1,m});
    som_all(1,4) = sum(temp(SOM_events,5));
    pv_all(1,4) = sum(temp(PV_events,5));

    temp = cellfun(@(x) strcmp(x,'reward'), cat_array{1,m});
    som_all(1,5) = sum(temp(SOM_events,5));
    pv_all(1,5) = sum(temp(PV_events,5));

    temp = cellfun(@(x) strcmp(x,'ITI'), cat_array{1,m});
    som_all(1,6) = sum(temp(SOM_events,5));
    pv_all(1,6) = sum(temp(PV_events,5));

    temp = cellfun(@(x) strcmp(x,'ITI_end'), cat_array{1,m});
    som_all(1,7) = sum(temp(SOM_events,5));
    pv_all(1,7) = sum(temp(PV_events,5));

    som_sum_v2 = [som_sum_v2;som_all];
    pv_sum_v2 = [pv_sum_v2;pv_all];


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

event2task_sums.som= som_sum_v2;
event2task_sums.pv= pv_sum_v2;
function task_period = define_trial_task_periods(alignment)
    event_onset = determine_onsets(alignment.left_padding,alignment.right_padding,[1:6]);
    % decide what is the timing for different time events...
    %1) stim 1
    %2) stim 2
    %3) stim 3??
    %4) turn
    %5) reward
    %6) ITI

    %try to make them about the same size?
    for e = 1:length(event_onset)
        if e == 4
            task_period(e,:) = event_onset(e)-12:event_onset(e)+12;
        else
            task_period(e,:) = event_onset(e):event_onset(e)+24;
        end
    end




function aligned_imaging = align_behavior_data (imaging,data_type,event)
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!

% 1) align data based on maze onset (include prededing ITI up to 1 sec)
%find the trial with the smallest amount of frames

for vr_trials = 1:length(good_trials)
    t = good_trials(vr_trials);
    if strcmp(data_type,'dff')
        imaging()
    elseif strcmp(data_type,'z_dff')
    else
    end
    
end

% 2) align data based on maze offset/turn (include proceding ITI up to 1 sec)

% 3) especialized based on each persons stimulus?

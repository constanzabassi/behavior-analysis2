function [updated_imaging_st,eliminated] = eliminate_photostim_trials(imaging_st)
updated_imaging_st = imaging_st;
[r,c] = determine_num_tiles(length(imaging_st));
figure(99);clf;
tiledlayout(r,c)
for m = 1:length(imaging_st)
    imaging = imaging_st{1,m};
    empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
    good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
    
    imaging_array = [imaging(good_trials).movement_in_imaging_time]; %convert to array for easier indexing
    virmen_trial_info = [imaging(good_trials).virmen_trial_info]; 
    aligned_imaging =[]; %this is needed so there is an output if there are zero trials in the condition (happens w reward)
    
    %trials to eliminate = photostim trials
    trials_to_eliminate = find([virmen_trial_info.is_stim_trial]);
    if ~isempty(trials_to_eliminate)
        for t = 1:length(trials_to_eliminate)
            updated_imaging_st{1,m}(good_trials(trials_to_eliminate(t))).good_trial = [];     
        end
        fprintf(strcat('eliminating ',num2str(length(trials_to_eliminate)) ,' trials in mouse ',num2str(m),'\n'))
    end

    % make plots of maze length!

    nexttile
    hold on
    %plot(maze_length, '-k','linewidth', 1.5)
    if ~isempty(trials_to_eliminate)
        plot(trials_to_eliminate,0,'*r','linewidth', 1.5)
    end
    xlabel('Trial ID')
    ylabel('Maze length (frames)')
    title (['Maze length dataset# ' num2str(m)])
    xlim([1 length(good_trials)])
    hold off

    eliminated{m} = good_trials(trials_to_eliminate);
end
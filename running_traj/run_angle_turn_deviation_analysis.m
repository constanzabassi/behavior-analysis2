%% analysis of running trajectories/view angle changes based on Green et al 2023
%get data for each mouse
m = 1;
imaging = imaging_st{1,m};
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!

imaging_array = [imaging(good_trials).movement_in_imaging_time]; %convert to array for easier indexing
imaging_trial_info = [imaging(good_trials).virmen_trial_info];

%%1) compute mouse's heading deviation (difference between its heading at
%each timepoint and the mean heading (smoothed- take 25% of shortest
%trials- compute the median and the circular mean heading at binned
%distances from the reward)
%also plot heading direction
median_viewangle = nanmedian([imaging_array.view_angle]); %for some reason it is not zero
figure(1);clf
for p = 1:25
    subplot(5,5,p);
    p = p;
    hold on;
    %plot(rescale(imaging_array(p).x_velocity(imaging_array(p).maze_frames),-1,1));
    plot(vel_ball{m,1}{p,2},'k');
    plot((imaging_array(p).view_angle(imaging_array(p).maze_frames))-median_viewangle,'color',[0.5 0.5 0.5]);
    %plot(rescale(smooth(mean(imaging(good_trials(p)).dff(all_celltypes{1,m}.pv_cells,imaging_array(p).maze_frames)),10,'boxcar'),-1,1),'color',[0.82 0.04 0.04]);
    plot(rescale(smooth(mean(imaging(good_trials(p)).dff(all_celltypes{1,m}.som_cells,imaging_array(p).maze_frames)),3,'boxcar'),-2,2),'color',[0.17 0.35 0.8]);
    
    hold off;
    xlim([1 length(imaging_array(p).maze_frames)])
    ylim([-4 4])
end


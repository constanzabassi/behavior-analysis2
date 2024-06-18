%% analysis of running trajectories/view angle changes based on Green et al 2023
vel_ball = get_ball_velocity(info,all_frames); %to get yaw
%%
%get data for each mouse
savepath = [info.savepath '\navigation_correction'];
save_str = ['ex_plots_viewangle_roll_SOM_dataset_maze_reward_frames'];
num_bins = 25;
for m = 1:length(imaging_st)
imaging = imaging_st{1,m};
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!

imaging_array = [imaging(good_trials).movement_in_imaging_time]; %convert to array for easier indexing
imaging_trial_info = [imaging(good_trials).virmen_trial_info];

%find the log transformed distance from reward
log_distance = log_transform_reward_distance(imaging_array); %finds eucledian distance

heading_deviation = compute_heading_deviation2(imaging_array, imaging_trial_info, vel_ball{m,1}, log_distance,num_bins); %heading_deviation trials x bins

%also plot heading direction
median_viewangle = nanmedian([imaging_array.view_angle]); %for some reason it is not zero

%to get all activity at once
avg_all = [];for t = good_trials; avg_all = [avg_all,imaging(t).dff(all_celltypes{1,m}.som_cells,:)];end
headin_all = [];count = 0;for t = 1:length(good_trials); headin_all = [headin_all, imresize(heading_deviation(t,:),[1,length(imaging_array(t).maze_frames)+length(imaging_array(t).reward_frames)+length(imaging_array(t).iti_frames)])]; end

figure(1);clf
for p = 1:36
    
    subplot(6,6,p);
    p = p+10;
    frames_to_include = [imaging_array(p).maze_frames,imaging_array(p).reward_frames];
    hold on;
    title(num2str(good_trials(p)))
    plot(rescale(imaging_array(p).x_velocity(frames_to_include),-1,1),'k');
%     plot(rescale(diff(imaging_array(p).x_velocity(frames_to_include)),-1,1),'k','LineWidth',1);
%     plot(vel_ball{m,1}{p,2},'k');

    plot((imaging_array(p).view_angle(frames_to_include))-median_viewangle,'color',[0.5 0.5 0.5]);
%     plot(rescale(rad2deg(imaging_array(p).view_angle(frames_to_include))-90,-2,2),'color',[0.5 0.5 0.5],'LineWidth',1);

    plot(imresize(heading_deviation(p,:),[1,length(imaging_array(p).maze_frames)]),'color',[0.7 0.7 0.7]);
    %plot(rescale(smooth(mean(imaging(good_trials(p)).dff(all_celltypes{1,m}.pv_cells,imaging_array(p).maze_frames)),10,'boxcar'),-1,1),'color',[0.82 0.04 0.04]);
    plot(rescale(smooth(mean(imaging(good_trials(p)).dff(all_celltypes{1,m}.som_cells,frames_to_include)),3,'boxcar'),-2,2),'color',[0.17 0.35 0.8]);
    
    hold off;
    xlim([1 length(frames_to_include)])
    ylim([-4 4])
end

if ~isempty(savepath)
        mkdir(savepath)
        cd(savepath)
        saveas(1,strcat(save_str,num2str(m),'.svg'));
        saveas(1,strcat(save_str,num2str(m),'.png'));
end

end




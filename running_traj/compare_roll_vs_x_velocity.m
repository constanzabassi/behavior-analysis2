


%%
mouse_date = 'HE4-1L1R\2023-08-24';
server = 'W:';
%HE4-1L1R\2023-08-24
clear info2
load([server, '\Connie\ProcessedData\' mouse_date '\VR\imaging.mat']);
load([server, '\Connie\ProcessedData\' mouse_date '\corrected_velocity.mat']);
info2.server = {server};
info2.mouse_date = {mouse_date};
imaging_st{1,1} = imaging;
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials);
all_frames = frames_relative2general(info2,imaging_st,0);


figure(3);clf;
tiledlayout(5,2);

for t = 30:39;nexttile; 
    trial_frames = all_frames{1,1}(t).maze(1):all_frames{1,1}(t).ITI(end);
    
    hold on
    plot(rescale(imaging(good_trials(t)).movement_in_imaging_time.stimulus,-40,40),'-r');
    plot(imaging(good_trials(t)).movement_in_imaging_time.x_velocity,'-b');
    plot(imaging(good_trials(t)).movement_in_imaging_time.x_position,'-g');
    %plot(corrected_velocity(1,trial_frames),'-m'); %movement_in_imaging_time.turn_frame
    plot(corrected_velocity(2,trial_frames),'-m');
%     plot(corrected_velocity(3,trial_frames),'-c');
%     plot(imaging(good_trials(t)).movement_in_imaging_time.turn_frame,0,'*r');
    
    new_turn = find(abs(imaging(good_trials(t)).movement_in_imaging_time.x_position)>1,1,'first');
    plot(new_turn,0,'*c');
    title(['Left turn: ' num2str(imaging(good_trials(t)).virmen_trial_info.left_turn) '| Left sound: ' num2str(rem(imaging(good_trials(t)).virmen_trial_info.condition,2))]);

    hold off
    ylim([-50 50])
end


% figure(); 
% hold on;
% % start_trial_frames = [imaging(:).relative_frames];
% plot(corrected_velocity(2,:));
% plot(bad_frames(:,1),0,'*c');
% hold off
% 

% %%
% temp = {};
% for trial = 1:length(good_trials)
%     frame_comp  = imaging(good_trials(trial)).relative_frames;
%     frame_comp(2,:)  = all_frames{1,1}(trial).maze(1):all_frames{1,1}(trial).ITI(end);
%     temp{trial} = frame_comp(1,:) == frame_comp(2,:);
%     if ~temp{trial}(1) == 1
%         display(num2str(trial))
%     end
% end

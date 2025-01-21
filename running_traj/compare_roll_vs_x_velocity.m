%This code was written to compare roll velocity (x movememnt in sensors) vs
%x velocity output from virmen (which is a combination of pitch and roll
%using view angle). Corrected velocity is the sensor velocity (1 = pitch/2
%2 = roll/3 = yaw). Overall X velocity and roll ARE NOT THE SAME. If
%anything X velocity is more closely related to pitch. 


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


%% Code to try to estimate view angle in case we decide later on to use x velocity instead of roll for passive/spont

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

pitch_temp = [];
stimuli_temp = [];
roll_temp = [];
yaw_temp = [];
y_vel_temp =[];
x_vel_temp=[];
turn_temp =[];
view_angle_temp =[];
first_half = 1:60;
for t = first_half
    trial_frames = all_frames{1,1}(t).maze(1):all_frames{1,1}(t).maze(end); %all_frames{1,1}(t).ITI(end);
    pitch_temp = [pitch_temp, corrected_velocity(1,trial_frames)];
    roll_temp = [roll_temp,corrected_velocity(2,trial_frames)];
    yaw_temp = [yaw_temp,corrected_velocity(3,trial_frames)];
    stimuli_temp = [stimuli_temp,imaging(good_trials(t)).movement_in_imaging_time.stimulus];

    y_vel_temp = [y_vel_temp, imaging(good_trials(t)).movement_in_imaging_time.y_velocity(1:length(trial_frames))];
    x_vel_temp = [x_vel_temp, imaging(good_trials(t)).movement_in_imaging_time.x_velocity(1:length(trial_frames))];
    view_angle_temp = [view_angle_temp,imaging(good_trials(t)).movement_in_imaging_time.view_angle(1:length(trial_frames)) ];

    zeros_array = zeros(1,length(trial_frames));
    new_turn = find(abs(imaging(good_trials(t)).movement_in_imaging_time.x_position)>1,1,'first');
    zeros_array(new_turn) = 1;
    turn_temp = [turn_temp, zeros_array];
end

view_angle_temp_test = []; pitch_temp_test=[];roll_temp_test = [];x_vel_test=[];yaw_test=[];
secondHalfIdx = 61:158;
for t = secondHalfIdx
    trial_frames = all_frames{1,1}(t).maze(1):all_frames{1,1}(t).maze(end);
    view_angle_temp_test = [view_angle_temp_test,imaging(good_trials(t)).movement_in_imaging_time.view_angle(1:length(trial_frames)) ];
    pitch_temp_test = [pitch_temp_test, corrected_velocity(1,trial_frames)];
    roll_temp_test = [roll_temp_test,corrected_velocity(2,trial_frames)];
    yaw_test = [yaw_test,corrected_velocity(3,trial_frames)];
    x_vel_test = [x_vel_test, imaging(good_trials(t)).movement_in_imaging_time.x_velocity(1:length(trial_frames))];
end




% Assuming data is structured as:
% x_velocity: [1 x N]
% pitch: [1 x N]
% roll: [1 x N]

pitch_train = pitch_temp;
roll_train = roll_temp;
view_angle_train = view_angle_temp;
yaw_train = yaw_temp;

pitch_test = pitch_temp_test;
roll_test = roll_temp_test;
view_angle_test = view_angle_temp_test;


% Fit a linear model to predict view angle from pitch and roll
mdl_theta = fitlm([pitch_train(:), roll_train(:), yaw_train(:)], view_angle_train(:), 'Intercept', true);

% Predict view angle for the second half
view_angle_est = predict(mdl_theta, [pitch_test(:), roll_test(:), yaw_test(:)]);

% Combine actual and estimated view angles
view_angle_combined = [view_angle_train,view_angle_est'];
pitch = [pitch_train, pitch_test];
% Calculate X-velocity using the combined view angle
x_velocity_est =  1.5 *pitch .* cos(view_angle_combined);

figure(1);clf;
hold on
plot(x_velocity_est);
plot([x_vel_temp,x_vel_test]);
hold off
movegui(gcf,'center')

%% predict passive data?


figure(3);clf;
tiledlayout(5,2);

for t = 121:140;nexttile; %30:39
    trial_frames = all_frames{1,1}(t).maze(1):all_frames{1,1}(t).ITI(end);
    % Predict view angle for the second half
    pitch_test = corrected_velocity(1,trial_frames)';
    roll_test  = corrected_velocity(2,trial_frames);
    yaw_test  = corrected_velocity(3,trial_frames);
    view_angle_est = predict(mdl_theta, [pitch_test(:), roll_test(:), yaw_test(:)]);
    
    % Calculate X-velocity using the combined view angle
    x_velocity_est =  1.5 *pitch_test .* cos(view_angle_est);
    
    hold on
    plot(rescale(imaging(good_trials(t)).movement_in_imaging_time.stimulus,-40,40),'-r');
    plot(imaging(good_trials(t)).movement_in_imaging_time.x_velocity,'-b');
    plot(imaging(good_trials(t)).movement_in_imaging_time.x_position,'-g');
    %plot(corrected_velocity(1,trial_frames),'-m'); %movement_in_imaging_time.turn_frame
    plot(corrected_velocity(2,trial_frames),'-m');
    plot(x_velocity_est,Color=[0.5,0.5,0.5]);
%     plot(corrected_velocity(3,trial_frames),'-c');
%     plot(imaging(good_trials(t)).movement_in_imaging_time.turn_frame,0,'*r');
    
    new_turn = find(abs(imaging(good_trials(t)).movement_in_imaging_time.x_position)>1,1,'first');
    plot(new_turn,0,'*c');
    title(['Left turn: ' num2str(imaging(good_trials(t)).virmen_trial_info.left_turn) '| Left sound: ' num2str(rem(imaging(good_trials(t)).virmen_trial_info.condition,2))]);

    hold off
    ylim([-50 50])
end

%%

pitch_temp = [];
stimuli_temp = [];
roll_temp = [];
yaw_temp = [];
y_vel_temp =[];
x_vel_temp=[];
turn_temp =[];


for t = 76:158;
    trial_frames = all_frames{1,1}(t).maze(1):all_frames{1,1}(t).ITI(end);
    pitch_temp = [pitch_temp, corrected_velocity(1,trial_frames)];
    roll_temp = [roll_temp,corrected_velocity(2,trial_frames)];
    yaw_temp = [yaw_temp,corrected_velocity(3,trial_frames)];
    stimuli_temp = [stimuli_temp,imaging(good_trials(t)).movement_in_imaging_time.stimulus];

    y_vel_temp = [y_vel_temp, imaging(good_trials(t)).movement_in_imaging_time.y_velocity];
    x_vel_temp = [x_vel_temp, imaging(good_trials(t)).movement_in_imaging_time.x_velocity];

    zeros_array = zeros(1,length(trial_frames));
    new_turn = find(abs(imaging(good_trials(t)).movement_in_imaging_time.x_position)>1,1,'first');
    zeros_array(new_turn) = 1;
    turn_temp = [turn_temp, zeros_array];
end
pitch_new = pitch_temp;
roll_new = roll_temp;

% Inputs for regression

response_new = x_vel_temp(:);
predictors_new = [pitch_new(:), roll_new(:), pitch_new(:) .* roll_new(:), pitch_new(:).^2, roll_new(:).^2]; %[pitch_new(:), roll_new(:)]

% Predict X-velocity
estimated_x_velocity = predict(mdl, predictors_new);

% Compare predictions
predicted = predict(mdl, predictors);
error = response - predicted;
fprintf('Mean Absolute Error: %.2f\n', nanmean(abs(error)));

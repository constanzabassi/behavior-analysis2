function vel_ball = get_ball_velocity(info,all_frames)
vel_ball = {};
for m = 1:length(info.mouse_date)
    m
    vel_tr={};
    load([info.server{1,m} '\Connie\ProcessedData\' info.mouse_date{1,m} '\corrected_velocity.mat']); %pitch(1) roll(2) yaw(3)
    %conver to randians!
    converted_yaw = corrected_velocity(3,:)./10.2; %diameter of the ball is about 20.4cm (8 inches)! divide by radius to get radians!
    converted_roll = corrected_velocity(2,:)./10.2; %diameter of the ball is about 20.4cm (8 inches)! divide by radius to get radians!
    for tr = 1:length(all_frames{1,m})
         vel_tr{tr,1} = corrected_velocity(3,all_frames{1,m}(tr).maze);
         vel_tr{tr,2} = converted_yaw(1,all_frames{1,m}(tr).maze);
         vel_tr{tr,3} = converted_roll(1,all_frames{1,m}(tr).maze);
    end
    vel_ball{m,1} = vel_tr;
end
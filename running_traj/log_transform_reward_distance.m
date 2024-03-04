function log_distance = log_transform_reward_distance(imaging_array)
% Assume you have the following variables:
% - x: N-by-1 vector containing the x-coordinates of the mouse's position at each time point
% - y: N-by-1 vector containing the y-coordinates of the mouse's position at each time point
% - reward_x: x-coordinate of the reward point
% - reward_y: y-coordinate of the reward point
% Compute the Euclidean distance from the reward point
for tr = 1:length(imaging_array)
    x = imaging_array(tr).x_position(imaging_array(tr).maze_frames);
    y = imaging_array(tr).y_position(imaging_array(tr).maze_frames);
    reward_x = x(end);
    reward_y = y(end);
    distance = sqrt((x - reward_x).^2 + (y - reward_y).^2);
    % Log-transform the distance
    log_distance{tr} = log(distance);
end
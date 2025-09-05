function K = compute_heading_kinematics(view_angle, dt)
% view_angle: 1 x T radians; dt: seconds per sample
dv = [0, wrapToPi_local(diff(view_angle))];
turn_vel = dv ./ dt;                               % rad/s
da = [0, diff(turn_vel)];
turn_acc = da ./ dt;                               % rad/s^2
K.turn_vel = turn_vel;
K.turn_acc = turn_acc;
end
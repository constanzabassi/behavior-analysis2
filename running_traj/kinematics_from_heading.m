function K = kinematics_from_heading(theta, Fs)
dt = 1/Fs;
dv = [0, wrapToPi_local(diff(theta))];
turn_vel = dv ./ dt;
da = [0, diff(turn_vel)];
turn_acc = da ./ dt;
K.turn_vel = turn_vel;
K.turn_acc = turn_acc;
end
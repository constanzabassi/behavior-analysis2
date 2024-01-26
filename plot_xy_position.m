function plot_xy_position(imaging)
colors = [0 0.3 0.8 %nice blue
          0.8 0 0.1]; %nice red
hold on
for t = 1:length(imaging)
    if ~isempty(imaging(t).good_trial) && imaging(t).virmen_trial_info.left_turn == 1
        plot(imaging(t).movement_in_imaging_time.x_position, 'color',colors(1,:));
        plot(imaging(t).movement_in_imaging_time.turn_frame,-0.1, '*c');
    elseif ~isempty(imaging(t).good_trial) && all(imaging(t).virmen_trial_info.left_turn == 0)
        plot(imaging(t).movement_in_imaging_time.x_position, 'color',colors(2,:));
        plot(imaging(t).movement_in_imaging_time.turn_frame,0.1, '*r');
    end
end
hold off
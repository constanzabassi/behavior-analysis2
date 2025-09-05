function [ev_onsets, drive, params] = correction_events(heading_dev, turn_acc, Fs, params)
if nargin<4||isempty(params)
    params.dev_th = pi/12;      % require |deviation| > 15 deg
    params.acc_th = 0.8;        % peak height threshold (rad/s^2)
    params.min_prom = 0.2;      % prominence
    params.refrac_s = 0.30;     % refractory (s)
end
sgn = sign(heading_dev);
drive = max(0, -sgn .* turn_acc);            % positive when accelerating against deviation
mask = abs(heading_dev) > params.dev_th;     % only when deviation is non-trivial
x = drive; x(~mask) = 0;
min_dist = round(params.refrac_s * Fs);
[~, loc] = findpeaks(x, 'MinPeakHeight', params.acc_th, ...
                        'MinPeakProminence', params.min_prom, ...
                        'MinPeakDistance', min_dist);
ev_onsets = loc;
end
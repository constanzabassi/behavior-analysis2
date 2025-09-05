function [corr_events, corr_drive, params] = detect_corrections(heading_dev, turn_acc, Fs, params)
% heading_dev, turn_acc: 1 x T
% Fs: Hz (frames per second)
% params has fields or defaults below
if nargin<4||isempty(params)
    params.dev_th = pi/12;    % require |deviation| > 15 deg
    params.acc_th = 0.8;      % require correction drive > 0.8 rad/s^2 (tune)
    params.min_peak_prom = 0.2; % min prominence for peaks (rad/s^2)
    params.refrac_s = 0.30;   % 300 ms refractory
end
dev_sgn     = sign(heading_dev);
corr_drive  = max(0, -dev_sgn .* turn_acc);  % positive when accelerating against deviation
mask_dev    = abs(heading_dev) > params.dev_th;
drive_masked= corr_drive;
drive_masked(~mask_dev) = 0;
% find peaks (MATLAB R2017b+: findpeaks)
min_dist = round(params.refrac_s * Fs);
[pk, loc] = findpeaks(drive_masked, 'MinPeakHeight', params.acc_th, ...
                      'MinPeakDistance', min_dist, 'MinPeakProminence', params.min_peak_prom);
corr_events.onsets = loc;         % frame indices
corr_events.amps   = pk;          % drive at onset
corr_events.mask_dev = mask_dev;  % for debugging
corr_events.params   = params;
end
function stats = correction_stats_for_trial(view_angle, heading_dev_frame, dist_cm, frames_to_include, Fs)
% Inputs are per-trial vectors restricted to frames_to_include.
dt = 1/Fs;
K  = compute_heading_kinematics(view_angle(frames_to_include), dt);
[ev, drive, pars] = detect_corrections(heading_dev_frame, K.turn_acc, Fs);
n_corr = numel(ev.onsets);
% path length in cm (distance-to-reward decreases; use range magnitude)
L = abs(nanmax(dist_cm(frames_to_include)) - nanmin(dist_cm(frames_to_include)));
rate_per_100 = n_corr / max(1e-6, (L/100));
% spatial profile: bin by distance-to-reward percentiles (or fixed bins)
nb = 20;
d = dist_cm(frames_to_include);
[~,~,bin] = histcounts(d, linspace(nanmin(d), nanmax(d), nb+1));
corr_vec = zeros(size(d)); corr_vec(ev.onsets) = 1;
p_corr_per_bin = accumarray(bin(:), corr_vec(:), [nb,1], @mean, NaN);
stats.n_corr = n_corr;
stats.rate_per_100 = rate_per_100;
stats.spatial_p = p_corr_per_bin;
stats.drive = drive;
stats.ev = ev;
stats.K = K;
stats.Fs = Fs;
stats.params = pars;
end
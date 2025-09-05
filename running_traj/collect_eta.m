function ETA = collect_eta(trig_frames, win_s, Fs, traces)
% traces: struct with any of these fields as row vectors over T:
%   som_mean, nonsst_mean, heading_dev, turn_vel, turn_acc
% Returns time vector and per-trace ETAs (mean across events).
pre = round(win_s(1)*Fs); post = round(win_s(2)*Fs);
T = numel(traces.heading_dev);
twin = (-pre:post);
keep = trig_frames(trig_frames+min(twin) > 0 & trig_frames+max(twin) <= T);
ETA.t = twin / Fs;
if isempty(keep), ETA.keep = []; return; end
names = fieldnames(traces);
for k = 1:numel(names)
    v = traces.(names{k});
    M = nan(numel(keep), numel(twin));
    for i = 1:numel(keep), M(i,:) = v(keep(i)+twin); end
    ETA.(names{k}) = mean(M,1,'omitnan');
    ETA.([names{k} '_per_event']) = M;
end
ETA.keep = keep;
end
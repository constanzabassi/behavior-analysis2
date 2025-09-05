function ETA = som_event_triggered(im_dff, som_idx, ev_onsets, Fs, win_s)
% im_dff: (Ncells x T) for the frames_to_include of this trial
% som_idx: indices into rows of im_dff for SOM cells
% ev_onsets: event frame indices (relative to frames_to_include)
% win_s: [pre post] seconds, e.g., [2 3]
if isempty(ev_onsets) || isempty(som_idx)
    ETA.mean = []; ETA.t = []; ETA.per_cell = [];
    ETA.sig = []; ETA.p = []; ETA.som_idx = som_idx; return
end
pre = round(win_s(1)*Fs); post = round(win_s(2)*Fs);
T = size(im_dff,2);
win = -pre:post;
keep = ev_onsets(ev_onsets+win(1) > 0 & ev_onsets+win(end) <= T);
if isempty(keep), ETA.mean=[]; ETA.t=[]; ETA.per_cell=[]; ETA.sig=[]; ETA.p=[]; ETA.som_idx = som_idx; return, end
% collect epochs (events x cells x time)
nE = numel(keep); nC = numel(som_idx); nW = numel(win);
epochs = nan(nE, nC, nW);
for i = 1:nE
    seg = im_dff(som_idx, keep(i)+win);
    epochs(i,:,:) = seg;
end
% ΔF/F baseline subtract using -2:-1 s
base_idx = find(win/Fs >= -2 & win/Fs <= -1);
if isempty(base_idx), base_idx = 1:max(1, round(0.5*Fs)); end
epochs_bs = epochs - mean(epochs(:,:,base_idx), 3, 'omitnan');
per_cell = squeeze(mean(epochs_bs, 1, 'omitnan'));   % cells x time
ETA.per_cell = per_cell;
ETA.mean = mean(per_cell, 1, 'omitnan');             % 1 x time
ETA.t = win / Fs;
ETA.som_idx = som_idx;
% simple significance per cell: mean 0–1 s vs baseline
post_idx = find(win/Fs >= 0 & win/Fs <= 1);
p = nan(nC,1); sig = false(nC,1);
for c = 1:nC
    x = squeeze(epochs_bs(:,c,post_idx)); x = mean(x,2,'omitnan');
    b = squeeze(epochs_bs(:,c,base_idx)); b = mean(b,2,'omitnan');
    if numel(x)>1 && numel(b)>1
        [~,p(c)] = ttest(x, b); % use signrank if non-normal
        sig(c) = p(c) < 0.05;
    end
end
ETA.p = p; ETA.sig = sig;
end
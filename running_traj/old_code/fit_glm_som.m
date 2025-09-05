function mdl = fit_glm_som(dff, drive, turn_vel, Fs)
% dff: 1 x T of a single cell (baseline-subtracted)
% Add 3 causal lags of drive (0–0.6 s), and turn_vel
T = numel(dff);
X = [];
names = {};
lags = round([0, 0.2, 0.6]*Fs);
for k = 1:numel(lags)
    xk = [zeros(1,lags(k)), drive(1:end-lags(k))];
    X = [X; xk]; %#ok<AGROW>
    names{end+1} = sprintf('drive_lag%d', k); %#ok<AGROW>
end
X = [X; turn_vel]; names{end+1}='turn_vel';
X = X'; y = dff(:);
tbl = array2table([y, X], 'VariableNames', ['y', names]);
mdl = fitlm(tbl, sprintf('y ~ %s', strjoin(names, ' + ')));
end
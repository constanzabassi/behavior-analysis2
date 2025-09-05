function ctrl_onsets = matched_non_correction_onsets(drive, K, Fs, target_onsets, tol)
% Pick times with low correction drive but similar |turn_vel| and |turn_acc|.
% tol: struct('vel', 10, 'acc', 0.5) tolerance in units
if nargin<5||isempty(tol), tol.vel=10; tol.acc=0.5; end
cand = find(drive < 0.1);     % “non-correction” frames
if isempty(cand), ctrl_onsets = []; return, end
ctrl_onsets = [];
for i = 1:numel(target_onsets)
    t0 = target_onsets(i);
    tv = abs(K.turn_vel(t0)); ta = abs(K.turn_acc(t0));
    ok = cand(abs(abs(K.turn_vel(cand))-tv) < tol.vel & ...
              abs(abs(K.turn_acc(cand))-ta) < tol.acc);
    if ~isempty(ok)
        % enforce spacing like events (300 ms)
        ok = ok(ok>round(0.3*Fs) & ok < (numel(drive)-round(0.3*Fs)));
        if ~isempty(ok), ctrl_onsets(end+1) = ok(randi(numel(ok))); end %#ok<AGROW>
    end
end
end
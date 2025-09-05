function mu = circ_mean(theta, dim)
% CIRC_MEAN Circular mean of angles in radians (handles NaNs).
%   mu = circ_mean(theta)     % mean across first non-singleton dim
%   mu = circ_mean(theta,dim) % mean across specified dimension
%
% Angles must be in radians. NaNs are ignored.
%
% Example:
%   mu = circ_mean([0, pi/2, pi, -pi/2]);

if nargin < 2 || isempty(dim)
    dim = find(size(theta) > 1, 1, 'first');
    if isempty(dim), dim = 1; end
end

% convert to unit vectors and average (ignoring NaNs)
S = nanmean(sin(theta), dim);
C = nanmean(cos(theta), dim);

mu = atan2(S, C);
end

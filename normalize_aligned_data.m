function norm_aligned_data = normalize_aligned_data(aligned_data,method)
%%% INPUTS: matrix size trials x neurons x time/frames
%%% OUTPUT: normalized matrix 
% have to decide normaization procedure for now normr (normalize along
% rows!)

%1) concatenate all trials together
temp_aligned = [];
for t = 1:size(aligned_data,1)
    temp_aligned = [temp_aligned,squeeze(aligned_data(t,:,:))];
end

%normalize rows!
norm_temp = normalize(temp_aligned,2,method);

trial_times = 1:size(aligned_data,3):length(temp_aligned);
%put back into nice trial x neuron x time matrix
norm_aligned_data = [];
for t = 1:size(aligned_data,1)  
    norm_aligned_data(t,:,:) = norm_temp(:,trial_times(t):trial_times(t)+size(aligned_data,3)-1);
end

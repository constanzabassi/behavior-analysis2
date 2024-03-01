function smoothed_dff_z = preprocess_pop_activity(dff,varargin)

if isempty(varargin)
    dff_z = zscore(dff')';
    summed_dff_z = sum(dff_z);
    smoothed_dff_z = smooth(summed_dff_z,10,'boxcar'); %smoothed over 1/3 of a second
elseif strcmp('avg',varargin{1})
    dff_z = zscore(dff')';
    mean_dff_z = mean(dff_z,1);
    smoothed_dff_z = smooth(mean_dff_z,10,'boxcar');

end 

end




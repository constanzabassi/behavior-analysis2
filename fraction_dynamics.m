function [max_cel_avg,max_cel, binss] = fraction_dynamics (imaging_st,alignment,bin_size)
max_cel = [];

for m = 1:length(imaging_st)
    m
    ex_imaging = imaging_st{1,m};
    [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
    [aligned_imaging,~,~] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
    
    binss = 1:bin_size:size(aligned_imaging,3)-bin_size;

    for cel = 1:size(aligned_imaging,2)
        for trial = 1:size(aligned_imaging,1)
        
            for b = 1:length(binss)
                binned_data(trial,cel,b) = mean(aligned_imaging(trial,cel,binss(b):binss(b)+bin_size-1));
            end
            [~,inds] = max(squeeze(binned_data(trial,cel,:)));
            max_cel(m,trial,cel) = inds;
        end
        max_cel_avg(m,cel) = round(mode(max_cel(m,:,cel),2));
    end
end
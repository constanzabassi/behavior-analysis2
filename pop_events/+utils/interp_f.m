function [fCorr]=interp_f(F,Fneu,bad_frames)

%INPUTS
    % bad_frames: 2 x #stims array. First column is first bad_frame, second
    % colummn is last bad_frame 

%OUTPUTS
    % fCorr: Neuropil corrected and interpolated F 


count= size(F,1);

fCorr=F-Fneu*.7; 

intervals= zeros(size(bad_frames,1),2);
intervals(:,1)= bad_frames(:,1)-2;%-2; %+/- 2 on each side to make it cleaner
intervals(:,2)= bad_frames(:,2)+2;%+2; 

%%

for int=1:size(intervals,1)
    frames=intervals(int,1): intervals(int,2); %current bad_frames
    
    if sum(frames>(size(F,2)-2))>0
        frames=intervals(int,1): (intervals(int,2)-2); 
        
    end

    for f = frames
        for cels =1:count

            m1=(fCorr(cels,f)-fCorr(cels,intervals(int,1)))/(intervals(int,2)-intervals(int,1)); % calculate slope
            fCorr(cels,f)= m1*(f-intervals(int,1)) +fCorr(cels,intervals(int,1)); % y = mx + b 
        
        end
    end
end




end 





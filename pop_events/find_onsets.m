function [full_events,full_onsets,event_starts,onset_starts,endings,doubles,peaks]= find_onsets(pop_signal,peaks,widths,heights,proms,t)

%% MAKE VARIABLES
full_events=cell(length(peaks),1); 
full_onsets=cell(length(peaks),1); 
endings=nan(1,length(peaks)); 
event_starts=nan(1,length(peaks)); 
onset_starts=nan(1,length(peaks)); 
doubles=0;

remove_edges=nan(1,length(peaks));

%% DETERMINE EVENTS AND ONSETS 

for i=1:length(peaks)
    if peaks(i)>150 && peaks(i)<length(pop_signal)-150
        before=pop_signal(round(peaks(i)-widths(i)/2):peaks(i)); 
        after=pop_signal(peaks(i):round(peaks(i)+widths(i)));   
        if i > 1
            if peaks(i-1) > peaks(i)-widths(i) 
                frames=peaks(i)-widths(i):peaks(i); 
             
                tonan=find(frames<endings(i-1));
                before(tonan)=NaN;
            end
        end
        event_start=find(before<(heights(i)-proms(i)*t)); 
        event_finish=find(after<(heights(i)-proms(i)*t)); 
        
        if ~isempty(event_start) % conditional to remove edges if there is a double peak
        
            thresh=1;
            onset_start=[];
            pre_event=before(1:event_start(end)); 
            
            while isempty(onset_start)
                onset_start=find(pre_event<(heights(i)-proms(i)*thresh)); 
                thresh= thresh - .001;
            end       
            event_frames=peaks(i)-(length(before)-event_start(end)): peaks(i)+event_finish(1);
            onset_frames=peaks(i)-(length(before)-event_start(end))-(length(pre_event)-onset_start(end)): peaks(i)+event_finish(1); 
            
            full_events{i}=event_frames; 
            full_onsets{i}=onset_frames; 
            event_starts(i)=event_frames(1); 
            onset_starts(i)=onset_frames(1);
            endings(i)=peaks(i)+event_finish(1); 
        
        else
            remove_edges(i)=1;
            doubles=doubles+1;       
        end

    else
        remove_edges(i)=1; 
end

end

full_events(remove_edges==1)=[];
full_onsets(remove_edges==1)=[];
event_starts(remove_edges==1)=[];
onset_starts(remove_edges==1)=[];
endings(remove_edges==1)=[];
peaks(remove_edges==1)=[];

end



%%
%         if isempty(onset_start)
%              pre_event=before(1:event_start(end-1)); 
% 
%              diff_pre=diff(movmean(pre_event,2)); 
%              neg=find(diff_pre<=0); 
%              onset_consec=diff(neg)==1;
%              onset_consec(end+1)=0;
%      
%              if isempty(neg)==0
%                  onset_neg=find(diff_pre<=0);    
%                  onset_cond=[];
%                  onset_cond(1,:)=onset_consec;
%                  onset_cond(2,:)=onset_neg;
%                  onset_start=find(all(onset_cond)); 
%              end
%              %onset_start=find(neg_der); 
%              %onset_start=length(neg_der)-(onset_start(end)+1); % correct for lost frames from diff
%              
%              
%         end

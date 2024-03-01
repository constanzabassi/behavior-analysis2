function [pyr_mean_activity,mch_mean_activity,tdt_mean_activity,velo,acc] = get_mean_activity(info,ds_events,mouse_activity,all_celltypes,event_frame,ex_thresh)

conditions={"SOM","PV","Mixed"}; 

for d = 1:length(ds_events)
    d
    %-- load files for each dataset 
    cur_onsets=ds_events(d).onsets;
    tdt = all_celltypes{1,d}.pv_cells;
    mch = all_celltypes{1,d}.som_cells;
    pyr = all_celltypes{1,d}.pyr_cells;
    decon = mouse_activity{1,d}.deconv;
    dff = mouse_activity{1,d}.dff;
 
    load(strcat(num2str(info.server{1,d}),'/Connie/ProcessedData/',num2str(info.mouse_date{1,d}),'/velocity_vector.mat'));
    speed = velocity_vector;
%     speed= sqrt(velocity(1,:).^2 + velocity(2,:).^2);
    abs_speed=abs(speed); 
    raw_acc= diff(speed); 
    abs_acc= abs(raw_acc); 
    
    % --- xcorr with velocity
    
    %[som_speed_xc,lags]=xcorr(speed,ds_events(d).mch_pop_signal,200,'normalized');
    %[pv_speed_xc,lags]=xcorr(speed,ds_events(d).tdt_pop_signal,200,'normalized');
    %[pyr_speed_xc,lags]=xcorr(speed,ds_events(d).pyr_pop_signal,200,'normalized');

    % ----
    for c = 1:length(conditions)
        
        ind = 0; 
        temp_pyr = []; % create vectors for each trial which will then be averaged across datasets 
        temp_tdt = [];
        temp_mch = [];
        temp_speed = []; 
        temp_aspeed= [];
        temp_acc= [];
        temp_abs_acc=[];

       for tr = 1:length(cur_onsets)
           if ~strcmp(conditions{c},'Mixed')
                if strcmp(cur_onsets(tr).condition,conditions{c})
                    
                    period = cur_onsets(tr).onset - event_frame :cur_onsets(tr).onset + event_frame; 
                    ratio=utils.get_ratio(cur_onsets,tr,ds_events,d);
                    if ratio>ex_thresh && period(end)<length(ds_events(d).pyr_pop_signal)
                    %if cur_onsets(tr).pure <ex_thresh 
                        ind = ind+1;
    
                        temp_pyr(ind,:) = ds_events(d).pyr_pop_signal(period); 
                        temp_tdt(ind,:) = ds_events(d).tdt_pop_signal(period);
                        temp_mch(ind,:) = ds_events(d).mch_pop_signal(period);
                        temp_speed(ind,:)= speed(period); 
                        temp_aspeed(ind,:)=abs_speed(period); 
                        temp_acc(ind,:)=raw_acc(period); 
                        temp_abs_acc(ind,:)=abs_acc(period);
    
                    end 
                end

               
           elseif strcmp(conditions{c},'Mixed')
                   period = cur_onsets(tr).onset - event_frame :cur_onsets(tr).onset + event_frame; 
                   ratio=utils.get_ratio(cur_onsets,tr,ds_events,d);
                   if ratio < ex_thresh && period(end)<length(ds_events(d).pyr_pop_signal)
                        ind = ind+1;
                        temp_pyr(ind,:) = ds_events(d).pyr_pop_signal(period); 
                        temp_tdt(ind,:) = ds_events(d).tdt_pop_signal(period);
                        temp_mch(ind,:) = ds_events(d).mch_pop_signal(period);
                        temp_speed(ind,:)= speed(period); 
                        temp_aspeed(ind,:)=abs_speed(period); 
                        temp_acc(ind,:)=raw_acc(period); 
                        temp_abs_acc(ind,:)=abs_acc(period);
                   end

            end
       end
        pyr_mean_activity(d,c,:) = mean(temp_pyr,'omitnan'); 
        tdt_mean_activity(d,c,:) = mean(temp_tdt,'omitnan');
        mch_mean_activity(d,c,:) = mean(temp_mch,'omitnan');
        velo(d,c,:) = mean(temp_speed,'omitnan'); 
        abs_velo(d,c,:)=mean(temp_aspeed,'omitnan'); 
        acc(d,c,:)=mean(temp_acc,'omitnan');
        absolute_acc(d,c,:)=mean(temp_abs_acc,'omitnan'); 

    
    %end
    % mean subtraction
%     temp = dff(pyr,:);
%     pyr_mean_activity(d,:,:) = pyr_mean_activity(d,:,:) - mean(temp(:));
%     temp = dff(tdt,:);
%     tdt_mean_activity(d,:,:) = tdt_mean_activity(d,:,:) - mean(temp(:));
%     temp = dff(mch,:);
%     mch_mean_activity(d,:,:) = mch_mean_activity(d,:,:) - mean(temp(:));
%     temp= speed; 
%     velo(d,:,:)= velo(d,:,:)- mean(temp(:)); 
% 
%     temp=abs_velo; 
%     abs_velo(d,:,:)=abs_velo(d,:,:)- mean(temp(:));  

    %ds_speed_xc(d,1,:)=pyr_speed_xc; 
    %ds_speed_xc(d,2,:)=som_speed_xc; 
    %ds_speed_xc(d,3,:)=pv_speed_xc; 

end


end



      

        
function ds_events = get_ds_events(info,mouse_activity,all_celltypes,params,activity_type)

for d = 1:length(all_celltypes)
    d
    tdt = all_celltypes{1,d}.pv_cells;
    mch = all_celltypes{1,d}.som_cells;
    pyr = all_celltypes{1,d}.pyr_cells;
    decon = mouse_activity{1,d}.deconv;
    dff = mouse_activity{1,d}.dff;

    if strcmp(activity_type,'dff')
        tdt_pop_signal = zscore(preprocess_pop_activity(dff(tdt,:)));
        mch_pop_signal = zscore(preprocess_pop_activity(dff(mch,:)));
        pyr_pop_signal = zscore(preprocess_pop_activity(dff(pyr,:))); 
    elseif strcmp(activity_type,'deconv')
        tdt_pop_signal = zscore(preprocess_pop_activity(decon(tdt,:)));
        mch_pop_signal = zscore(preprocess_pop_activity(decon(mch,:)));
        pyr_pop_signal = zscore(preprocess_pop_activity(decon(pyr,:))); 
    elseif strcmp(activity_type,'dff_avg') 
        tdt_pop_signal = zscore(preprocess_pop_activity(dff(tdt,:),'avg')); 
        mch_pop_signal = zscore(preprocess_pop_activity(dff(mch,:),'avg'));
        pyr_pop_signal = zscore(preprocess_pop_activity(dff(pyr,:),'avg'));
    elseif strcmp(activity_type,'deconv_avg')
        tdt_pop_signal = zscore(preprocess_pop_activity(decon(tdt,:),'avg'));
        mch_pop_signal = zscore(preprocess_pop_activity(decon(mch,:),'avg')); 
        pyr_pop_signal = zscore(preprocess_pop_activity(decon(pyr,:),'avg'));
    end

%     for p=1:size(params,1)
        
        cp=params(1,:); 
        [tdt_h,tdt_peaks,tdt_w,tdt_prom] = findpeaks(tdt_pop_signal,'MinPeakHeight',cp(1),'MinPeakDistance',cp(2),'MinPeakProminence',cp(3),'MaxPeakWidth',cp(4),'MinPeakWidth',cp(5));%'MinPeakHeight',cp(1),'MinPeakProminence',cp(2),'MinPeakWidth',cp(3));
        [mch_h,mch_peaks,mch_w,mch_prom] = findpeaks(mch_pop_signal,'MinPeakHeight',cp(1),'MinPeakDistance',cp(2),'MinPeakProminence',cp(3),'MaxPeakWidth',cp(4),'MinPeakWidth',cp(5));%'MinPeakHeight',cp(1),'MinPeakProminence',cp(2),'MinPeakWidth',cp(3));


       
        [mch_full_events,mch_full_onsets,mch_events,mch_onsets,mch_ends,mch_doubles]=find_onsets(mch_pop_signal,mch_peaks,mch_w,mch_h,mch_prom,.5);
        [tdt_full_events,tdt_full_onsets,tdt_events,tdt_onsets,tdt_ends,tdt_doubles]=find_onsets(tdt_pop_signal,tdt_peaks,tdt_w,tdt_h,tdt_prom,.5);

            % ---- put SOM onsets into structure
    tr = 0;
    for e = 1:length(mch_onsets)
        if mch_onsets(e)>120 & mch_onsets(e)<size(decon,2)-400  
            tr = tr+1;
        
            D_onsets(tr).condition = 'SOM';
            
            D_onsets(tr).pure=tdt_pop_signal(mch_peaks(e));
            D_onsets(tr).event_diff= mean(mch_pop_signal(mch_full_events{e})) - mean (tdt_pop_signal(mch_full_events{e})); 
            D_onsets(tr).onset_diff= mean(mch_pop_signal(mch_full_onsets{e})) - mean(tdt_pop_signal(mch_full_onsets{e})); 
            D_onsets(tr).data = decon(pyr,mch_onsets(e)-100:mch_onsets(e)+400);
            seed=randi(length(pyr_pop_signal)-600)+100;
            D_onsets(tr).randdata=decon(pyr,seed-100:seed+400);
            D_onsets(tr).dff=dff(pyr,mch_onsets(e)-100:mch_onsets(e)+400)
            D_onsets(tr).randdff=dff(pyr,seed-100:seed+400); 
            D_onsets(tr).somdata=decon(mch,mch_onsets(e)-100:mch_onsets(e)+400);
            D_onsets(tr).pvdata=decon(tdt,mch_onsets(e)-100:mch_onsets(e)+400);
            D_onsets(tr).somdff=dff(mch,mch_onsets(e)-100:mch_onsets(e)+400); 
            D_onsets(tr).pvdff= dff(tdt,mch_onsets(e)-100:mch_onsets(e)+400); 

            D_onsets(tr).onset= mch_onsets(e); 
            D_onsets(tr).event=mch_events(e); 
            D_onsets(tr).peak=mch_peaks(e); 
            D_onsets(tr).width=length(mch_full_events{e}); 

        end
    end

    %  ---- put PV onsets into structure 
    for e = 1:length(tdt_onsets)
        if tdt_onsets(e)>120 & tdt_onsets(e)<size(decon,2)-400 % if onsets aren't too close to beginning or end 
            tr = tr+1;
            
            D_onsets(tr).condition = 'PV';
            
            D_onsets(tr).pure=mch_pop_signal(tdt_peaks(e)); 
            D_onsets(tr).event_diff= mean(mch_pop_signal(tdt_full_events{e})) - mean (tdt_pop_signal(tdt_full_events{e})); 
            D_onsets(tr).onset_diff= mean(mch_pop_signal(tdt_full_onsets{e})) - mean(tdt_pop_signal(tdt_full_onsets{e}));
            
            D_onsets(tr).data = decon(pyr,tdt_onsets(e)-100:tdt_onsets(e)+400);
            seed=randi(length(pyr_pop_signal)-600)+100;
            D_onsets(tr).randdata=decon(pyr,seed-100:seed+400);
            D_onsets(tr).dff=dff(pyr,tdt_onsets(e)-100:tdt_onsets(e)+400)
            D_onsets(tr).randdff=dff(pyr,seed-100:seed+400); 
            D_onsets(tr).somdata=decon(mch,tdt_onsets(e)-100:tdt_onsets(e)+400);
            D_onsets(tr).pvdata=decon(tdt,tdt_onsets(e)-100:tdt_onsets(e)+400);
            D_onsets(tr).somdff=dff(mch,tdt_onsets(e)-100:tdt_onsets(e)+400); 
            D_onsets(tr).pvdff= dff(tdt,tdt_onsets(e)-100:tdt_onsets(e)+400); 


            D_onsets(tr).onset= tdt_onsets(e); 
            D_onsets(tr).event=tdt_events(e); 
            D_onsets(tr).peak=tdt_peaks(e); 
            D_onsets(tr).width=length(tdt_full_events{e}); 

        end

    end

%         onsets(p).params=cp; 
%         onsets(p).mch_onsets=mch_onsets;
%         onsets(p).mch_events=mch_events; 
%         onsets(p).mch_full_onsets=mch_full_onsets;
%         onsets(p).mch_full_events=mch_full_events; 
%         onsets(p).mch_widths=mch_w; 
%         onsets(p).mch_peaks=mch_peaks; 
%         onsets(p).mch_h=mch_h; 
%         onsets(p).mch_prom=mch_prom;
%         onsets(p).mch_ends=mch_ends;
%         onsets(p).mch_doubles=mch_doubles;
%     
%         onsets(p).tdt_onsets=tdt_onsets;
%         onsets(p).tdt_events=tdt_events; 
%         onsets(p).tdt_full_onsets=tdt_full_onsets;
%         onsets(p).tdt_full_events=tdt_full_events; 
%         onsets(p).tdt_widths=tdt_w; 
%         onsets(p).tdt_peaks=tdt_peaks; 
%         onsets(p).tdt_h=tdt_h;
%         onsets(p).tdt_prom=tdt_prom;
%         onsets(p).tdt_ends=tdt_ends;
%         onsets(p).tdt_doubles=tdt_doubles;
     
           
%     end
    
    ds_events(d).tag=info.mouse_date{1,d}; 
    ds_events(d).onsets=D_onsets; 
    ds_events(d).params=params; 
    ds_events(d).dff=dff; 
    ds_events(d).decon=decon; 
    ds_events(d).som=mch; 
    ds_events(d).pv=tdt; 
    ds_events(d).pyr=pyr; 
    ds_events(d).mch_pop_signal=mch_pop_signal; 
    ds_events(d).tdt_pop_signal=tdt_pop_signal; 
    ds_events(d).pyr_pop_signal=pyr_pop_signal;


end





function [ratio]=get_ratio(cur_onsets,tr,ds_events,ds)

if strcmp (cur_onsets(tr).condition,'SOM')
   ratio = ds_events(ds).mch_pop_signal(cur_onsets(tr).peak) / ds_events(ds).tdt_pop_signal(cur_onsets(tr).peak); 
   if ds_events(ds).tdt_pop_signal(cur_onsets(tr).peak)<0
        ratio = 10; 
   end

elseif strcmp (cur_onsets(tr).condition,'PV')
                
    ratio = ds_events(ds).tdt_pop_signal(cur_onsets(tr).peak) / ds_events(ds).mch_pop_signal(cur_onsets(tr).peak);
    if ds_events(ds).mch_pop_signal(cur_onsets(tr).peak)<0
        ratio = 10; 
    end


end

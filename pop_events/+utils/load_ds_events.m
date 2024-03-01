function[ds_events]= load_ds_events(type)

if strcmp(type,'standard')
    if ismac
        ds_events=load('/Volumes/Runyan2/Christian/Processed Data/Event Analysis/standard_ds_onsets.mat');
    else
        ds_events=load('Y:\Christian\Processed Data\Event Analysis\standard_ds_onsets.mat')
        
end

ds_events=ds_events.ds_events; 

end

%% behavior analysis of datasets
%1) choose datasets
info.mouse_date={'HA11-1R/2023-05-05','HA11-1R/2023-04-13','HA10-1L/2023-04-10','HA10-1L/2023-04-17','HA2-1L/2023-04-12','HA2-1L/2023-05-05'}; %mice with behavioral responses ,'GS9-1L/2023-01-16','GS8-00/2022-12-20','HA13-1L/2023-02-24','GE3-00/2022-10-20','HA10-1L/2023-03-27-session2'

info.server = {'V:','V:','V:','V:','V:','V:'};%\\runyan-fs-01\Runyan2';
info.savepath = 'V:/Connie/results/VR';%'Y:\Connie\results\PVSOM_opto\lab_meetingmay2023'; %'Y:\Connie\results\opto_figs_sfn'

%% 2)pool imaging data structure from multiple datasets and organize it
[all_celltypes,imaging_st,mouse] = pool_imaging(info.mouse_date,info.server);

%organize so that all mice are within one variable  
[num_cells,sorted_cells] = organize_pooled_celltypes(imaging_st,all_celltypes);

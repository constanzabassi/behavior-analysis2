function save_VR_pooled(savepath,all_celltypes,imaging_st)
if ~isempty(savepath)
    mkdir([savepath '\data_info'])
    cd([savepath '\data_info'])
    save('all_celltypes','all_celltypes');
    save('imaging_st','imaging_st','-v7.3');
    
end
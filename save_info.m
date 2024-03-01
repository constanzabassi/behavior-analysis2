function save_info(info,all_celltypes,imaging_st,mouse,savepath)
if ~isempty(savepath)
    mkdir([savepath '\data_info'])
    cd([savepath '\data_info'])
    save('info','info');
    save('all_celltypes','all_celltypes');
    save('mouse','mouse','-v7.3');
    save('imaging_st','imaging_st','-v7.3');
end
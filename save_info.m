function save_info(info,savepath)
if ~isempty(savepath)
    mkdir([savepath '\data_info'])
    cd([savepath '\data_info'])
    save('info','info');
    
end
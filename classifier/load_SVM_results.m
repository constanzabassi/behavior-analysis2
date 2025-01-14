model_type = 'GLM_3nmf_passive';
missing_indices = [];
for m = 1:length(info.mouse_date)
    mm = info.mouse_date(m);
    mm = mm{1,1};
    ss = info.serverid(m);
    ss = ss {1,1};
    base = (strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/', model_type, '/decoding/'));
    filepath = ([base 'sound_category_svm_info.mat']);
    if isfile(filepath)
        load(filepath);
    else
        disp(['File missing for index: ' num2str(m)]);
        missing_indices = [missing_indices; m-1]; % Record the index of the missing file
    end
end
% Display all missing indices
disp('Indices of datasets with missing files:');
disp(missing_indices);

%%
model_type = 'GLM_3nmf_passive';
task_event_type = 'sound_category';
missing_indices = [];
for m = 1:length(info.mouse_date)
    mm = info.mouse_date(m);
    mm = mm{1,1};
    ss = info.serverid(m);
    ss = ss {1,1};
    base = (strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/', model_type, '/decoding/'));
    filepath = ([base task_event_type '_output.mat']);

end
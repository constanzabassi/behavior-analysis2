function output = classify_over_time(aligned_data,Y,mdl_param)

selected_frames = mdl_param.frames_around;
bin = mdl_param.bin;
ends=zeros(1,length(selected_frames))+bin;
timepoints=[selected_frames;ends];
for t = 1:length(timepoints)
    t
    X = get_X (aligned_data, mdl_param,selected_frames(t));

    %call classifier model
    [~, accuracy(t)] = trainClassifier_cb(X, Y,[1;2],'SVM'); %accuracy(mouse,t)
    %repeat but with suffled Y labels
    Y_shuff=Y(randperm(length(Y)));
    [~, shuff_accuracy(t)] = trainClassifier_cb(X, Y_shuff,[1;2],'SVM'); 

end
%% STORE VARIABLES 
output.accuracy=accuracy; %in Christians accuracy is (datasets,bins)
output.shuff_accuracy=shuff_accuracy; 
output.mdl_param = mdl_param;


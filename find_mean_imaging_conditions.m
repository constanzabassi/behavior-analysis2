function [mean_conditions,imaging_conditions_updated] = find_mean_imaging_conditions(imaging_conditions)
%find the mean across trials so that I can plot the mean of cells per
%condition across datasets
%size = imaging_conditions{1,mouse}{1,conditions}(trials,cells,frames)

temp_mean = {};
for m = 1:length(imaging_conditions)
    temp = cellfun(@(x) mean(x,1),{imaging_conditions{1,m}{1,:}},'UniformOutput',false); %mean across trials
    temp_mean1 = cellfun(@squeeze,temp,'UniformOutput',false);% squeeze to have 2D matrix
    temp_mean(m,:) = temp_mean1;%{m} = temp_mean1;
end

mean_conditions = [];
imaging_conditions_updated ={};
for c = 1:size(temp_mean,2)
    if ~isempty(temp_mean{1,c})
        mean_conditions(c,:,:) = vertcat(temp_mean{:,c});
        imaging_conditions_updated{1,c} = mean_conditions(c,:,:);
    end
    imaging_conditions_updated{2,c} = imaging_conditions{1,1}{2,c};
end

%rebuild structure for plotting later


function value = sort_values (data,sorting_type, sort_index)
data1= squeeze(data);
if sorting_type == 1
    [y_axis,inds] = max(data1(:,sort_index:end),[],2);
    [~,value] = sort(inds,'ascend'); %by time
else
    [y_axis,inds] = max(data1(:,sort_index:end),[],2);
    [~,value] = sort(y_axis,'ascend'); %by max val
end
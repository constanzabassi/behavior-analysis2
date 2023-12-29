function make_heatmap(data,min_max,sorting_type,event_frame)

data1= squeeze(data);

if sorting_type == 1
    [y_axis,inds] = max(data1,[],2);
    [~,value] = sort(inds,'ascend'); %sort(y_axis,'ascend');
    r= 1:length(inds);
    r(value) = r;
    r=r';
    imagesc(data1(value,:)); %by time
    if ~isempty(event_frame)
        xline(event_frame,'-w')
    end
else
    [y_axis,inds] = max(data1,[],2);
    [~,value] = sort(y_axis,'ascend');
    r= 1:length(inds);
    r(value) = r;
    r=r';
    imagesc(data1(value,:)); %by max val
    if ~isempty(event_frame)
        xline(event_frame,'-w')
    end
end
caxis([min_max]);
colorbar;
xlim([0 size(data,2)]);
ylim([0 size(data,1)]);


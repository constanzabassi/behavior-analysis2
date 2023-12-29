function make_heatmap(data,min_max,sorting_type,varargin)

data1= squeeze(data);

if sorting_type == 1
    [y_axis,inds] = max(data1,[],2);
    [~,value] = sort(inds,'ascend'); %sort(y_axis,'ascend');
    r= 1:length(inds);
    r(value) = r;
    r=r';
    imagesc(data1(value,:)); %by time
    if nargin > 3
        for i = 1:length(varargin)
            xline(varargin{i},'-w')
        end
    end
else
    [y_axis,inds] = max(data1,[],2);
    [~,value] = sort(y_axis,'ascend');
    r= 1:length(inds);
    r(value) = r;
    r=r';
    imagesc(data1(value,:)); %by max val
    if nargin > 3
        for i = 1:length(varargin)
            xline(varargin{i},'-w')
        end
    end
end
caxis([min_max]);
colorbar;
xlim([0 size(data,2)]);
ylim([0 size(data,1)]);


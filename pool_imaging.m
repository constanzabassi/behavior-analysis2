function [all_celltypes,imaging_st,mouse,cat_imaging] = pool_imaging(mouse_date,server)
imaging_st = {};
cat_imaging = [];

for m = 1:length(mouse_date)
    mm = mouse_date(m)
    mm = mm{1,1};
    ss = server(m);
    ss = ss {1,1};

    deconv = load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/deconv/deconv.mat'));
    load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/dff.mat'));

    deconv = deconv.deconv;
    load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/VR/imaging.mat'));

    %save raw data for each mouse
    mouse{m}.dff = dff;
    mouse{m}.deconv = deconv;

    %save imaging strucutre for each mouse
    imaging_st{m} = imaging;

    %add info about which mouse it is for big matrix to keep track
    for t = 1:length(imaging)
        imaging(t).mouse = m;
    end

    %save concatenated version (massive matrix)
    if isfield(imaging(1),'relative_frames')
        imaging = rmfield(imaging,'relative_frames');
    end
    cat_imaging = cat(2,cat_imaging,imaging);

end
%load red cells
all_celltypes = {};
for m = 1:length(mouse_date)
    mm = mouse_date(m);
    mm = mm{1,1};
    ss = server(m);
    ss = ss {1,1};
    if isdir(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/red_variables/'))==1
        load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/red_variables/pyr_cells.mat'));
        load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/red_variables/tdtom_cells.mat'));
        load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/red_variables/mcherry_cells.mat'));
        
        all_celltypes{m}.pyr_cells = pyr_cells';
        all_celltypes{m}.som_cells= mcherry_cells;
        all_celltypes{m}.pv_cells= tdtom_cells;
    
        total_sum = [length(all_celltypes{m}.som_cells)+length(all_celltypes{m}.pyr_cells)+length(all_celltypes{m}.pv_cells)];
        if total_sum == size(mouse{1,m}.dff,1) && total_sum == size(mouse{1,m}.deconv,1)
            fprintf([num2str(mm) ': cell numbers are a match!\n'])
        else
            fprintf([num2str(mm) ': cell numbers dont match!\n'])
        end
    end

end

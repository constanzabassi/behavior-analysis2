%% organizing pv, mchery, pyr cells
function [num_cells,sorted_cells,sorted_pv,sorted_som,sorted_pyr] = organize_pooled_celltypes(dff_st,all_celltypes)
sorted_pv = [];
sorted_som = [];
sorted_pyr = [];
num_cells = [];
sorted_cells = {};
%sorted_sig_cells_wilcoxon = [];
for m = 1:length(dff_st)
    num_cells = [num_cells, length(all_celltypes{1,m}.som_cells)+length(all_celltypes{1,m}.pyr_cells)+length(all_celltypes{1,m}.pv_cells)];
    if m ==1
    sorted_som = [sorted_som ; all_celltypes{1,m}.som_cells];
    sorted_pyr = [sorted_pyr ; [all_celltypes{1,m}.pyr_cells]];
    sorted_pv = [sorted_pv ; all_celltypes{1,m}.pv_cells];
    else %add cellcount from previously to make sure they numbers make sense
    temp = sum(num_cells(1:m-1));
    sorted_som = [sorted_som ; (all_celltypes{1,m}.som_cells+temp)];
    sorted_pv = [sorted_pv ; (all_celltypes{1,m}.pv_cells+temp)];
    sorted_pyr = [sorted_pyr ; ([all_celltypes{1,m}.pyr_cells]+temp)];
    end
end
sorted_cells.pyr = sorted_pyr;
sorted_cells.som = sorted_som;
sorted_cells.pv = sorted_pv;
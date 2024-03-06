function num_responsive = unpack_responsive(responsive_neurons, all_celltypes)
all_cells =[cellfun(@(x) x.pyr_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.som_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.pv_cells,all_celltypes,'UniformOutput',false)];
num_cells = cellfun(@length, all_cells );
%{cell types, dataset}

possible_celltypes = fieldnames(all_celltypes{1,1});
num_responsive =[];
for m = 1:length(all_celltypes)
    for task_period = 1:length(responsive_neurons{1,m})
        for ce = 1:3
            if sum(ismember(all_celltypes{1,m}.(possible_celltypes{ce}),responsive_neurons{1,m}{1,task_period})) >0
                num_responsive(m,task_period,ce) = (sum(ismember(all_celltypes{1,m}.(possible_celltypes{ce}),responsive_neurons{1,m}{1,task_period}))/num_cells(ce,m))*100;
            else
                num_responsive(m,task_period,ce) = 0;
            end
        end
    end
end
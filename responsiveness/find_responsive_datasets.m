all_f = zeros(25,3,6);
possible_celltypes = fieldnames(all_celltypes{1,1});

for f = 1:6
    for i = 1:25;
        for ce = 1:3
            all_f(i,ce,f) = length(find(ismember(all_celltypes{1,i}.(possible_celltypes{ce}),responsive_neuron2{1,i}{1,f})));
        end
    end
end
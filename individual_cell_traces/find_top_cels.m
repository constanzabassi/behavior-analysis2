function best_cels = find_top_cels(beta_cel,num_cells)

for d = 1:size(beta_cel.pyr,1)
    [~,sorted] = sort(abs(beta_cel.pyr{d,1,1}),'descend');
    best_cels.pyr(d,:) = sorted(1:num_cells);

    [~,sorted] = sort(abs(beta_cel.som{d,1,1}),'descend');
    best_cels.som(d,:) = sorted(1:num_cells);

    [~,sorted] = sort(abs(beta_cel.pv{d,1,1}),'descend');
    best_cels.pv(d,:) = sorted(1:num_cells);

end
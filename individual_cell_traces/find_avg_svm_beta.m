function [avg_beta,betas_cel] = find_avg_svm_beta (betas,all_celltypes,bins_chosen)

for dataset = 1:size(betas,2)
    for b = 1:length(bins_chosen)
        mean_across = mean([betas{:,dataset,bins_chosen(b)}],2);
        avg_beta{dataset,:,b} = mean_across; %mean across all cells!
        betas_cel.pyr{dataset,:,b} = mean_across(all_celltypes{1,dataset}.pyr_cells);
        betas_cel.som{dataset,:,b} = mean_across(all_celltypes{1,dataset}.som_cells);
        betas_cel.pv{dataset,:,b} = mean_across(all_celltypes{1,dataset}.pv_cells);
    end
end

function [avg_beta,beta_cel] = find_avg_svm_beta (betas,all_celltypes,bins_chosen)

for dataset = 1:size(betas,2)
    mean_across = mean([betas{:,1,4}],2);
    avg_beta{dataset,:} = mean_across; %mean across all cells!
    betas_cel.pyr = mean_across(all_celltypes{1,dataset}.pyr_cells);
    betas_cel.som = mean_across(all_celltypes{1,dataset}.som_cells);
    betas_cel.pv = mean_across(all_celltypes{1,dataset}.pv_cells);
end

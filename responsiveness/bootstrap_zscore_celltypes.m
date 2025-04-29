function [z_scores, pvals] = bootstrap_zscore_celltypes(current_aligned_dataset_all, all_celltypes, task_period, celltype_list, num_boot)

% Inputs:
% - current_aligned_dataset_all: cell array {dataset} of [trials x neurons x time]
% - all_celltypes: cell array {dataset} with fields pyr_cells, som_cells, pv_cells
% - task_period: [start_idx end_idx] of time window (e.g. [10 20])
% - celltype_list: {'pyr_cells','som_cells','pv_cells'}
% - num_boot: number of bootstrap iterations

% Outputs:
% - z_scores: matrix of z-scores [#celltype comparisons x 1]
% - pvals: same size, empirical p-values for bootstrap test

n_datasets = numel(current_aligned_dataset_all);
n_celltypes = numel(celltype_list);

% Preallocate
celltype_means = cell(n_celltypes, 1);

% Pool mean responses across datasets
for c = 1:n_celltypes
    all_means = [];
    for d = 1:n_datasets
        dataset = current_aligned_dataset_all{d}; % trials x neurons x time
        f = squeeze(dataset(:,:,task_period(1):task_period(2))); % time window
        m = squeeze(mean(f,3)); % trials x neurons
        ct_idx = all_celltypes{d}.(celltype_list{c});
        if isempty(ct_idx), continue; end
        all_means = [all_means; mean(m(:, ct_idx), 1)']; % each neuron's mean
    end
    celltype_means{c} = all_means; % [neurons x 1]
end

% Bootstrap between each pair of cell types
combos = nchoosek(1:n_celltypes, 2);
n_comps = size(combos, 1);
z_scores = zeros(n_comps, 1);
pvals = zeros(n_comps, 1);

for i = 1:n_comps
    a = combos(i,1); b = combos(i,2);
    A = celltype_means{a}; B = celltype_means{b};
    
    if isempty(A) || isempty(B)
        z_scores(i) = NaN;
        pvals(i) = NaN;
        continue;
    end
    
    diff_obs = mean(A) - mean(B);

    % Bootstrap
    boot_diffs = zeros(num_boot,1);
    pooled = [A; B];
    nA = numel(A);
    
    for b_iter = 1:num_boot
        idx = randperm(numel(pooled));
        A_b = pooled(idx(1:nA));
        B_b = pooled(idx(nA+1:end));
        boot_diffs(b_iter) = mean(A_b) - mean(B_b);
    end
    
    z_scores(i) = (diff_obs - mean(boot_diffs)) / std(boot_diffs);
    pvals(i) = mean(abs(boot_diffs) >= abs(diff_obs)); % two-tailed
end

function zscore_output = zscore_responsive_fraction(responsive_neuron, all_celltypes, total_neurons, num_shuff)
% Inputs:
%   responsive_neuron – cell array per epoch with IDs of responsive neurons
%   all_celltypes     – structure with fields pyr_cells, som_cells, pv_cells (neuron IDs for current dataset)
%   total_neurons     – total number of neurons in the dataset (e.g., size(current_aligned_dataset,2))
%   num_shuff         – number of shuffles for null distribution
%
% Output:
%   zscore_output     – struct with z-scores and raw fractions for each cell type and epoch

celltypes = {'pyr', 'som', 'pv'};
n_epochs = length(responsive_neuron);
zscore_output = struct();

for epoch = 1:n_epochs
    resp_ids = responsive_neuron{epoch};
    zscore_output(epoch).epoch = epoch;

    for ct = 1:length(celltypes)
        celltype = celltypes{ct};
        ct_ids = all_celltypes.(sprintf('%s_cells', celltype)); % neuron indices for this type
        ct_ids = ct_ids(ct_ids <= total_neurons); % prevent out-of-bound IDs

        % Observed fraction
        n_in_type = length(ct_ids);
        if n_in_type == 0
            zscore_output(epoch).(celltype).zscore = NaN;
            zscore_output(epoch).(celltype).observed_fraction = NaN;
            continue;
        end
        n_resp = sum(ismember(ct_ids, resp_ids));
        observed_frac = n_resp / n_in_type;

        % Null distribution
        null_fracs = zeros(1, num_shuff);
        for s = 1:num_shuff
%             rand_ids = randperm(total_neurons, n_in_type);
            rand_pool = ct_ids;  % only sample from this cell type
            rand_ids = rand_pool(randperm(length(rand_pool), n_in_type));

            n_resp_rand = sum(ismember(rand_ids, resp_ids));
            null_fracs(s) = n_resp_rand / n_in_type;
        end

        % Z-score
        mu_null = mean(null_fracs);
        std_null = std(null_fracs);
        zval = (observed_frac - mu_null) / std_null;

        % Save
        zscore_output(epoch).(celltype).zscore = zval;
        zscore_output(epoch).(celltype).observed_fraction = observed_frac;
        zscore_output(epoch).(celltype).null_distribution = null_fracs;
    end
end
end

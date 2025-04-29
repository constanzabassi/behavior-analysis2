function [responsive_neuron,responsive_neuron_prctile,neuron_zscores] = find_responsive_neurons(task_period,current_aligned_dataset,params)
num_shuff = params.num_shuff;
p_thr = params.p_thr ;
responsive_neuron = cell(1,size(task_period,1));
responsive_neuron_prctile = cell(1,size(task_period,1));
for neuron = 1:size(current_aligned_dataset,2) %number of neurons
    neuron
    f = squeeze(current_aligned_dataset(:,neuron,:));%squeeze(S_data{a}(i,:,:));
    for task_epoch = 1:size(task_period,1) %number of different task periods to test
        ts_ctrl = setdiff(1:size(current_aligned_dataset,3), task_period(task_epoch,:));
        v = nanmean(f(:,task_period(task_epoch,:)),2); v0 = [];
        n1 = length(ts_ctrl); n2 = min(n1, length(task_period(task_epoch,:)));
        for s = 1:num_shuff
            idx = randperm(n1, n2);
            v0(:,s) = nanmean(f(:,ts_ctrl(idx)),2);
        end
        v = v(~isnan(v)); v0 = v0(~isnan(v0));

        try; pval = ranksum(v, v0(:), 'tail', 'right');
        catch ME; pval = NaN;
        end

        if pval<p_thr && (nanmean(v(:))-nanmean(v0(:)))>0.01
%             if pval<p_thr
            responsive_neuron{task_epoch}(end+1) = neuron;
            
        end
        if nanmean(v) > prctile(v0,95)
            responsive_neuron_prctile{task_epoch}(end+1) = neuron;
        end

        mu_v = nanmean(v);
        mu_v0 = nanmean(v0);
        std_v0 = nanstd(v0);

        % Compute z-score or d-prime
        zscore_val = (mu_v - mu_v0) / std_v0;
        neuron_zscores{task_epoch}(neuron) = zscore_val;
    end
end
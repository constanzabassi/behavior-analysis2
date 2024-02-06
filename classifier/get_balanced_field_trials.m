function [selected_trials,lc_selected,rc_selected] = get_balanced_field_trials(imaging,selected_field_num)

fieldss = fieldnames(imaging(1).virmen_trial_info);
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!


selected_trials = false(1, length(good_trials));
virmen_trial_info = [imaging(good_trials).virmen_trial_info];

if length(selected_field_num)==1
condition = [virmen_trial_info.(fieldss{selected_field_num})];

unique_cond = unique(condition);
for c = 1:length(unique_cond)
    conds{c} = find(condition == unique_cond(c));
end


% make sure that each of these groups is equally represented in
% the training trials, to ensure that stimulus category and
% behavioural choice are uncorrelated.

smallest_set_size = min(cellfun(@length ,conds));
lc_selected = randsample(conds{1}, smallest_set_size);
rc_selected = randsample(conds{2}, smallest_set_size);
selected_trials(lc_selected) = true;
selected_trials(rc_selected) = true;

smallest_set_size
else
condition = [virmen_trial_info.(fieldss{selected_field_num(1)})]-1;
condition2 = [virmen_trial_info.(fieldss{selected_field_num(2)})];


unique_cond = unique(condition);
for c = 1:length(unique_cond)
    conds{c} = find(condition == unique_cond(c));
end

lc = condition & condition2;
li = condition & ~condition2;
rc = ~condition & condition2;
ri = ~condition & ~condition2;

% make sure that each of these groups is equally represented in
% the training trials, to ensure that stimulus category and
% behavioural choice are uncorrelated.

smallest_set_size = min([nnz(lc), nnz(li), nnz(rc), nnz(ri)]);
lc_selected = randsample(find(lc), smallest_set_size);
li_selected = randsample(find(li), smallest_set_size);
rc_selected = randsample(find(rc), smallest_set_size);
ri_selected = randsample(find(ri), smallest_set_size);
selected_trials(lc_selected) = true;
selected_trials(li_selected) = true;
selected_trials(rc_selected) = true;
selected_trials(ri_selected) = true;

end

end
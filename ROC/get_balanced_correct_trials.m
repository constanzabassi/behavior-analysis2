function selected_trials = get_balanced_correct_trials(condition_array_trials)

selected_trials = false(1, length(condition_array_trials));
correctness = condition_array_trials(:,2);
left_choice_ness = condition_array_trials(:,3);

% find out left/correct, right/correct,

lc = left_choice_ness & correctness;
rc = ~left_choice_ness & correctness;

% make sure that each of these groups is equally represented in
% the training trials, to ensure that stimulus category and
% behavioural choice are uncorrelated.
smallest_set_size = min([nnz(lc),  nnz(rc) ]);
lc_selected = randsample(find(lc), smallest_set_size);
rc_selected = randsample(find(rc), smallest_set_size);
selected_trials(lc_selected) = true;
selected_trials(rc_selected) = true;
 
smallest_set_size
end

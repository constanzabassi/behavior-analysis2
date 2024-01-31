function [pos_sig,neg_sig] = determine_sig_cells(real_values,shuff_values)
% Assumes shuff_values(neurons, number of shuffles)

% determine significance
for cel = 1:length(real_values)
    if real_values(cel)> prctile(shuff_values(cel,:),99)%mod_index(cel)>0 && mod_index(cel)> prctile(shuff_values(:,cel),97.5)
        pos_sig(cel)= 1;
    else
        pos_sig(cel) =0;
    end
    if real_values(cel)< prctile(shuff_values(cel,:),1)%mod_index(cel)<0 && mod_index(cel)< prctile(shuffled_mod_index(:,cel),2.5)
        neg_sig(cel) = 1;
    else
        neg_sig(cel) = 0;
    end
end
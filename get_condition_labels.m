function combined_string_label = get_condition_labels(condition_values)
    % Map condition values to labels
    labels = cell(1, numel(condition_values));

    % Define labels based on condition values
    for i = 1:numel(condition_values)
        if i == 1
            if condition_values(i) == 1
                labels{i} = "Correct" ;
            else
                labels{i} = "Incorrect";
            end
        elseif i == 2
            if condition_values(i) == 1
                labels{i} = "Left" ;
            else
                labels{i} = "Right";
            end
        elseif i == 3
            if condition_values(i) == 1
                labels{i} = "Stim" ;
            else
                labels{i} = "Control";
            end
        end
    end
    % Convert individual strings into a single concatenated string
    combined_string_label = strjoin(string(labels), '/');

end
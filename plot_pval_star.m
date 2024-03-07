function plot_pval_star(x_val, y_val, p, xline_vars)
%%% assumes distance between three is x_seq = [-0.2, 0, 0.2];

% Add significance symbols based on p-value
if p < 0.001
    sig_symbol = '***';
elseif p < 0.01
    sig_symbol = '**';
elseif p < 0.05
    sig_symbol = '*';
else
    sig_symbol = '';
end

% Determine the height of text based on the maximum value of the boxplot
yMax = y_val;%max(max(whiskerplot([data1; data2])));
text_height = yMax;

% Plot significance symbol
if ~isempty(sig_symbol)
    text(x_val+mean([xline_vars(1),xline_vars(2)]), text_height, sig_symbol, 'HorizontalAlignment', 'center', 'Color', 'k','FontSize',14);
    

    line([x_val+xline_vars(1), x_val+xline_vars(2)], [y_val-0.15, y_val-0.15], 'Color', 'k', 'LineWidth', 0.5);

end

% hold off;



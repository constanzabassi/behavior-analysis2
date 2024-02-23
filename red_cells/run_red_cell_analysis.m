% get red cell info
plot_info.colors_celltype = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04 % red  
                            0 0 0.5]; %dark purple

[all_sil,missing_data] = get_red_silhouettes(info,plot_info,[info.savepath '/red_cell_analysis']);
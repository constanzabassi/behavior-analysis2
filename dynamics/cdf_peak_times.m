function p_cdf =  cdf_peak_times(max_cel_mode,dynamics_info,all_celltypes,plot_info,info)
binss = 1:length(dynamics_info.binss);
possible_celltypes = fieldnames(all_celltypes{1,1});
figure(62);clf;
hold on;
for ce = 1:3
    cdf = [];
    cdf_cat = [];
    for m = 1:size(max_cel_mode,1) 
        current_max = [max_cel_mode{m,all_celltypes{1,m}.(possible_celltypes{ce})}];
        [cdf_temp,p1] = make_cdf(current_max,binss); %find(ismember(sorted_sig_cells,sorted_pyr)
        cdf = [cdf;cdf_temp];
        cdf_cat = [cdf_cat,cdf_temp];
    end
    mean_cdf = mean(cdf,1); %find mean across datasets
    
    %make plots
    
    %a(ce) = plot(binss,mean_cdf);
    SEM= std(cdf)/sqrt(size(cdf,1));
    a(ce) = shadedErrorBar(1:size(cdf,2),mean(cdf,1), SEM, 'lineProps',{'color', plot_info.colors_celltype(ce,:)});

    for i = 1:length(dynamics_info.new_onsets)
        xline(dynamics_info.new_onsets(i),'--k','LineWidth',1.5)
    end

%     set( a(ce), 'LineWidth', 1.5, 'LineStyle', lineStyles_contexts{c}, 'color',colors(1,:));%linecolors(2,:));
    cdf_all{ce} = mean_cdf;
    cdf_cat_all{ce} = cdf_cat;


end

hold off

ylim([0 1])
xlim([1 binss(end)])
ylabel('Cumulative Fraction of Peak Times')
% xlabel('Modulation Index')
set(gca,'fontsize',14)
set(gca, 'box', 'off', 'xtick', [])

%permutation test
possible_tests = nchoosek(1:3,2);

ct = 0;
for t = 1:length(possible_tests)
    [p_cdf(t), observeddifference, effectsize] = permutationTest(cdf_cat_all{1,possible_tests(t,1)}, cdf_cat_all{1,possible_tests(t,2)}, 10000);
    
    if p_cdf(t) < 0.05
        xline_vars(1) = binss(find(cdf_all{1,possible_tests(t,1)} > 0.86+ct,1,'first')); 
        xline_vars(2) = binss(find(cdf_all{1,possible_tests(t,2)} > 0.86+ct,1,'first')); 
        xval = 0;  
        plot_pval_star(xval, 0.87+ct, p_cdf(t), xline_vars,0.01)
        ct = ct+0.03;
    end
end

%do legend after significance data are not added to legend
legend([a(1).mainLine a(2).mainLine a(3).mainLine],'PYR', 'SOM', 'PV', 'Location', 'southeast');

if ~isempty(info)
    mkdir([info.savepath '\frc_dynamics'])
    cd([info.savepath '\frc_dynamics'])
    if length(dynamics_info.conditions) < 8
    saveas(62,strcat('cdf_max_peak',num2str(unique(diff(dynamics_info.binss))),'_condition',num2str(dynamics_info.conditions),'_nbins',num2str((dynamics_info.bin_size)),'.svg'));
    saveas(62,strcat('cdf_max_peak',num2str(unique(diff(dynamics_info.binss))),'_condition',num2str(dynamics_info.conditions),'_nbins',num2str((dynamics_info.bin_size)),'.png'));

    else
    saveas(62,strcat('cdf_max_peak',num2str(unique(diff(dynamics_info.binss))),'_nbins',num2str((dynamics_info.bin_size)),'.svg'));
    saveas(62,strcat('cdf_max_peak',num2str(unique(diff(dynamics_info.binss))),'_nbins',num2str((dynamics_info.bin_size)),'.png'));

    end
end
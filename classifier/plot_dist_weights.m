function plot_dist_weights(bin_id, betas,all_celltypes,plot_info,output,svm_info)
possible_celltypes = fieldnames(all_celltypes{1,1});


figure(572);clf;
[rows,columns] = determine_num_tiles(size(betas,2)); %uses length of input
tiledlayout(rows,columns);

edges = -1:0.1:1; %bin edges can be changed

for m = 1:size(betas,2) %per mouse

    all_data = [betas{:,m,bin_id}]; %neurons x num_iterations
    nexttile
    hold on;

    for ce = 1:3
        ex_mouse = m;
        
        % Plotting the histogram %PLOT standard error of the mean across
        % subsample iterations
        
        mean_data = mean(all_data(all_celltypes{1,m}.(possible_celltypes{ce}),:),2); %find mean for specified cells across all subsamples
        [mean_prob]= get_hist(mean_data,edges);
        [across_prob] = get_hist(all_data(all_celltypes{1,m}.(possible_celltypes{ce}),:),edges);%cellfun(@(x) get_hist(x,edges),{all_data(all_celltypes{1,m}.(possible_celltypes{ce}),:)},'UniformOutput',false);%probability values for each cell across subsamples


        SEM= std(across_prob')/sqrt(size(across_prob,2)); %frames/num iterations
        shadedErrorBar(edges,mean_prob, SEM, 'lineProps',{'color', plot_info.colors_celltype(ce,:),'LineWidth', 1.5});
    end

    % Adding labels and title
    xlabel('Classifier Weight');
    ylabel({'Probability'});
    title(svm_info.mouse_date(m));

end
hold off

mkdir([svm_info.savepath '\SVM_' output{1,1,1}.mdl_param.data_type '_' svm_info.savestr]);
cd([svm_info.savepath '\SVM_' output{1,1,1}.mdl_param.data_type '_' svm_info.savestr]);
% save('roc_mdl','roc_mdl');
saveas(572,strcat('SVM_weights_across_cells_bin',num2str(bin_id),'.png'));
saveas(572,strcat('SVM_weights_across_cells_bin',num2str(bin_id),'.svg'));

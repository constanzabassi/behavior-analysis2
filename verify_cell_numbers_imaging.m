%%%call context decoder
load('V:\Connie\results\opto_2024\context\data_info\info.mat')
save_string = 'GLM_3nmf_pre';
num_splits = 10; %normally 10
testing_datasets = [1:25]; %datasets to look at


for m = testing_datasets;
    mm = info.mouse_date(m);
    mm = mm{1,1};
    ss = info.server(m);
    ss = ss {1,1};
    vr =  load(strcat(ss,'/Connie/ProcessedData/',mm,'/VR/imaging.mat')); %imaging dir to load imaging.mat
    pass = load(strcat(ss,'/Connie/ProcessedData/',mm,'/passive/imaging.mat')); %imaging dir to load imaging.mat

    empty_trials = find(cellfun(@isempty,{vr.imaging.good_trial}));
    good_trials =  setdiff(1:length(vr.imaging),empty_trials); 
    
%load the red cell IDs
  load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/red_variables/pyr_cells.mat'));
  load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/red_variables/tdtom_cells.mat')); %PV
  load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/red_variables/mcherry_cells.mat')); %SOM

  %check to make sure numbers match!!
  total_cells = length(pyr_cells)+length(tdtom_cells)+length(mcherry_cells);
  if size(vr.imaging(good_trials(1)).dff,1) == total_cells && size(pass.imaging(1).dff,1) == total_cells
      fprintf([num2str(mm) ': cell numbers are a match!\n'])
  else
      fprintf([num2str(mm) ': cell numbers ARE NOT match!\n'])
  end
end
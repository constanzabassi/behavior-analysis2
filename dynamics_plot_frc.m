[max_cel_avg,~, binss] = fraction_dynamics (imaging_st,alignment,3);
event_onsets = determine_onsets(left_padding,right_padding,[1:6]);
new_onsets = find(histcounts(event_onsets,binss));

frc=histcounts(max_cel_avg(2,:),1:length(binss))./381;
figure(55);clf;
hold on;
plot(frc,'LineWidth',1.5)
for i = 1:length(new_onsets)
    xline(new_onsets(i),'--k','LineWidth',1.5)
end
hold off
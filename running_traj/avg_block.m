% Helper to average stacked blocks (each block = 5 rows: nonSst, SOM, dev, vel, accel)
function out = avg_block(stack_block, t)
if isempty(stack_block), out = []; return; end
n = size(stack_block,1)/5; K = 5;
M = reshape(stack_block, [K, n, size(stack_block,2)]);
out.t = t; out.nonsst = squeeze(mean(M(1,:,:),2,'omitnan'));
out.som   = squeeze(mean(M(2,:,:),2,'omitnan'));
out.dev   = squeeze(mean(M(3,:,:),2,'omitnan'));
out.vel   = squeeze(mean(M(4,:,:),2,'omitnan'));
out.acc   = squeeze(mean(M(5,:,:),2,'omitnan'));
end
% we need the time axis; grab from last ETA we computed
taxis = (-round(WIN(1)*Fs):round(WIN(2)*Fs))/Fs;
G  = avg_block(stack.g, taxis);
H0 = avg_block(stack.h_low,  taxis);
H1 = avg_block(stack.h_high, taxis);
I0 = avg_block(stack.i_low,  taxis);
I1 = avg_block(stack.i_high, taxis);
J0 = avg_block(stack.j_low,  taxis);
J1 = avg_block(stack.j_high, taxis);
figure(22); clf
labels = {'Non-Sst','SOM','Heading dev (rad)','Turn vel (rad/s)','Turn accel (rad/s^2)'};
panels = {'g: enter T','h: low dev','h: high dev','i: low accel','i: high accel','j: low dev','j: high dev'};
DATA = {G,H0,H1,I0,I1,J0,J1};
for pp = 1:numel(DATA)
    if isempty(DATA{pp}), continue; end
    for r = 1:5
        subplot(5, numel(DATA), (r-1)*numel(DATA)+pp); hold on
        switch r
            case 1, plot(DATA{pp}.t, DATA{pp}.nonsst, 'Color',[.6 .6 .6], 'LineWidth',1.5);
            case 2, plot(DATA{pp}.t, DATA{pp}.som,   'Color',[0.1 0.3 0.8], 'LineWidth',1.5);
            case 3, plot(DATA{pp}.t, DATA{pp}.dev,   'k','LineWidth',1.2); ylim([-pi pi]);
            case 4, plot(DATA{pp}.t, DATA{pp}.vel,   'k','LineWidth',1.2);
            case 5, plot(DATA{pp}.t, DATA{pp}.acc,   'k','LineWidth',1.2);
        end
        xline(0,'k:'); yline(0,'k:');
        if r==1, title(sprintf('%s\n(n=%d events)', panels{pp}, size(evalin('caller','stack'),2))); end %#ok<EVLC>
        if pp==1, ylabel(labels{r}); end
        xlim([DATA{pp}.t(1), DATA{pp}.t(end)]);
    end
end
set(gcf,'Color','w'); drawnow
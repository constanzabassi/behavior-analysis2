function save_figures(fignum,folder,filename)

if ismac
    saveas(fignum,['/Users/christianpotter/Dropbox/Dual Labeling Paper/V2/',folder,'/',filename],'pdf')
    saveas(fignum,['/Users/christianpotter/Dropbox/Dual Labeling Paper/V2/',folder,'/',filename],'fig')
else
    saveas(fignum,['C:\Users\Runyan1\Dropbox\Dual Labeling Paper\V2\',folder,'\',filename],'pdf')
    saveas(fignum,['C:\Users\Runyan1\Dropbox\Dual Labeling Paper\V2\',folder,'\',filename],'fig')
end
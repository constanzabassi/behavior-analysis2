function [sptitle]=make_title(param,bin_size)


if strcmp(param.stat,'avg')
    if strcmp(param.type,'before')
        b=num2str(100-param.be(1)); 
        bsize=num2str(param.be(2)); 
        exthresh=param.exthresh; 
        sptitle={[bsize,' frame bins, ',b,' frames before onset'],['bin size = ',num2str(bin_size),' | exclusion threshold = ',num2str(exthresh)]}; 
    else
        b=num2str(param.be(1)); 
        bsize=num2str(param.be(2)); 
        exthresh=param.exthresh; 
        sptitle={[bsize,' frame bins, ',b,' frames after ',param.type],['bin size = ',num2str(bin_size),' | exclusion threshold = ',num2str(exthresh)]}; 
    end
else
    if strcmp(param.type,'before')
        b=num2str(100-param.be(1)); 
        bsize=num2str(param.be(2)); 
        exthresh=param.exthresh; 
        sptitle={[bsize,' frames, ',b,' frames before onset'],['bin size = ',num2str(bin_size),' | exclusion threshold = ',num2str(exthresh)]}; 
    else
        b=num2str(param.be(1)); 
        bsize=num2str(param.be(2)); 
        exthresh=param.exthresh; 
        sptitle={[bsize,' frames, ',b,' frames after ',param.type],['bin size = ',num2str(bin_size),' | exclusion threshold = ',num2str(exthresh)]}; 
    end
end

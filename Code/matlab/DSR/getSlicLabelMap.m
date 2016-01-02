function sulabel = getSlicLabelMap(imName, compactness, spnumber, r, c)

comm=['SLICSuperpixelSegmentation' ' ' imName ' ' int2str(compactness) ' ' int2str(spnumber) ' '];
system(comm); 
sulabel = ReadDAT([r,c],[imName(1:end - 4) '.dat']);
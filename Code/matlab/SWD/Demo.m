function Demo()

     winSize = 14; %size of each patch: 14x14
     rdDim = 11; %reducing to 11 dimensions
     sigma = 3; %sigma of Gaussian used for smoothing the saliency map

     imgName = '22.jpg';

     imageSaliency = Wu_ImageSaliencyComputing( imgName, winSize, rdDim, sigma);
     imshow(imageSaliency, []);

return;

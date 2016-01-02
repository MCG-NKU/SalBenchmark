
%
%  This code demonstrates how to compute a saliency map using the Image Signature
% 

close all;
clc;

figure;

numImgs = 5;

for imgNum = 1 : numImgs

  fprintf('Computing saliency maps for sample image %d...\n', imgNum);

  img = imread(sprintf('samplepics/%d.jpg',imgNum));

  labMap = signatureSal( img );
  
  paramRGB = default_signature_param;
  paramRGB.colorChannels = 'rgb';

  rgbMap = signatureSal( img , paramRGB );
  
  rgbMap = signatureSal( img , paramRGB );

  
  clf;
  subplot(1,2,1);
  show_imgnmap2( img , labMap );
  title( sprintf('Sample Image %d: Image Signature - LAB', imgNum ) );

  subplot(1,2,2);
  show_imgnmap2( img , rgbMap );
  title( sprintf('Sample Image %d: Image Signature - RGB', imgNum ) );

  if ( imgNum < numImgs )
    fprintf('\n\tWaiting for keypress to continue...\n\n');
    pause;
  end

end
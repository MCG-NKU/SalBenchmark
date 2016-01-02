function salmapSmooth = saliencymap(imfile, options)

salSize   = options.size;
ratio     = options.quantile;
modeltype = options.modeltype;

% read image
disp('Reading image.');
g = double(imread(imfile));
[height, width, ch] = size(g);
Img = g;

%resize the original image
if height > width
    Img = imresize(g, [salSize salSize]);
else
    Img = imresize(g, [salSize salSize]);
end

Img = Img + 2.0*randn(size(Img));
[height, width, ch] = size(Img);

% Extract visual features
disp('Extracting image features..');
I = (Img(:,:,1)+Img(:,:,2)+Img(:,:,3))/3;
d = [-1 0 1];
Iy = imfilter(I,d,'symmetric','same','conv');
Ix = imfilter(I,d','symmetric','same','conv');
[L, a, b] = RGB2Lab(Img);
[s2, s1] = meshgrid(1:width,1:height);

F = zeros(height,width,5);
F(:,:,1) = L;
F(:,:,2) = a;
F(:,:,3) = b;
F(:,:,4) = abs(Ix);
F(:,:,5) = abs(Iy);
F(:,:,6) = s1;
F(:,:,7) = s2;

% Calculate integral images for fast computation of covariance
disp('Calculating integral images...');
fiimage = integralimage(F);
fsoiimage = sointegralimage(F);

disp('Computing saliency map....');
patch_sizes = salSize * 2.^(-6:-2);
k=1;
m=3;
for ki=patch_sizes
    disp(['scale: ',num2str(k),'/5']);
    ld = [];
    for i=1:ki:height-ki+1
        for j=1:ki:width-ki+1
            x2=j;
            y2=i;
            x3=min(width,j+ki);
            y3=min(height,i+ki);
            
            [Cov1 M1] = iicov(fiimage, fsoiimage, [y2 x2], [y3 x3]);
            
            if strcmp(modeltype,'SigmaPoints')
                covC = Cov1 + 0.001*eye(size(Cov1));
                covC = 2*(size(covC,1)+0.1)*covC;
                L = chol(covC);
                
                li = L(:);
                for kk=1:size(covC,1)*size(covC,1)
                    li(kk) = li(kk)+M1(mod(kk-1,size(covC,1))+1);
                end
                lj = L(:);
                for kk=1:size(covC,1)*size(covC,1)
                    lj(kk) = M1(mod(kk-1,size(covC,1))+1)-lj(kk);
                end
                resRef = [M1 li' lj'];
            end
            
            d = [];
            for ii=max(1,i-m*ki):ki:min(height,i+m*ki)
                for jj=max(1,j-m*ki):ki:min(width,j+m*ki)
                    if ii==i && jj==j
                        continue;
                    end
                    
                    x2=jj;
                    y2=ii;
                    x3=min(width,jj+ki);
                    y3=min(height,ii+ki);
                    
                    [Cov2 M2] = iicov(fiimage, fsoiimage, [y2 x2], [y3 x3]);
                    if strcmp(modeltype,'CovariancesOnly')
                        d = [d; covdist(Cov1, Cov2)/(1+norm([i-ii,j-jj]))];
                    elseif strcmp(modeltype,'SigmaPoints')
                        covC = Cov2 + 0.001*eye(size(Cov2));
                        covC = 2*(size(covC,1)+0.1)*covC;
                        L = chol(covC);
                        li = L(:);
                        for kk=1:size(covC,1)*size(covC,1)
                            li(kk) = li(kk)+M2(mod(kk-1,size(covC,1))+1);
                        end
                        lj = L(:);
                        for kk=1:size(covC,1)*size(covC,1)
                            lj(kk) = M2(mod(kk-1,size(covC,1))+1)-lj(kk);
                        end
                        resRef2 = [M2 li' lj'];
                        
                        d = [d; norm(resRef - resRef2)/(1+norm([i-ii,j-jj]))];
                    end
                end
            end
            dummy = sort(d,'ascend');
            if options.centerBias==1
                S{k}.map(floor(i/ki)+1,floor(j/ki)+1) = (1-norm([i+ki/2-(0.5*salSize),j+ki/2-(0.5*salSize)])/norm([1-(0.5*salSize),1-(0.5*salSize)]))*sum(dummy(1:floor(length(d)*ratio))/floor(length(d)*ratio));
            else
                S{k}.map(floor(i/ki)+1,floor(j/ki)+1) = sum(dummy(1:floor(length(d)*ratio))/floor(length(d)*ratio));
            end
        end
    end
    k=k+1;
end

salmap = ones(size(height,width));
k=1;
for ki=patch_sizes
    salmap = salmap .* imresize(S{k}.map,[height,width]);
    k = k+1;
end

[height, width, ch] = size(g);
salmap = imresize(salmap, [height, width] , 'bilinear');

disp('Smoothing saliency map.....');
kSize = size(g,2)*0.02; 
salmapSmooth = imfilter(salmap, fspecial('gaussian', round([kSize, kSize]*4), kSize));
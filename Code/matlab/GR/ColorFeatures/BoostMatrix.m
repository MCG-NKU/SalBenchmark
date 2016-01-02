function [Mboost,U,S] = BoostMatrix(image,order,sigma)
% computes boost-matrix, Mboost, from a single image or a list of images:
%
% image:
%   1. class(image) = double   input is a single color image (w*h*3)
%   2. class(image) = char     input is a file which contains a list of image_names.
% order:
%       order of differentiation. For standard color boosting the first
%       order derivatives are used (order=1)
% sigma:
%       sigma of Gaussian derivative

if(nargin<2)
    order=1;
    sigma=1;
end

if(ischar(image))               % image is a file containing image names
    fid1=fopen(image,'r');
    if(fid1<0) 
        display('cannot find file 3');
        return;
    end
    M=zeros(3);
    image_counter=0;
    while(~feof(fid1))          % loop over images 
        image_counter=image_counter+1;
        image_name=fgetl(fid1);
        a=double(imread(image_name));        
        
        if(order==0)
            R=reshape(a(:,:,1),1,size(a,1)*size(a,2));
            G=reshape(a(:,:,2),1,size(a,1)*size(a,2));
            B=reshape(a(:,:,3),1,size(a,1)*size(a,2));
        else
            R=reshape([  gDer(a(:,:,1),sigma,1,0), gDer(a(:,:,1),sigma,0,1)],1,2*size(a,1)*size(a,2));
            G=reshape([  gDer(a(:,:,2),sigma,1,0), gDer(a(:,:,2),sigma,0,1)],1,2*size(a,1)*size(a,2));
            B=reshape([  gDer(a(:,:,3),sigma,1,0), gDer(a(:,:,3),sigma,0,1)],1,2*size(a,1)*size(a,2));          
        end

        M2(1,1)=sum(R.*R);
        M2(1,2)=sum(R.*G);
        M2(1,3)=sum(R.*B);
        M2(2,2)=sum(G.*G);
        M2(2,3)=sum(G.*B);
        M2(3,3)=sum(B.*B);
        M2(2,1)=M2(1,2);
        M2(3,1)=M2(1,3);
        M2(3,2)=M2(2,3);
        
        M=M+M2/(size(a,1)*size(a,2));                
    end
    M=M/image_counter;                
    [U,S,V] = svd(M);
    Mboost=U*(diag(1./diag(sqrt(S)))*V');    
elseif (isfloat(image))         % image is a single color image
    a=image;
    
    if(order==0)
        R=reshape(a(:,:,1),1,size(a,1)*size(a,2));
        G=reshape(a(:,:,2),1,size(a,1)*size(a,2));
        B=reshape(a(:,:,3),1,size(a,1)*size(a,2));
    else
        R=reshape([  gDer(a(:,:,1),sigma,1,0), gDer(a(:,:,1),sigma,0,1)],1,2*size(a,1)*size(a,2));
        G=reshape([  gDer(a(:,:,2),sigma,1,0), gDer(a(:,:,2),sigma,0,1)],1,2*size(a,1)*size(a,2));
        B=reshape([  gDer(a(:,:,3),sigma,1,0), gDer(a(:,:,3),sigma,0,1)],1,2*size(a,1)*size(a,2));            
    end    

    M(1,1)=sum(R.*R);
    M(1,2)=sum(R.*G);
    M(1,3)=sum(R.*B);
    M(2,2)=sum(G.*G);
    M(2,3)=sum(G.*B);
    M(3,3)=sum(B.*B);
    M(2,1)=M(1,2);
    M(3,1)=M(1,3);
    M(3,2)=M(2,3);
    
    M=M/(size(a,1)*size(a,2));
    
    [U,S,V] = svd(M);
    Mboost=U*(diag(1./diag(sqrt(S)))*V');    
else
    fprintf(1,'Input should be double or char !!\n');
    Mboost=[];
end
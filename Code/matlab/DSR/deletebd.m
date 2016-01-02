%% Delete the artificial frame surrounding the input image.

clear all;
% imgRoot='./Image4000/';
outdir='./outimage/';
mkdir(outdir);
imnames=dir([imgRoot '*' 'jpg']);

for ii=1:length(imnames)
    imname=[imgRoot imnames(ii).name]; 
    input_im=imread(imname);
    [m,n,z]=size(input_im);
    pbname=['./pbImg/'  imnames(ii).name(1:end-4) 'pb.mat'];
    load(pbname);
    k=1;
    count=1;
    while 1
        pbv(1)=mean(pb(k,:));
        pbv(2)=mean(pb(m-k+1,:));
        pbv(3)=mean(pb(:,k));
        pbv(4)=mean(pb(:,n-k+1));
        if k>30
            break;
        else
            if pbv(1)>0.3||pbv(2)>0.3||pbv(3)>0.3||pbv(4)>0.3
                b(count)=k;
                count=count+1;
            end
            k=k+1;
        end
    end

    if count>1
        k=b(count-1);
        outimage=input_im(k:m-k+1,k:n-k+1,:);
    else
        outimage=input_im;
    end
    
	outname1=[outdir imnames(ii).name];
	imwrite(uint8(outimage),outname1);
end
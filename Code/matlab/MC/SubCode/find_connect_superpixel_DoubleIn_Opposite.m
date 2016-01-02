function  [ ConPix0, ConPixSecond ] = find_connect_superpixel_DoubleIn_Opposite(labels, K, height ,width )
%%
% obtain the neighbour relationship of the super-pixels
% Input: 
%         labels:    the super-pixel label obtained from SLIC
%         K:         the number of super-pixels
%         height:    the height of the image
%         width:     the width of the image
% Output:
%         ConPix0:   the one layer neighbour relationship
%         ConPixSecond:  the two layer neighbour relationship
%%%%=====================================================
ConPix=zeros(K,K);
%the one outerboundary super
for i=1:height-1
    for j=1:width-1
        if labels(i,j)~=labels(i,j+1)
            ConPix(labels(i,j)+1 ,labels(i,j+1)+1 )=1;
        end
        if labels(i,j)~=labels(i+1,j)
            ConPix(labels(i,j)+1 ,labels(i+1,j)+1 )=1;
        end
    end
    if labels(i,j+1)~=labels(i+1,j+1)
        ConPix(labels(i,j+1)+1 ,labels(i+1,j+1 )+1 )=1;
    end
end
for j=1:width-1
    if labels(height,j)~=labels(height,j+1)
        ConPix( labels(height,j)+1,labels(height,j+1)+1 )=1;
    end
end
for i=1:height-1
    for j=1:width-1
        if labels(i,j)~=labels(i+1,j+1)
            ConPix( labels(i,j)+1,labels(i+1,j+1)+1 )=1;
        end
    end
end
for i=1:height-1
    for j=2:width
        if labels(i,j)~=labels(i+1,j-1)
            ConPix( labels(i,j)+1,labels(i+1,j-1)+1 )=1; 
        end
    end
end
 ConPix0 = ConPix + ConPix';
% connect the super-pixel on the opposite boundary
for j=1:width 
    ConPix( labels(1,j)+1 , labels(height,j)+1 ) = 1;
end
for j=1:height
    ConPix( labels(j,1)+1 , labels(j,width)+1 ) = 1 ;
end
ConPix=ConPix+ConPix';
% find the second outerboundary superpixel
 ConPixSecond = ConPix; 
for i=1:K
    siteline=find( ConPix(i,:)>0 );
    lenthsiteline=length(siteline); 
    for j=1:lenthsiteline
        ConPixSecond(i,:)= ConPixSecond(i,:)+ ConPix( siteline( j ), :);
    end
end
     % find third outerboundary superpixel
%      ConPixTid = ConPixSecond;
%      for i=1:K
%          siteline=find( ConPixSecond(i,:)>0 );
%          lenthsiteline=length(siteline);
%          for j=1:lenthsiteline
%              ConPixTid(i,:)= ConPixTid(i,:)+ ConPix( siteline( j ), :);
%          end
%      end
     



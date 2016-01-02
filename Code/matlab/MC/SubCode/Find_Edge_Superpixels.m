function   EdgSup = Find_Edge_Superpixels( Labels, K,  height, width , Wcon, ConPix )
%%
% obtain the indication of edge super-pixels
% Input:
%          Labels:   the super-pixel label obtained from SLIC
%          K:        the number of super-pixels
%          height:   the height of the image
%          width:    the width of the image
%          Wcon:     the affinity weight on the edge of the graph
%          ConPix:   one layer neighbour relationship of super-pixels
% Output: 
%          EdgSup:   the edge superpixel is indicated by value 1,
%                    the superpixel in the edge frame is indicated by value 2.
%%%%====================================================================
EdgSup=zeros( K,1);   Check=0;  
for i=1:height
    EdgSup ( Labels( i,1 )+1 ) =1;
    EdgSup ( Labels(i, width) +1 )=1;
end
for i=1:width
    EdgSup (Labels(1,i) +1 )= 1 ;
    EdgSup (Labels(height, i) +1 ) =1;
end
EdgSupSecond = EdgSup;
for j=1:K
    if EdgSup(j)==1        
        for z=1:K
            if ( ConPix(j,z)>0 ) && ( EdgSup(z)==0 )
                Check = Check + Wcon(j,z);
                EdgSupSecond( z ) = 1;                
            end
        end
        if Check > 13          % heuristic threshold to discard the frame
            return;
        end
    end
end
EdgSup =  EdgSup + EdgSupSecond;




function [ Salpix ] = GetMC(imname)    
    Img = double( imread( imname ) );
    [ height,width ] = size(Img(:,:,1));
    PixNum = height*width;    
    ImgVecR = reshape( Img(:,:,1)', PixNum, 1);
    ImgVecG = reshape( Img(:,:,2)', PixNum, 1);
    ImgVecB = reshape( Img(:,:,3)', PixNum, 1);
    % m is the compactness parameter, k is the super-pixel number in SLIC algorithm
    m = 20;      k = 250;  
    ImgAttr=[ height ,width, k, m, PixNum ];
    % obtain superpixel from SLIC algorithm: LabelLine is the super-pixel label vector of the image,
    % Sup1, Sup2, Sup3 are the mean L a b colour value of each superpixel,
    %  k is the number of the super-pixel.
    [ LabelLine, Sup1, Sup2, Sup3, k ] = SLIC( ImgVecR, ImgVecG, ImgVecB, ImgAttr );
    Label=reshape(LabelLine,width,height);
    Label = Label';     % the superpixle label
    
    [ ConPix, ConPixDouble ] = find_connect_superpixel_DoubleIn_Opposite( Label, k, height ,width );
    % count the number of the edge in the graph 
    NumInit=0;
    for j=1:k
        for z=j+1:k
            if ConPixDouble(j,z)>0
                NumInit=NumInit+1;
            end
        end
    end
    Dcol=zeros(NumInit,3);
    % calculate the edge weight
    mm=1;
    for j=1:k-1
        for z=j+1:k
            if ConPixDouble(j,z)>0
                DcolTem = sqrt( ( Sup1(j)-Sup1(z) ).^2 + ( Sup2(j)-Sup2(z) ).^2 + ( Sup3(j)- Sup3(z) ).^2 );
                Dcol(mm, 1: 3 )=[j,z,DcolTem ];
                mm=mm+1;
            end
        end
    end
    
    DcolNor = normalize( Dcol(:,3) );
    weight = exp( -10*DcolNor ) + .00001;
    WconFirst = sparse( [Dcol(:,1);Dcol(:,2)], [Dcol(:,2);Dcol(:,1)], [weight,weight],k ,k );
    WconFirst = full(WconFirst )  + eye(k);   % the affinity matrix of the graph model
    
    Discard = sum(WconFirst,2);
    DiscardPos = find( Discard < 1.1 );    % to discard the outlier
    LenDiscardPos = length(DiscardPos);
    
    EdgSup = Find_Edge_Superpixels( Label, k,  height, width , WconFirst, ConPix );    
    for j=1:LenDiscardPos
        EdgSup( DiscardPos(j) ) = 2;
    end
    
    NumIn = k - length( find( EdgSup == 2 ) );    
    NumEdg = length( find( EdgSup==1 ) );
    EdgWcon = zeros( k, NumEdg );
    mm=1;
    for j=1:k
        if EdgSup(j)==1
            EdgWcon(:,mm) = WconFirst(:,j);
            mm = mm + 1;
        end
    end
    alph = 1;  W=zeros(k,k);
    %%%%%%%%%%%% absorb MC
    if NumIn == k
        BaseEdg = sum( EdgWcon, 2 ) ;
        D = diag( Discard + BaseEdg );
        Wcon =  D \ WconFirst;
        I = eye( NumIn );
        N = ( I - alph* Wcon  );
        y = ones( NumIn, 1 );
        Sal = N \ y;
        Sal = normalize(Sal);
    else
        BaseEdg = zeros( NumIn, 1 );
        sumD = zeros( NumIn, 1 );
        mm=1;
        for j = 1:k
            if EdgSup(j) < 2
                BaseEdg(mm) = sum( EdgWcon( j, : ) );
                sumD(mm) = Discard(j);
                W(mm,:) = WconFirst(j,:);
                mm = mm + 1;
            end
        end
        mm=1;
        for j=1:k
            if EdgSup(j) < 2
                W( :,mm)=W(:,j);
                mm=mm+1;
            end
        end
        Wmid = W( 1:NumIn, 1: NumIn );
        D = diag( BaseEdg + sumD );
        Wmid = D \ Wmid;
        I = eye( NumIn );
        N = ( I - alph* Wmid  );
        y = ones( NumIn, 1 );
        Sal = N \ y;
        Sal = normalize(Sal);
    end
    %%%%%%%%%%%  entropy decide 2
    Entro = zeros( 11, 1 );
    for j = 1 : NumIn
        entroT =  floor( Sal(j) * 10 ) + 1;
        Entro( entroT ) = Entro( entroT ) + 1;
    end
    Entro(10) = Entro(10) + Entro(11);
    Entro = Entro ./ NumIn;
    Entropy = 0;
    for  j = 1 : 10
        Entropy = Entropy + Entro(j) * min( ( j ), ( 11 - j ) );
    end
    % output the saliency map directly from absorb MC
    if   Entropy < 2
        if NumIn < k
            SalAll = zeros(k,1);
            mm=1;
            for j= 1: k
                if EdgSup (j ) < 2
                    SalAll(j) = Sal( mm );
                    mm=mm+1;
                end
            end
            for j=1:LenDiscardPos
                for z=1:k
                    if ConPix( DiscardPos(j), z ) > 0
                        if SalAll(z) >.3
                            SalAll( DiscardPos(j) ) = 1 ;
                            break;
                        end
                    end
                end
            end
            SalLine = sup2pixel( PixNum, LabelLine, SalAll );  % to convey the saliency value from superpixel to pixel
            Salpix = reshape( SalLine, width, height );
            Salpix = Salpix';
        else
            SalLine = sup2pixel( PixNum, LabelLine, Sal );
            Salpix = reshape( SalLine, width, height );
            Salpix = Salpix';
        end
        %imwrite( Salpix, [ Salmap, ImgEnum(i).name(1:end-4), '.png' ] );
    else
        %%%%%%%%%%%% equilibrium post-process
        if NumIn == k
            sumDiscard = sum( Discard );
            c = Discard ./ sumDiscard;
            rW = 1 ./ c;
            sumrW = sum(rW);
            rW = rW / sumrW;
            Sal = N \ rW;
            Sal = normalize(Sal);
        else
            sumsumD = sum( sumD );
            c = sumD ./ sumsumD;
            rW = 1 ./ c;
            sumrW = sum(rW);
            rW = rW / sumrW;
            Sal = N \ rW;
            Sal = normalize(Sal);
        end
        if NumIn < k
            SalAll = zeros(k,1);
            mm=1;
            for j= 1: k
                if EdgSup (j ) < 2
                    SalAll(j) = Sal( mm );
                    mm=mm+1;
                end
            end
            for j = 1:LenDiscardPos        % to descide the saliency of outlier based on neighbour's saliency
                for z=1:k
                    if ConPix( DiscardPos(j), z ) > 0
                        if SalAll(z) >.3
                            SalAll( DiscardPos(j) ) = 1 ;
                            break;
                        end
                    end
                end
            end
            SalLine = sup2pixel( PixNum, LabelLine, SalAll );
            Salpix = reshape( SalLine, width, height );
            Salpix = Salpix';
        else
            SalLine = sup2pixel( PixNum, LabelLine, Sal );
            Salpix = reshape( SalLine, width, height );
            Salpix = Salpix';
        end
        %imwrite( Salpix, [ Salmap,ImgEnum(i).name(1:end-4), '.png' ] );
    end

end


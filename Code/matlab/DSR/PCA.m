function Base = PCA( Data , Dimensions , Rate )
%% Calculate the PCA bases.

%% Input
%%	Data 			:   samples
%%  Dimensions		:	retaining dimension, which is valid when Rate = 0 
%%	Rate	   		:	energy retaining rate

%% Output
%%	Base			: 	PCA bases, eigenvectors;
	
[ N_sample, Number ] = size( Data );              

Mean = zeros( N_sample ,1 );
for Num = 1 : Number
    Mean = Mean + Data( : , Num );                  
end
Mean = Mean / Number;                               

COVM = zeros( Number , Number );                    
for i = 1 : Number
    Data( : , i ) = Data( : , i ) - Mean;          
end
COVM = ( Data' * Data ) / Number;              

[ pc , latent , explained ] = pcacov( COVM );		

if Rate ~= 0
   sum = 0;
   i = 1;
   while(1)
        if sum >= Rate 
           break;
        else
           sum = sum + explained(i);            
           i = i + 1;
        end
   end
   Dimensions = i;
end                                                 							

TempW = zeros(Number,Dimensions);                         
for j = 1 : Dimensions
    TempW( : , j ) = pc( : , j );
end

Base = Data * TempW;                                        
for i = 1 : Dimensions
    Base( : , i ) = Base( : , i ) / norm( Base( : , i ) );  
end                                                         
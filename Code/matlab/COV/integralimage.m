% copyright MERL, Fatih Porikli, 2005

function X = integralimage(I)

[n,m,d] = size(I);
X = zeros(n,m,d);

for i=1:d
    X(1,1,i) = I(1,1,i);
    for y = 2 : n
        X(y,1,i) = X(y-1,1,i) + I(y,1,i);
    end;
    for x = 2 : m
        X(1,x,i) = X(1,x-1,i) + I(1,x,i);
    end;
end;

for i=1:d
    for y = 2 : n
        for x = 2 : m
            X(y,x,i) = X(y,x-1,i) + X(y-1,x,i) - X(y-1,x-1,i) + I(y,x,i);
        end;
    end;
end;
        

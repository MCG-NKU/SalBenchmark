% copyright MERL, Fatih Porikli, 2005

function [res] = covdist(A, B)

[n,m] = size(A);

e = eig(A,B);
e = real(e);
res = 0;
for i=1:n
    if (e(i) > 0.0000000000000000000001)
        v = log(e(i));
        res = res+v*v;
    end;
end;
res = sqrt(res);


% e = eig(inv(A)*B);
% e = real (e);
% res = 0;
% for i=1:n
%     if (e(i) > 0.0000000000000000000001)
%         res = res+log(e(i))*log(e(i));
%     end;
% end;
% res = sqrt(res);

% 
% siA = sqrtm(inv(A));
% lM = logm(siA*B*siA);
% res = trace(lM*lM);

function zctr_csf = generate_csf(zctr, s, mode)
% returns the value of the csf at a specific relative contrast and spatial frequency.
%
% outputs:
%   zctr_csf: matrix of csf_values
%
% inputs:
%   zctr: matrix of relative contrast values
%   s: matrix of spatial frequency values
%   mode: type of channel i.e. colour or intensity

% select for mode of channel:
if strcmp(mode,'intensity')
    params.sigma1 = 1.021035;
    params.sigma2 = 1.048155;
    params.sigma3 = 0.212226;
    params.beta   = 4.981624;
    params.s_k_0  = 4.530974;
    params.s_g_0  = 4;
else
    params.sigma1 = 1.360638;
    params.sigma2 = 0.796124;
    params.sigma3 = 0.348766;
    params.beta   = 3.611746;
    params.s_k_0  = 5.059210;
    params.s_g_0  = 4.724440;
end
zctr_csf = apply_csf(s,zctr,params);

end

function zctr_csf = apply_csf(s,zctr,params)
% Equation of csf based on Otazu et al, 2010

sigma1 = params.sigma1;
sigma2 = params.sigma2;
sigma3 = params.sigma3;
beta   = params.beta;
s_g_0  = params.s_g_0;
s_k_0  = params.s_k_0;

fCsfMax = CSF(s - s_g_0, beta, beta, sigma1, sigma2, 0);
fCsfMin = CSF(s - s_k_0, 1, 0, sigma3, sigma3, 1);

zctr_csf = zctr.*fCsfMax + fCsfMin;

end

function fCsf = CSF(s, amplitude1, amplitude2, sigma1, sigma2, contrast_min)
% Equation of csf based on Otazu et al, 2010

fCsf(s <= 0) = amplitude1.*exp(-(s(s <= 0).*s(s <= 0))./(2.*sigma1*sigma1));
fCsf(s > 0)  = amplitude2.*exp(-(s(s > 0).*s(s > 0))./(2.*sigma2*sigma2)) + contrast_min;
fCsf         = reshape(fCsf,size(s));

end

function [z,p] = geweke(beta)
% Syntax:
%
% [z,p] = nb_mcmc.geweke(beta)
%
% Description:
%
% Test for convergence of a M-H chain.
%
% Geweke (1992) test. This test split sample into two parts. The first 
% 10% and the last 50%. If the chain is at stationarity, the means of two 
% samples should be equal. The null hypothesis is that the subsamples has 
% the same mean.
% 
% Input:
% 
% - beta : A draws x numVar double.
% 
% Output:
% 
% - z  : A 1 x numVar double with the difference in mean statistics.
%
% - p  : A 1 x numVar double with the p-values of the test statistics.
%
% See also:
% nb_mcmc.mhSampler
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [n,q]  = size(beta);
    n1     = round(0.1*n);
    s2     = round(0.5*n);
    n2     = n - s2 + 1;
    split1 = beta(1:n1,:);     
    split2 = beta(s2:end,:);
    mean1  = mean(split1,1);              
    mean2  = mean(split2,1) ; 
    var1   = mean1;
    var2   = mean2;
    for ii = 1:q
        var1(ii) = nb_zeroSpectrumEstimation(split1(:,ii),'bartlett',[],'nw');
        var2(ii) = nb_zeroSpectrumEstimation(split2(:,ii),'bartlett',[],'nw');
    end
    z = (mean1 - mean2)./sqrt( var1./n1 + var2./n2 );
    p = 2*(1 - nb_distribution.normal_cdf(abs(z),0,1));
    
end

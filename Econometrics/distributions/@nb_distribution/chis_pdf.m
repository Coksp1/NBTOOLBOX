function f = chis_pdf(x,m)
% Syntax:
%
% f = nb_distribution.chis_pdf(x,m)
%
% Description:
%
% PDF of the chi squared distribution
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
%
% - m : A parameter such that the mean is m
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.chis_cdf, nb_distribution.chis_rand, 
% nb_distribution.chis_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    f = nb_distribution.gamma_pdf(x,m*0.5,2);
     
end

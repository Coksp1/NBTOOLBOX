function f = logistic_pdf(x,m,k)
% Syntax:
%
% f = nb_distribution.logistic_pdf(x,m,k)
%
% Description:
%
% PDF of the logistic distribution
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
%
% - m : The location paramter. Mode = m. Must be a number.
%
% - k : Scale paramter. Must be a positive number.
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.logistic_cdf, nb_distribution.logistic_rand, 
% nb_distribution.logistic_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    f1 = exp((x - m)./k);
    f2 = k.*(1 + f1).^2;
    f  = f1./f2; 
    
end

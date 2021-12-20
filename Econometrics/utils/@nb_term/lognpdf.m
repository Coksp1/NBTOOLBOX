function obj = lognpdf(obj,m,k)
% Syntax:
%
% obj = lognpdf(obj,m,k)
%
% Description:
%
% Log-normal pdf.
% 
% Input:
% 
% - obj : A vector of nb_term objects.
%
% - m   : The mean of the distribution, as an object of class nb_term.
%
% - k   : The std of the distribution, as an object of class nb_term.
%
% Output:
% 
% - obj : A vector of nb_term objects.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin == 1
        obj = generalFunc(obj,'lognpdf');
    elseif nargin == 2
        obj = generalFunc(obj,'lognpdf',m);
    else
        obj = generalFunc(obj,'lognpdf',m,k);
    end
    
end

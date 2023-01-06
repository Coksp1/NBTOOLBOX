function obj = normcdf(obj,m,k)
% Syntax:
%
% obj = normcdf(obj,m,k)
%
% Description:
%
% Normal cdf.
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin == 1
        obj = generalFunc(obj,'normcdf');
    elseif nargin == 2
        obj = generalFunc(obj,'normcdf',m);
    else
        obj = generalFunc(obj,'normcdf',m,k);
    end
    
end

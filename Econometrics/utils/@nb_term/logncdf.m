function obj = logncdf(obj,m,k)
% Syntax:
%
% obj = logncdf(obj,m,k)
%
% Description:
%
% Log-normal cdf.
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
        obj = generalFunc(obj,'logncdf');
    elseif nargin == 2
        obj = generalFunc(obj,'logncdf',m);
    else
        obj = generalFunc(obj,'logncdf',m,k);
    end
    
end

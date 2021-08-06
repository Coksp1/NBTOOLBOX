function obj = mpower(obj,another)
% Syntax:
%
% obj = mpower(obj,another)
%
% Description:
%
% Power operator (*) for nb_term objects.
% 
% Input:
% 
% Two cases:
%
% One input:
%
% - obj     : A vector of nb_term objects.
%
% Two inputs:
% 
% - obj     : A scalar nb_term object. 
%
% - another : A vector of nb_term objects.
%
% Output:
% 
% - obj     : A scalar nb_term object.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if nargin == 1
        obj = power(obj);
    else
        obj = power(obj,another);
    end
    
end

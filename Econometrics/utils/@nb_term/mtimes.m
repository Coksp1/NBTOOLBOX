function obj = mtimes(obj,another)
% Syntax:
%
% obj = mtimes(obj,another)
%
% Description:
%
% Times operator (*) for nb_term objects.
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
        obj = times(obj);
    else
        obj = times(obj,another);
    end
    
end

function obj = mrdivide(obj,another)
% Syntax:
%
% obj = mrdivide(obj,another)
%
% Description:
%
% Division operator (/) for nb_term objects.
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
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin == 1
        obj = rdivide(obj);
    else
        obj = rdivide(obj,another);
    end
    
end

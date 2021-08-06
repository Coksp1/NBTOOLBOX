function [out,IA,IC] = unique(in)
% Syntax:
%
% obj = unique(obj)
%
% Description:
%
% Get unique elements of a vector of nb_date objects.
% 
% Input:
% 
% - in  : A vector of nb_date objects.
% 
% Output:
% 
% - out : A unique (sorted) vector of nb_date objects.
%
% - IA  : out = in(IA)
%
% - IC  : A = C(IC)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nr        = getNr(in);
    [~,IA,IC] = unique(nr);
    out       = in(IA);
    
end
    

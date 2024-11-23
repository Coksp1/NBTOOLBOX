function [uniq,ind] = unique(obj)
% Syntax:
%
% uniq = unique(obj,another)
%
% Description:
%
% Locate the unique nb_term objects in a vector of nb_term objects.
% 
% Input:
% 
% - obj  : A vector of nb_term objects.
%
% Output:
% 
% - uniq : The unique nb_term objects.
%
% - ind  : Vector such that uniq = obj(ind).
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [~,ind] = unique(cellstr(obj));
    uniq    = obj(ind);
    
end

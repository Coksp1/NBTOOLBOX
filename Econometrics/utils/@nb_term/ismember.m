function [ind,loc] = ismember(obj,another)
% Syntax:
%
% [ind,loc] = ismember(obj,another)
%
% Description:
%
% Check if the terms in obj is member of the terms in another.
% 
% Input:
% 
% - obj     : A vector of nb_term objects.
%
% - another : A vector of nb_term objects.
%
% Output:
% 
% - ind     : A logical vector with same size as obj. Elements that are
%             true are found to be in the another input.
%
% - loc     : A double vector with same size as obj. Locations of the
%             elements that are found in the another input. If not found
%             0 is returned.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [ind,loc] = ismember(cellstr(obj),cellstr(another));
    
end

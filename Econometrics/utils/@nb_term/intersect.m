function int = intersect(obj,another)
% Syntax:
%
% int = intersect(obj,another)
%
% Description:
%
% Get the intersect of two vectors of nb_term objects.
% 
% Input:
% 
% - obj     : A vector of nb_term objects.
%
% - another : A vector of nb_term objects.
%
% Output:
% 
% - int     : The intersect, as a vector of nb_term objects.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    [~,ind] = intersect(cellstr(obj),cellstr(another));
    int     = obj(ind);
    
end

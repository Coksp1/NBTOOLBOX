function uni = union(obj,another)
% Syntax:
%
% uni = union(obj,another)
%
% Description:
%
% Get the union of two vectors of nb_term objects.
% 
% Input:
% 
% - obj     : A vector of nb_term objects.
%
% - another : A vector of nb_term objects.
%
% Output:
% 
% - uni     : The union, as a vector of nb_term objects.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [~,ind] = union(cellstr(obj),cellstr(another));
    uni     = obj(ind);
    
end

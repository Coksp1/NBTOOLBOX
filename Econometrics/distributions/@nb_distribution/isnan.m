function ret = isnan(obj)
% Syntax:
%
% ret = isnan(obj)
%
% Description:
%
% Test if the elements of a N x M x P nb_distribution object is 
% of type 'constant(NaN)', i.e. is NaN.
% 
% Input:
% 
% - obj : A N x M x P nb_distribution object.
% 
% Output:
% 
% - ret : A N x M x P logical. 
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    names = reshape({obj.name},size(obj));
    ret   = cellfun(@(x)strcmpi(x,'constant(NaN)'),names);

end

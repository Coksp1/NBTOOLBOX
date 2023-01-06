function d = nb_breakAdj(d,method,indexes)
% Syntax:
%
% obj = breakAdj(obj,method,varargin)
%
% Description:
%
% The intent of this function is to set observations around break points to
% nan, and interpolate the observation at these break-points.
%
% Input:
% 
% - d       : An double with size T x N x P. Interpolation is done along 
%             the first dimension.
% 
% - method  : The wanted interpolation method to use. See the 
%             nb_interpolate function.
%   
% - indexes : A vector of integers or a logical array of length T for 
%             where to set the rows of d to nan.
%
% Output:
% 
% - d       : An double with size T x N x P.
%
% See also:
% nb_interpolate
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    d(indexes,:,:) = nan;
    d              = nb_interpolate(d,method);

end

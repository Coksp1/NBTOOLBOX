function obj = horzcat(a,varargin)
% Syntax:
%
% obj = horzcat(a,b,varargin)
%
% Description:
%
% Horizontal concatenation of nb_cell objects. ([a,b])
% 
% Input:
%
% - a        : An object of class nb_cell
%
% - varargin : Optional number of nb_cell objects
% 
% Output:
%
% - obj      : An nb_cell object with all the variables from the 
%              different nb_cell object merge into one dataset 
% 
% Examples:
%
% obj = [a,b];
% obj = [a,b,c];
%
% See also:
% merge
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    for ii = 1:size(varargin,2)
        a = merge(a,varargin{ii},'horzcat');
    end
    obj = a;

end

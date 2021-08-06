function obj = deptcat(obj,varargin)
% Syntax:
%
% obj = deptcat(obj,varargin)
%
% Description:
%
% Depth concatenation (add pages of different objects) (No short 
% notation)
%
% Be aware: The sizes of the cell matrices will be expanded automaically to
%           match eachother.
% 
% Input:
%
% - obj       : An object of class nb_cell
% 
% - varargin  : Optional number of nb_cell objects
% 
% Output:
%
% - obj       : An object of class nb_cell where all the objects 
%               datasets are added into.     
% 
% See also:
% addPages
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj = addPages(obj,varargin{:});

end

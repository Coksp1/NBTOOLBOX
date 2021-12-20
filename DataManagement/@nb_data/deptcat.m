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
% Be aware: If the added datsets does not contain the same
% variables or obs, the data of the nb_data object with the
% tightest window will be expanded automatically to include
% all the same dates and variables. (the added data will be 
% set as nan)
% 
% Input:
%
% - obj       : An object of class nb_data
% 
% - varargin  : Optional number of nb_data objects
% 
% Output:
%
% - obj       : An object of class nb_ts where all the objects 
%               datasets are added into.     
% 
% Examples:
%
% obj = obj.deptcat(DB);
% obj = obj.deptcat(DB,DB2,DB3);
%
% See also:
% addPages
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj = addPages(obj,varargin{:});

end

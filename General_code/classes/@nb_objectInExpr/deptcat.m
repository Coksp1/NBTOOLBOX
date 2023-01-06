function obj = deptcat(a,b,varargin)
% Syntax:
%
% obj = deptcat(a,b,varargin)
%
% Description:
%
% Depth concatenation (add pages of different nb_objectInExpr objects) 
% (No short hand notation)
% 
% Input:
%
% - a        : An object of class nb_objectInExpr
%
% - b        : An object of class nb_objectInExpr
%
% - varargin : Optional number of nb_objectInExpr objects
% 
% Output:
% 
% obj        : An object of class nb_objectInExpr.
%
% Examples:
%
% obj = deptcat(a,b);
% obj = deptcat(a,b,c);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj = compare(a,b);
    
    % Concatenate the rest
    if ~isempty(varargin) 
        obj = deptcat(obj,varargin{ii});
    end

end

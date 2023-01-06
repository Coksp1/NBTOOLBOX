function obj = horzcat(a,b,varargin)
% Syntax:
%
% obj = horzcat(a,b,varargin)
%
% Description:
%
% Horizontal concatenation ([a,b])
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
% obj        : An object of class nb_objectInExpr
% 
% Examples:
%
% obj = [a,b];
% obj = [a,b,c];
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj = compare(a,b);
    
    % Concatenate the rest
    if ~isempty(varargin)
        obj = horzcat(obj,varargin{:});
    end

end

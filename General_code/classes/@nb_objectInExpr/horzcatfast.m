function obj = horzcatfast(varargin)
% Syntax:
%
% obj = horzcatfast(varargin)
%
% Description:
%
% Horizontal concatenation
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
% See also
% nb_objectInExpr.horzcat
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj = compare(a,b);
    
    % Concatenate the rest
    if ~isempty(varargin)
        obj = horzcat(obj,varargin{:});
    end

end

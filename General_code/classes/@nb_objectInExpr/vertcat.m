function a = vertcat(a,b,varargin)
% Syntax:
%
% obj = vertcat(a,b,varargin)
%
% Description:
% 
% Vertical concatenation ([a;b])
% 
% Input:
% 
% - a         : An object of class nb_objectInExpr
% 
% - b         : An object of class nb_objectInExpr
% 
% - varargin  : Optional numbers of objects of class nb_objectInExpr
% 
% Output:
% 
% - a         : An nb_objectInExpr object
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    a = compare(a,b);
    
    % Concatenate the rest
    if ~isempty(varargin)
        a = vertcat(a,varargin{:});
    end

end

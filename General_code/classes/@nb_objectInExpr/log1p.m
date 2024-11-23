function obj = log1p(obj)
% Syntax:
%
% obj = log1p(obj)
%
% Description:
%
% log1p(obj) computes LOG(1+xi), where xi are the elements of obj.
% Complex results are produced if xi < -1.
%  
% For small real xi, log1p(xi) should be approximately xi, whereas the
% computed value of LOG(1+xi) can be zero or have high relative error.
% 
% Input:
% 
% - obj : An object of class nb_objectInExpr
% 
% Output: 
% 
% - obj : An object of class nb_objectInExpr
% 
% Examples:
%
% out = log1p(in);
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

end

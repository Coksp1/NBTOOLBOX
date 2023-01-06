function obj = expm1(obj)
% Syntax:
%
% obj = expm1(obj)
%
% Description:
%
% expm1(obj) computes exp(obj)-1, compensating for the roundoff in
% exp(obj).
% (For small real X, expm1(X) should be approximately X, whereas the
% computed value of EXP(X)-1 can be zero or have high relative error.)
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
% obj = expm1(obj);
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
  
end

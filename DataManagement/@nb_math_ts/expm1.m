function obj = expm1(obj)
% Syntax:
%
% obj = expm1(obj)
%
% Description:
%
% exp(obj) is the exponential of the elements of obj, e to the obj.
% expm1(obj) computes exp(obj)-1, compensating for the roundoff in
% exp(obj).
% (For small real X, expm1(X) should be approximately X, whereas the
% computed value of EXP(X)-1 can be zero or have high relative error.)
% 
% Input:
% 
% - obj           : An object of class nb_math_ts
% 
% Output:
% 
% - obj           : An object of class nb_math_ts where the data are 
%                   equal to e.^obj.data-1
% 
% Examples:
% 
% obj = expm1(obj);
%
% Written by Andreas Haga Raavand

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = expm1(obj.data);

    
end

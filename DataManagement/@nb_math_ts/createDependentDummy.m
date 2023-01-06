function obj = createDependentDummy(obj,condition,scalar)
% Syntax:
%
% obj = createVarDummy(obj,condition)
% obj = createVarDummy(obj,condition,scalar)
%
% Description:
%
% Creates a nb_math_ts object with dummy variables basted on the
% tested criterions.
% 
% Input:
% 
% - obj       : An object of class nb_math_ts with size nObs x nVars x 
%               nPages.
%
% - condition : Name of the added dummy variable.
%
%               - '<'  : Less than. 
% 
%               - '>'  : Greater than. 
%
%               - '<=' : Less than or equal to. 
%
%               - '>=' : Less than or equal to. 
%
%               - '==' : Equal to. 
%
%               - '~=' : Not equal to. 
%
% - scalar    : A scalar double. Default is 0.
% 
% Output:
% 
% - obj : An object of class nb_math_ts with size nObs x nVars x nPages.
%
% Examples:
%
% obj = nb_math_ts([1,2;-3,1;-1,3],'2012');
% obj = createDependentDummy(obj,'>',0);
%
% See also:
% createDependentDummy
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        scalar = 0;
    end
    obj.data = createDependentDummy(obj.data,condition,scalar);

end

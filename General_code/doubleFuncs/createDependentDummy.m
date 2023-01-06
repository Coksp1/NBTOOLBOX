function y = createDependentDummy(y,condition,scalar)
% Syntax:
%
% y = createVarDummy(y,condition)
% y = createVarDummy(y,condition,scalar)
%
% Description:
%
% Create dummy series based on time-series stored as double.
% 
% Input:
% 
% - obj       : An double with size nObs x nVars x nPages.
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
% - obj       : An double with size nObs x nVars x nPages.
%
% Examples:
%
% y = [1,2;-3,1;-1,3];
% y = createDependentDummy(y,'>',0);
%
% See also:
% nb_math_ts.createDependentDummy
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        scalar = 0;
    end
    if ~nb_isOneLineChar(condition)
        error('The condition input must be a one line char.')
    end
    if ~nb_isScalarNumber(scalar)
        error('The scalar input must be a scalar number.')
    end
    switch condition
        case {'<','lt'}
            func = @lt; 
        case {'>','gt'}
            func = @gt; 
        case {'<=','le'}
            func = @ge; 
        case {'>=','ge'}
            func = @le; 
        case {'==','eq'}
            func = @eq; 
        case {'~=','ne'}
            func = @ne; 
        otherwise
            error([mfilename ':: Unsupported logical operator ' condition '.'])
    end
    y = func(y,scalar);

end

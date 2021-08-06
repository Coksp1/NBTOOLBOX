function out = nb_eval(expression,variables,data,macro)
% Syntax:
%
% out = nb_eval(expression,variables,data)
% out = nb_eval(expression,variables,data,macro)
%
% Description:
%
% Evaluate a expression as a string. 
% 
% Input:
% 
% - expression : A string with the expression to evaluate. E.g.
%                'lag(exp(Var1/(Var2^1^3))*4,1)*Var4 + Var1*(exp(Var1/2))'
%
% - variables  : The variables of the dataset. As a cellstr with size
%                1 x nvars.
%
% - data       : The dataset. A double or a nb_math_ts object with the
%                data of the variables. Must have size nobs x nvars.
% 
% - macro      : Set to true to also handle the NB Toolbox macro processing
%                language as well. Default is false.
%
% Output:
% 
% - out        : The result of the evaluation of the string
%
% See also:
% nb_ts.createVariable, nb_cs.createVariable, nb_cs.createType,
% nb_data.createVariable, eval
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        macro = false;
    end
    
    % Check for unsupported chars and matching parentheses
    expr = expression;
    str  = nb_checkForErrors(expression,macro);
    if ~isempty(str)
        error([mfilename ':: Error while parsing expression:: ' str])
    end
    
    % Parse the input string
    [str,out,nInp] = nb_shuntingYardAlgorithm(expression,sort(variables),macro);
    if ~isempty(str)
        error([mfilename ':: Error while parsing expression:: ' expr ':: ' str])
    end
    
    % Get the type of the different elements
    [out,type] = nb_getTypes(out,variables,data,macro,nInp);
    
    % Evaluate the interpreted expression
    [out,str] = nb_evalExpression(out,type,nInp);
    if ~isempty(str)
        error([mfilename ':: Error while evaluating expression ' expr ':: ' str])
    end
    
end

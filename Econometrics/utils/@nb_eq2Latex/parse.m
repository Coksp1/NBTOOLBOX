function obj = parse(expr,varargin)
% Syntax:
%
% obj = nb_eq2Latex.parse(expr,varargin)
%
% Description:
%
% Parse mathematical expressions an turn them into a vector of nb_eq2Latex
% objects.
% 
% Input:
% 
% - expr      : A N x 1 cellstr with the mathematical expressions to parse.
% 
% Optional input:
%
% - 'latexVars'    : Use this input to translate the names of the 
%                    variables/parameters of the mathematical expression
%                    to latex names. In this case 'vars' must also be 
%                    given. Each element of the 'vars' input is translated
%                    into the corresponding element of this input. Must
%                    be a M x 1 cellstr.
%
% - 'precision'    : See help on the precision property. Default is 14.
%
% - 'vars'         : A M x 1 cellstr with the variables of the expression.  
%                    If not provided or empty, the variables will be   
%                    parsed at the cost of speed.
%
% Output:
% 
% - obj       : A N x 1 vector of nb_eq2Latex objects.
%
% See also:
% nb_eq2Latex.writePDF
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
    
    if ~iscellstr(expr) %#ok<ISCLSTR>
        error([mfilename ':: The expr input must be a cellstr.'])
    end
    inputs          = parseInputs(varargin);
    [exprFunc,vars] = expr2Func(expr(:),inputs.vars);
    if ~isempty(inputs.latexVars)
        vars = inputs.latexVars;
    end
    obj = nb_eq2Latex(vars,inputs.precision);
    obj = exprFunc(obj);

end

%==========================================================================
function inputs = parseInputs(optInputs)
    
    % Parse optional inputs
    default = {
       'latexVars',     {},      @iscellstr
       'precision',    	14,      {@nb_isScalarInteger,'||',@ischar}
       'vars',          {},      @iscellstr
    };
    [inputs,message] = nb_parseInputs(mfilename,default,optInputs{:});
    if ~isempty(message)
        error(message)
    end
    
    % Further tests
    if ~isempty(inputs.vars)
        inputs.vars = inputs.vars(:);
    end
    if ~isempty(inputs.latexVars)
        inputs.latexVars = inputs.latexVars(:);
        if isempty(inputs.vars)
            error([mfilename ':: If the input ''latexVars'' is given the ''vars'' ',...
                             'input cannot be empty.'])
        elseif size(inputs.vars,1) ~= size(inputs.latexVars,1)
            error([mfilename ':: The length of ''latexVars'' must match the length of ',...
                             'the ''vars'' input.'])
        end
    end
    
    
end

%==========================================================================
function [exprFunc,vars] = expr2Func(expr,vars)

    % Translate the equation into generic names
    nEqs    = size(expr,1);
    out     = cell(nEqs,1);
    matches = regexp(expr,'[A-Za-z_]{1}[A-Za-z_0-9]*(?!\()','match');
    
    % Parse out parameters if not provided
    if isempty(vars)
        vars = unique(nb_nestedCell2Cell(matches));
    end
    
    % Create the variables with lead and lag
    [~,varsNS,varsS] = nb_createGenericNames(vars,'vars');  
    
    % Subst. out in each equation
    for ii = 1:length(expr)

        matchesT = matches{ii};    
        indV     = ismember(varsS,matchesT);
        varsT    = strcat('(?<![A-Za-z_])',varsS(indV),'(?![A-Za-z_0-9])');
        varsNT   = varsNS(indV);
        out{ii}  = expr{ii};
        for vv = length(varsT):-1:1
            out{ii} = regexprep(out{ii},varsT{vv},varsNT{vv});
        end
        
    end
       
    % Create function handle
    exprFunc = nb_cell2func(out,'(vars)');

end

function [eqs,eqFunc] = eqs2funcSub(parser,eqs,type)
% Syntax:
% 
% [eqs,eqFunc] = nb_dsge.eqs2funcSub(parser,eqs)
% [eqs,eqFunc] = nb_dsge.eqs2funcSub(parser,eqs,type)
%
% Description:
%
% Convert equation of the model to a function handle. Subroutine. 
%
% Static private method.
% 
% Input:
%
% - parser : See the parser property of the nb_dsge class.
%
% - eqs    : A nEq x 1 cellstr array with the equations of the model.
%
% - type   : Give 1 to indicate that you want the static representation
%            of the model, give 2 to get the function handle of the
%            observation model, otherwise you will get a function handle 
%            of the core model.
%
% See also:
% nb_dsge.parse, nb_dsge.addEquation, nb_dsge.solveSteadyStateStatic
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 0;
    end

    if type == 2 % Observation model
        vars = nb_dsge.getObsOrderingNB(parser,[]);
        pars = parser.parameters;
    elseif type == 1 % Static
        
        if isfield(parser,'endogenousChanged')
            vars = parser.endogenousChanged(~parser.isAuxiliary);
        else
            vars = parser.endogenous(~parser.isAuxiliary);
        end
        varsExo = parser.exogenous;
        if isfield(parser,'parametersChanged')
            pars = parser.parametersChanged;
        else
            pars = parser.parameters;
        end 
        
        % Append endogenized parameters
        if ~isempty(parser.parametersStatic)
            vars       = [vars,parser.parametersStatic];
            parsRemove = ismember(pars,parser.parametersStatic);
            pars       = pars(~parsRemove);
        end
        
        % Get static equations
        eqs = nb_dsge.getStaticEquations(eqs,parser);
        
    else % Core model
        vars = nb_dsge.getOrderingNB(parser,[]);
        pars = parser.parameters;
    end
    all = [vars,pars];
    if any(ismember({'vars','pars'},all))
        error([mfilename ':: ''vars'' and ''pars'' cannot be used in variable or parameter names.'])
    end
    
    [vars,r] = sort(vars);
    nVars    = length(vars);
    num      = 1:nVars;
    numS     = strtrim(cellstr(int2str(num')));
    varsN    = strcat('vars(',numS ,')');
    varsN    = varsN(r);
    
    % Here we need to sort the parameters as well, as the
    % variables and parameters can be interchanged during solving
    % of the steady-state!
    [pars,r] = sort(pars);
    nParam   = length(pars);
    num      = 1:nParam;
    numS     = strtrim(cellstr(int2str(num')));
    paramN   = strcat('pars(',numS ,')');
    paramN   = paramN(r);
    
    if type == 1 % Static
        % Here we just add the exogenous variable as parameters
        % as this will make the static function only a function of
        % two inputs...
        [varsExo,r] = sort(varsExo);
        nVarsExo    = length(varsExo);
        num         = nParam + (1:nVarsExo);
        numS        = strtrim(cellstr(int2str(num')));
        varsExoN    = strcat('pars(',numS ,')');
        varsExoN    = varsExoN(r);
        
        % This are the variables subst in for the steady_state_init
        % expressions
        varsSSInit  = strcat(vars,'_SS_INIT');
        varsSSInitN = strcat('ss_init_',varsN);
        
    end
    
    if type == 1 % Static
        eqsTrans = nb_dsge.transLeadLagStatic(eqs);
        % Here we may add a way to remove uneccesary terms from the
        % static equation, i.e. + g(Var/Var) + ...
    else
        eqsTrans = nb_dsge.transLeadLag(eqs);
    end
    
    nEqs    = size(eqsTrans,1);
    out     = cell(nEqs,1);
    matches = regexp(eqsTrans,'[A-Za-z_]{1}[A-Za-z_0-9]*(?!\()','match');
    for ii = 1:length(eqsTrans)
    
        eq       = eqsTrans{ii};
        matchesT = matches{ii};
        ind      = ismember(pars,matchesT);
        paramT   = strcat('(?<![A-Za-z_])',pars(ind),'(?![A-Za-z_0-9])');
        paramNT  = paramN(ind);
        for pp = length(paramT):-1:1 
            eq = regexprep(eq,paramT{pp},paramNT{pp});
        end
        
        if type == 1 % Static
            
            indV   = ismember(varsExo,matchesT);
            varsT  = strcat('(?<![A-Za-z_])',varsExo(indV),'(?![A-Za-z_0-9])');
            varsNT = varsExoN(indV);
            for vv = length(varsT):-1:1
                eq = regexprep(eq,varsT{vv},varsNT{vv});
            end
            
            indV   = ismember(varsSSInit,matchesT);
            varsT  = strcat('(?<![A-Za-z_])',varsSSInit(indV),'(?![A-Za-z_0-9])');
            varsNT = varsSSInitN(indV);
            for vv = length(varsT):-1:1
                eq = regexprep(eq,varsT{vv},varsNT{vv});
            end
            
        end
        
        indV   = ismember(vars,matchesT);
        varsT  = strcat('(?<![A-Za-z_])',vars(indV),'(?![A-Za-z_0-9])');
        varsNT = varsN(indV);
        for vv = length(varsT):-1:1
            eq = regexprep(eq,varsT{vv},varsNT{vv});
        end
        out{ii} = eq;
        
    end
       
    % Create function handle
    out = strcat(out,';');
    out = [out{:}];
    if type == 1 % Static
        out = ['@(vars,pars,ss_init_vars)[', out(1:end-1) ,']'];
    else
        out = ['@(vars,pars)[', out(1:end-1) ,']'];
    end
    try
        eqFunc = str2func(out);
    catch Err
        % Loop through each equation separatly, and check which
        % equations that fails
        strFunc = nb_func2Cellstr(out);
        failed  = false(size(strFunc,1),1);
        for ii = 1:size(strFunc,1)
            try
                str2func(['@(vars,pars)', strFunc{ii}]);
            catch
                failed(ii) = true;
            end
        end
        if any(failed)
            failedEqs = eqs(failed);
            num       = 1:length(eqs);
            numStr    = strtrim(cellstr(int2str(num(failed)')));
            failedEqs = strcat(failedEqs, '; (nr. ', numStr, ')\n');
            err       = [mfilename ':: Could not parse the following equations: \n\n'];
            err       = [err,failedEqs{:}];
            error('nb_dsge:parsingFailed',err);
        else
            rethrow(Err);
        end
    end
    
end

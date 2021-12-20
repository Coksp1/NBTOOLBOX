function [eqs,funcs] = eqs2funcEpi(inputs,allEndo,epiVars,vars,varsExo,pars,eqs)
% Syntax:
%
% [eqs,funcs] = nb_perfectForesight.eqs2funcEpi(inputs,allEndo,epiVars,...
%                   vars,varsExo,pars,eqs)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    all = [epiVars,vars,pars];
    if any(ismember({'vars','pars'},all))
        error([mfilename ':: ''vars'' and ''pars'' cannot be used in variable or parameter names.'])
    end
    
    % The known variables when solving for the epilogue (lead and lag of 
    % the variables of the epilogue is added for simplicity)
    [varsN,varsNS,vars] = nb_createGenericNames(vars,'vars');
    
    % The variables of the epilogue that we want to solve for
    [epiVarsN,epiVarsNS,epiVars] = nb_createGenericNames(epiVars,'epivars');
    
    % We don't need to sort the parameters as they are already sorted.
    paramN = nb_createGenericNames(pars,'pars');
   
    % Here we just add the exogenous variable as parameters
    % as this will make the function handle only a function of
    % three inputs...
    nParam      = length(pars);
    [varsExo,r] = sort(varsExo);
    nVarsExo    = length(varsExo);
    num         = nParam + (1:nVarsExo);
    numS        = strtrim(cellstr(int2str(num')));
    varsExoN    = strcat('pars(',numS ,')');
    varsExoNS   = varsExoN(r);
    
    eqs     = nb_dsge.transLeadLag(eqs);
    eqs     = nb_perfectForesight.substituteSS(eqs,allEndo);
    nEqs    = size(eqs,1);
    out     = cell(nEqs,1);
    matches = regexp(eqs,'[A-Za-z_]{1}[A-Za-z_0-9]*(?!\()','match');
    for ii = 1:length(eqs)
    
        eq       = eqs{ii};
        matchesT = matches{ii};
        ind      = ismember(pars,matchesT);
        paramT   = strcat('(?<![A-Za-z_])',pars(ind),'(?![A-Za-z_0-9])');
        paramNT  = paramN(ind);
        for pp = length(paramT):-1:1 
            eq = regexprep(eq,paramT{pp},paramNT{pp});
        end
        
        indV   = ismember(varsExo,matchesT);
        varsT  = strcat('(?<![A-Za-z_])',varsExo(indV),'(?![A-Za-z_0-9])');
        varsNT = varsExoN(indV);
        for vv = length(varsT):-1:1
            eq = regexprep(eq,varsT{vv},varsNT{vv});
        end
        
        indV   = ismember(vars,matchesT);
        varsT  = strcat('(?<![A-Za-z_])',vars(indV),'(?![A-Za-z_0-9])');
        varsNT = varsNS(indV);
        for vv = length(varsT):-1:1
            eq = regexprep(eq,varsT{vv},varsNT{vv});
        end
        
        indV   = ismember(epiVars,matchesT);
        varsT  = strcat('(?<![A-Za-z_])',epiVars(indV),'(?![A-Za-z_0-9])');
        varsNT = epiVarsNS(indV);
        for vv = length(varsT):-1:1
            eq = regexprep(eq,varsT{vv},varsNT{vv});
        end
        out{ii} = eq;
        
    end
       
    % Create function handle
    F       = nb_cell2func(out,'(epivars,vars,pars,ssVars)');
    funcs.G = F;
    
    % Derive symbolic derivatives if that method is used.
    funcs.symbolic = false;
    if strcmpi(inputs.derivativeMethod,'symbolic')
        
        epiVarsD       = nb_mySD(epiVarsN);
        varsD          = nb_param(varsN);
        paramD         = nb_param([paramN;varsExoNS]);
        ssVarsD        = nb_param(nb_createGenericNames([epiVars,vars],'ssVars'));
        funcs.symbolic = true;
        symDeriv       = F(epiVarsD,varsD,paramD,ssVarsD);
        derivEqs       = [symDeriv.derivatives];
        funcs.GDeriv   = nb_cell2func(derivEqs,'(epivars,vars,pars,ssVars)');
        [I,J]          = nb_getSymbolicDerivIndex(symDeriv,'epivars',derivEqs);
        funcs.ind      = [I,J];
        
    end
    
    
end

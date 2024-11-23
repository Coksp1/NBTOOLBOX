function [stackedFirst,initN,varsN] = getStackedFirst(eqs,matches,pars,paramN,varsExo,varsExoN,varsCLead,initVal)
% Syntax:
%
% [stackedFirst,initN,varsN] = nb_perfectForesight.getStackedFirst(eqs,...
%               matches,pars,paramN,varsExo,varsExoN,varsCLead,initVal)
%
% Syntax:
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nEqs = size(eqs,1);
    
    % Get initial conditions for the state variables
    initVar = fieldnames(initVal);
    initVar = strcat(initVar,'_lag');
    initN   = nb_createGenericNames(initVar,'initVal');
    
    % Sub for endogenous (first period)
    [varsN,varsNS,varsCLead] = nb_createGenericNames(varsCLead,'vars');

    stackedFirst = cell(nEqs,1);
    for ii = 1:length(eqs)
    
        eq       = eqs{ii};
        matchesT = matches{ii};
        ind      = ismember(initVar,matchesT);
        initT    = strcat('(?<![A-Za-z_])',initVar(ind),'(?![A-Za-z_0-9])');
        initNT   = initN(ind);
        for pp = length(initT):-1:1
            eq = regexprep(eq,initT{pp},initNT{pp});
        end
        
        ind      = ismember(pars,matchesT);
        paramT   = strcat('(?<![A-Za-z_])',pars(ind),'(?![A-Za-z_0-9])');
        paramNT  = paramN(ind);
        for pp = 1:length(paramT) % They already are of inverse order
            eq = regexprep(eq,paramT{pp},paramNT{pp});
        end
        
        indV   = ismember(varsExo,matchesT);
        varsT  = strcat('(?<![A-Za-z_])',varsExo(indV),'(?![A-Za-z_0-9])');
        varsNT = varsExoN(indV);
        for vv = length(varsT):-1:1
            eq = regexprep(eq,varsT{vv},varsNT{vv});
        end
        
        indV   = ismember(varsCLead,matchesT);
        varsT  = strcat('(?<![A-Za-z_])',varsCLead(indV),'(?![A-Za-z_0-9])');
        varsNT = varsNS(indV);
        for vv = length(varsT):-1:1
            eq = regexprep(eq,varsT{vv},varsNT{vv});
        end
        stackedFirst{ii} = eq;
        
    end
    
end

function [out,varsN] = getEqOfPeriod(eqs,matches,pars,paramN,varsExo,varsExoN,vars,varsNS)
% Syntax:
%
% [out,varsN] = nb_perfectForesight.getEqOfPeriod(eqs,matches,pars,...
%                   paramN,varsExo,varsExoN,vars,varsN)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nEqs = size(eqs,1);

    % Sub for endogenous (first period)
    if nargin < 8
        [varsN,varsNS,vars] = nb_createGenericNames(vars,'vars'); 
    end

    % Translate the equations of one period
    out = cell(nEqs,1);
    for ii = 1:length(eqs)
    
        eq       = eqs{ii};
        matchesT = matches{ii};
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
        
        indV   = ismember(vars,matchesT);
        varsT  = strcat('(?<![A-Za-z_])',vars(indV),'(?![A-Za-z_0-9])');
        varsNT = varsNS(indV);
        for vv = length(varsT):-1:1
            eq = regexprep(eq,varsT{vv},varsNT{vv});
        end
        out{ii} = eq;
        
    end
    
end

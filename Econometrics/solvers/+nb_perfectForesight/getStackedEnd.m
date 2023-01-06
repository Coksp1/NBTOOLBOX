function [stackedEnd,endN,varsN] = getStackedEnd(eqs,matches,pars,paramN,varsExo,varsExoN,varsCLag,endVal)
% Syntax:
%
% [stackedEnd,endN,varsN] = nb_perfectForesight.getStackedEnd(eqs,...
%               matches,pars,paramN,varsExo,varsExoN,varsCLag,endVal)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get end conditions for the control variables
    endVar = fieldnames(endVal);
    endVar = strcat(endVar,'_lead');
    endN   = nb_createGenericNames(endVar,'endVal');
    
    % Sub for endogenous (last period)
    [varsN,varsNS,varsCLag] = nb_createGenericNames(varsCLag,'vars'); 

    % Get the stacked equation for the last period
    stackedEnd = cell(length(eqs),1);
    for ii = 1:length(eqs)
    
        eq       = eqs{ii};
        matchesT = matches{ii};
        ind      = ismember(endVar,matchesT);
        endT     = strcat('(?<![A-Za-z_])',endVar(ind),'(?![A-Za-z_0-9])');
        endNT    = endN(ind);
        for pp = length(endT):-1:1
            eq = regexprep(eq,endT{pp},endNT{pp});
        end
        
        ind     = ismember(pars,matchesT);
        paramT  = strcat('(?<![A-Za-z_])',pars(ind),'(?![A-Za-z_0-9])');
        paramNT = paramN(ind);
        for pp = 1:length(paramT) % They already are of inverse order
            eq = regexprep(eq,paramT{pp},paramNT{pp});
        end
        
        indV   = ismember(varsExo,matchesT);
        varsT  = strcat('(?<![A-Za-z_])',varsExo(indV),'(?![A-Za-z_0-9])');
        varsNT = varsExoN(indV);
        for vv = length(varsT):-1:1
            eq = regexprep(eq,varsT{vv},varsNT{vv});
        end
        
        indV   = ismember(varsCLag,matchesT);
        varsT  = strcat('(?<![A-Za-z_])',varsCLag(indV),'(?![A-Za-z_0-9])');
        varsNT = varsNS(indV);
        for vv = length(varsT):-1:1
            eq = regexprep(eq,varsT{vv},varsNT{vv});
        end
        stackedEnd{ii} = eq;
        
    end
    
end

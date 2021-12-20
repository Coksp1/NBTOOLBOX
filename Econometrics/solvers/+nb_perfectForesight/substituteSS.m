function eqs = substituteSS(eqs,endo)
% Syntax:
%
% [YT,err] = nb_perfectForesight.blockIteration(obj,funcs,inputs,iter,...
%                   outer,YT)
%
% Description:
%
% Here we need to substitute in for the end values where the steady-state
% operator is used.
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    matches = regexp(eqs,'steady_state\(\w+\)','match');
    for ii = 1:length(eqs)
        
        matchesEq = matches{ii};
        if ~isempty(matchesEq)
            
            matchesEq  = unique(matchesEq);
            matchesEq  = flip(matchesEq,2);
            ssExpr     = strrep(matchesEq,'steady_state(','');
            ssExpr     = cellfun(@(x)x(1:end-1),ssExpr,'uniformOutput',false);
            [test,loc] = ismember(ssExpr,endo);
            if any(~test)
                error([mfilename ':: You cannot use a expression in the steady-state operator which ',...
                                 'is not a single endogenous variable of the model. I.e; ' toString(ssExpr(~test))])
            end
            for jj = 1:length(ssExpr)
                eqs{ii} = strrep(eqs{ii},matchesEq{jj},['ssVars(' int2str(loc(jj)) ')']);
            end
            
        end
        
    end
    
end

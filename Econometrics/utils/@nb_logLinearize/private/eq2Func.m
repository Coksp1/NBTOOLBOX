function obj = eq2Func(obj)
% Syntax:
%
% obj = eq2Func(obj)
%
% Description:
%
% Converts the equations into a function handle
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Create the variables with lead and lag
    vars             = [strcat(obj.variables,'_lag'),obj.variables,strcat(obj.variables,'_lead')];
    [~,varsNS,varsS] = nb_createGenericNames(vars,'vars');    
    
    % Translate the equation into generic names
    eqs     = obj.equations;
    nEqs    = size(eqs,1);
    out     = cell(nEqs,1);
    matches = regexp(eqs,'[A-Za-z_]{1}[A-Za-z_0-9]*(?!\()','match');
    
    % Parse out parameters if not provided
    if isempty(obj.parameters)
        uMatches       = unique(nb_nestedCell2Cell(matches));
        ind            = ismember(uMatches,vars);
        obj.parameters = uMatches(~ind);
    end
    obj.parameters   = [obj.parameters,'zzz_constant'];
    [~,parsNS,parsS] = nb_createGenericNames(obj.parameters,'pars');  
    
    for ii = 1:length(eqs)
    
        eq       = eqs{ii};
        matchesT = matches{ii};
        ind      = ismember(parsS,matchesT);
        paramT   = strcat('(?<![A-Za-z_])',parsS(ind),'(?![A-Za-z_0-9])');
        paramNT  = parsNS(ind);
        for pp = length(paramT):-1:1 
            eq = regexprep(eq,paramT{pp},paramNT{pp});
        end

        indV   = ismember(varsS,matchesT);
        varsT  = strcat('(?<![A-Za-z_])',varsS(indV),'(?![A-Za-z_0-9])');
        varsNT = varsNS(indV);
        for vv = length(varsT):-1:1
            eq = regexprep(eq,varsT{vv},varsNT{vv});
        end
        if ~isnan(str2double(eq))
            % To make it possible to have equations like 1 = ...
            % we just substitute in a arbitrary parameter called 'constant'
            ind = strcmp('zzz_constant',parsS);
            eq  = parsNS{ind}; 
        end
        out{ii} = eq;
        
    end
       
    % Create function handle
    obj.eqFunc = nb_cell2func(out,'(vars,pars)');

end

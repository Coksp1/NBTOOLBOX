function parser = eq2func(parser)
% Syntax:
%
% parser = nb_nonLinearEq.eq2func(parser)
%
% Description:
%
% Convert equations to function handle.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Remove equality
    eqs = nb_model_parse.removeEquality(parser.equations);

    % Translate lag
    eqs = regexprep(eqs,'\s','');
    eqs = regexprep(eqs,'(?<=[^+-\*\^])\({1}[-]{1}(\d{1,2})\){1}','_lag$1');
    
    % For now we don't allow for more than one dependent variable
    if length(parser.dependent) > 1 || length(eqs) > 1
        error([mfilename ':: For now it is only allowed with one equation and one dependent variable.'])
    end
    
    % Find the lags of all variables
    vars      = [parser.dependent,parser.exogenous];
    matches   = regexp(eqs,'[A-Za-z_]{1}[A-Za-z_0-9]*(?!\()','match');
    matchesU  = unique(horzcat(matches{:}));
    ind       = ismember(matchesU,parser.parameters);
    matchesWP = matchesU(~ind);
    lags      = cell(1,length(vars));
    allVars   = cell(1,length(vars));
    for ii = 1:length(vars)
        matchesV    = regexp(matchesWP,['^' vars{ii} '_lag(\d{1,2})'],'tokens');
        matchesV    = nb_nestedCell2Cell(matchesV);
        lagsV       = nb_nestedCell2Cell(matchesV);
        lags{ii}    = str2num(char(lagsV))'; %#ok<ST2NM>
        allVars{ii} = [vars(ii),strcat(vars{ii},'_lag',lagsV)];
    end
    allVars = nb_nestedCell2Cell(allVars);
    allVars = flip(sort(allVars),2);
    
    % Are some matches unclassified?
    test = ismember(matchesWP,allVars);
    if any(~test)
        error(['The following parameters/variables are not classified: ' toString(matchesWP(~test))])
    end
    
    % Create function handle to optimize
    out              = translateEq(parser,eqs,matches,allVars);
    out              = strcat(out,';');
    out              = [out{:}];  
    parser.eqFunc    = str2func(['@(pars,dummy,vars,constant)[', out(1:end-1) ,']']);
    parser.variables = allVars;
    parser.lags      = lags;

end

%==========================================================================
function out = translateEq(parser,eqs,matches,vars)

    nEqs          = size(eqs,1);
    [pars,paramN] = nb_model_parse.getParamTranslation(parser.parameters);
    varsN         = getVars(vars);

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
        
        indV   = ismember(vars,matchesT);
        varsT  = strcat('(?<![A-Za-z_])',vars(indV),'(?![A-Za-z_0-9])');
        varsNT = varsN(indV);
        for vv = length(varsT):-1:1
            eq = regexprep(eq,varsT{vv},varsNT{vv});
        end
        out{ii} = eq;
        
    end
    
end

%==========================================================================
function varsN = getVars(vars)

    num   = 1:length(vars);
    numS  = strtrim(cellstr(int2str(num')));
    varsN = strcat('vars(:,',numS ,')');
    
end

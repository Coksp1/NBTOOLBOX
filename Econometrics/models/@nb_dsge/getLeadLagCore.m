function [eqs,test,leadCLag,endoS] = getLeadLagCore(parser,eqs,endo,exo)
% Syntax:
% 
% [eqs,test,leadCLag,endoS] = nb_dsge.getLeadLagCore(parser,eqs,endo,exo)
%
% Description:
%
% Get lead, current and lag incidence of a set of equations. 
%
% Static private method.
% 
% See also:
% nb_dsge.getLeadLag, nb_dsge.getLeadLagObsModel
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    endoS   = flip(sort(endo),2);
    numEndo = length(endo);
    params  = parser.parameters;

    % Find lead, current and lag indices
    %-----------------------------------
    matches   = regexp(eqs,'[A-Za-z_]{1}[A-Za-z_0-9]*(?:\({1}[+-]{0,1}\d+\){1}){0,1}','match');
    matches   = [matches{:}];
    matches   = unique(matches);
    functions = regexp(eqs,'[A-Za-z_]{1}[A-Za-z_0-9]*(?:\({1}[^+-].*?){1})','match');
    functions = [functions{:}];
    functions = unique(functions);
    
    % Subst out for var(1) with var(+1) and var(0) with var!
    par       = regexp(functions,'(?:\({1}[^+-].*?){1})','match');
    par       = [par{:}];
    functions = regexprep(functions,'(?:\({1}[^+-].*?){1})','');
    indR      = ismember(functions,endo);
    if any(indR)
        eqs = fixIndexing(eqs,functions(indR),par(indR));
    end
    functions = functions(~indR);
    par       = par(~indR);
    indR      = ismember(functions,exo);
    if any(indR)
        eqs = fixIndexing(eqs,functions(indR),par(indR));
    end
    functions = functions(~indR);
    
    % Remove the functions from the matches
    functions = unique(functions);
    indF      = ismember(matches,functions);
    matches   = matches(~indF);
    
    % Remove the parameters from the matches
    indP      = ismember(matches,params);
    matches   = matches(~indP);
    
    % Detect the lead, current and lag indices
    test = cell(numEndo,1);
    for ii = 1:numEndo
        endoT               = endoS{ii};
        numL                = size(endoT,2);
        pattern             = strcat('(?<![A-Za-z_0-9])',endoT,'(\([+-]\d+\))*$');
        indM                = not(cellfun(@(x)isempty(x),regexp(matches,pattern,'start')));
        match               = matches(indM);
        match               = cellfun(@(x)str2double(x(numL+2:end-1)),match);
        match(isnan(match)) = 0;
        test{ii}            = match;
    end
    leadCLag      = false(numEndo,3); 
    leadCLag(:,3) = cellfun(@(x)any(x == -1),test);
    leadCLag(:,2) = cellfun(@(x)any(x == 0),test);
    leadCLag(:,1) = cellfun(@(x)any(x == 1),test);
    
    % Check for lagged or leaded exogenous variables, which we do not allow
    % for
    exo     = flip(sort(exo),2);
    nExo    = length(exo);
    testExo = cell(nExo,1);
    for ii = 1:nExo
        numL                = size(exo{ii},2);
        indE                = strncmp(exo{ii},matches,numL);
        match               = matches(indE);
        match               = cellfun(@(x)str2double(x(numL+2:end-1)),match);
        match(isnan(match)) = 0;
        testExo{ii}            = match;
    end
    indLead = cellfun(@(x)any(x > 0),testExo);
    if any(indLead)
        error([mfilename ':: It is not possible to lead the exogenous variables; ' toString(exo(indLead))])
    end
    indLag  = cellfun(@(x)any(x < 0),testExo);
    if any(indLag)
        error([mfilename ':: It is not possible to lag the exogenous variables; ' toString(exo(indLag))])
    end
    
end

%==========================================================================
function eqs = fixIndexing(eqs,vars,parPart)
% Change var(0) to var
% Subst var(1) with var(+1)

    varsWPar = strcat(vars,parPart);
    ind0     = strcmp(parPart,'(0)');
    for ii = find(ind0)
        new = strrep(varsWPar{ii},'(','\(');
        new = strrep(new,')','\)');
        eqs = regexprep(eqs,['(?<![\w\d])' new],vars{ii});
    end
    for ii = find(~ind0)
        new = strrep(varsWPar{ii},'(','\(');
        new = strrep(new,')','\)');
        to  = strrep(varsWPar{ii},'(','(+');
        eqs = regexprep(eqs,['(?<![\w\d])' new],to);
    end

end

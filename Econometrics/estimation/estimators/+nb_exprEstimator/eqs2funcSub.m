function [eqFunc,nLags,varsOut] = eqs2funcSub(vars,eq,type)
% Syntax:
% 
% [eqFunc,nLags,varsOut] = nb_exprEstimator.eqs2funcSub(vars,eq,type)
%
% Description:
%
% Convert equation of the model to a function handle. Subroutine. 
% 
% Input:
%
% - vars : Allowed variables in the expression.
%
% - eq   : A one line char with one equation of the model.
%
% - type : Give 1 to indicate that you are interpreting the left hand
%          side variables.
%
% See also:
% nb_exprEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 0;
    end
    if type
        typeStr = 'left hand side';
    else
        typeStr = 'right hand side term';
    end
    
    
    matches = regexp(eq,'[A-Za-z_]{1}[A-Za-z_0-9]*\(t(-\d+)*\)','match');
    matches = unique(matches);
    if isempty(matches)
        matches = regexp(eq,'\(t(-\d+)*\)','match');
        if isempty(matches)
            error([mfilename ':: The following expression for the ' typeStr ' could not be interpreted; ' eq,...
                             '. Have you forgotten the timing of the variable, i.e. using x(t) syntax?'])
        else
            error([mfilename ':: The following expression for the ' typeStr ' could not be interpreted; ' eq])
        end
    end
    if type
        if length(matches) > 1
            error([mfilename ':: The expression for the left hand side can only contain one variable;' eq])
        end
        if ~nb_contains(matches{1},'(t)')
            error([mfilename ':: The expression for the left hand side can only be date as (t); ' eq]) 
        end
    end
    out      = eq;
    nMatches = length(matches);
    nLags    = zeros(1,nMatches);
    varsOut  = cell(1,nMatches);
    for ii = 1:nMatches
        matchesT   = matches{ii};
        indOpen    = strfind(matchesT,'(');
        varName    = matchesT(1:indOpen-1);
        locV       = find(strcmp(varName,vars));
        if isempty(locV)
           error(['Could not locate the variable ' varName ' in the data for the expression '  eq ' (Case sensitive!). ',...
                  'The data contain the following variables; ' toString(vars) '.']) 
        end
        newVarName = ['vars' matchesT(indOpen:end-1) ',' int2str(locV) ')']; 
        out        = strrep(out,matchesT,newVarName);
        index      = matchesT(indOpen+2:end-1);
        if ~isempty(index)
            nLags(ii) = -str2double(index);
        end
        varsOut{ii} = varName;
    end
        
    % Create function handle
    out = regexprep(out,'^diff\(','nb_diff('); % Fix problem with diff removing one observation!
    out = ['@(vars,t)', out];
    
    try
        eqFunc = str2func(out);
    catch Err
        err = ['Could not parse the expression for the ' typeStr ': ', eq];
        nb_error(err,Err);
    end
    
end

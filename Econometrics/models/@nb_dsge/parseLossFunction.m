function parser = parseLossFunction(parser,lossFunction)
% Syntax:
% 
% parser = nb_dsge.parseLossFunction(parser,lossFunction)
%
% Description:
%
% Parse loss function and 
% 
% See also:
% nb_dsge.parse, nb_dsge.setLossFunction
%
% Written by Kenneth Sæterhagen Paulsen
  
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    param       = parser.parameters;
    inUse       = parser.parametersInUse;
    isUncertain = parser.parametersIsUncertain;
    endo        = parser.endogenous; 
    
    % Get variables included in the loss function
    matches     = regexp(lossFunction,'[A-Za-z_]{1}[A-Za-z_0-9]*(?!\()','match');
    [ind,loc]   = ismember(matches,endo);
    vars        = matches(ind);
    loc         = loc(ind);
    
    % Substitute in the indexed vector of paramters
    paramLF = unique(matches(~ind));
    indP    = ismember(paramLF,param);
    if any(~indP)
        warning('nb_dsge:parseLossFunction',[mfilename ':: The following names used in the loss function are taken as parameters; '...
                toString(paramLF(~indP)) '. Remember to assign them some values!'])
        param       = [param,paramLF(~indP)];
        inUse       = [inUse,true(size(paramLF(~indP)))];
        isUncertain = [isUncertain,false(size(paramLF(~indP)))]; 
    end
    indInUse = ismember(param,paramLF);
    inUse    = inUse | indInUse;
    
    all = [endo,param];
    if any(ismember({'vars','pars'},all))
        error([mfilename ':: ''vars'' and ''pars'' cannot be used in variable or parameter names.'])
    end
    
    [~,locP] = ismember(paramLF,param);
    numS     = strtrim(cellstr(int2str(locP')));
    paramLF  = strcat('(?<![A-Za-z_])',paramLF,'(?![A-Za-z_0-9])');
    paramN   = strcat('pars(',numS ,')');
    for pp = 1:length(paramLF)
        lossFunction = regexprep(lossFunction,paramLF{pp},paramN{pp});
    end
    
    % Substitute in for the variables
    varsM = strcat('(?<![A-Za-z_])',vars,'(?![A-Za-z_0-9])');
    nVars = length(vars);
    num   = 1:nVars;
    numS  = strtrim(cellstr(int2str(num')));
    varsN = strcat('vars(',numS ,')');
    for vv = 1:nVars
        lossFunction = regexprep(lossFunction,varsM{vv},varsN{vv});
    end
    lossFunction = str2func(['@(vars,pars)' lossFunction]);
    
    % Store indexes of the loss function and loss variables
    parser.lossFunction          = lossFunction;
    parser.lossVariables         = varsN; 
    parser.lossVariablesIndex    = loc; 
    parser.lossVariableNames     = vars;
    parser.optimal               = true;
    parser.parameters            = param;
    parser.parametersInUse       = inUse;
    parser.parametersIsUncertain = isUncertain;
    
end

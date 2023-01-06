function parser = parseSimpleRules(parser,simpleRules)
% Syntax:
% 
% parser = nb_dsge.parseSimpleRules(parser,simpleRules)
%
% Description:
%
% Private method.
%
% Parse simple rules. 
% 
% See also:
% nb_dsge.set, nb_dsge.parse, nb_dsge.optimalSimpleRules
%
% Written by Kenneth Sæterhagen Paulsen
  
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    param       = parser.parameters;
    inUse       = parser.parametersInUse;
    isUncertain = parser.parametersIsUncertain;
    
    % Remove equalities
    simpleRules = nb_model_parse.removeEquality(simpleRules);
    
    % Rename lead and lag
    simpleRulesParsed = nb_dsge.transLeadLag(simpleRules);
    
    % Locate the endogenous variables
    matches = regexp(simpleRulesParsed,'[A-Za-z_]{1}[A-Za-z_0-9]*(?!\()','match');
    matches = horzcat(matches{:});
    endo    = parser.endogenous;
    vars    = [strcat(endo,'_lead'),endo,strcat(endo,'_lag'),parser.exogenous];
    ind     = ~ismember(matches,vars);

    % Substitute in the indexed vector of paramters
    paramSR = unique(matches(ind));
    indP    = ismember(paramSR,param);
    if any(~indP)
        warning('nb_dsge:parseSimpleRules',[mfilename ':: The following names used in the simple rules are taken as parameters; '...
                toString(paramSR(~indP)) '. Remember to assign them some values or some initial values for us by the optimizer!'])
        param       = [param,paramSR(~indP)]; 
        inUse       = [inUse,true(size(paramSR(~indP)))]; 
        isUncertain = [isUncertain,false(size(paramSR(~indP)))]; 
    end
    indInUse = ismember(param,paramSR);
    inUse    = inUse | indInUse;
    
    % Update parameters and equations
    nEqs                         = size(parser.equations,1);
    parser.parameters            = param;
    parser.parametersInUse       = inUse;
    parser.parametersIsUncertain = isUncertain;
    parser.equations             = [parser.equations; simpleRules];
    parser.equationsParsed       = [parser.equationsParsed; simpleRulesParsed];
    parser.optimalSimpleRule     = true;
    
    % Get lead/ lag incidence
    parser = nb_dsge.getLeadLag(parser);
    
    % Store simple rules to the model parser
    parser.simpleRules           = simpleRules;
    parser.numSimpleRules        = size(simpleRules,1);
    parser.indSimpleRules        = nEqs+1:nEqs+parser.numSimpleRules;
    [~,parser.srFunction]        = nb_dsge.eqs2funcSub(parser,simpleRulesParsed);
    parser.simpleRulesParameters = paramSR;
    
    % Create function handle
    numEndo     = length(parser.equations);
    numEq       = size(parser.equations,1);
    runEqs2Func = true;
    if numEndo > numEq
        runEqs2Func = false;
    end
    if numEndo < numEq
        runEqs2Func = false;
    end
    if runEqs2Func
        parser = nb_dsge.eqs2func(parser);
        parser = rmfield(parser,'equationsParsed');
        parser = nb_rmfield(parser,'derivativeFunc'); % Trigger re-calculation of symbolic derivatives
    end
    
    % Inticate that the function handle used for calculating the 
    % steady-state must be created
    parser.createStatic = true;
      
end

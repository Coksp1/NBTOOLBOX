function [funcs,inputs] = getStackedSystemFunction(obj,inputs,parser)
% Syntax:
%
% [funcs,inputs] = nb_perfectForesight.getStackedSystemFunction(obj,...
%                       inputs,parser)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin ~= 3
        parser = obj.parser;
    end
    
    % Get variables and parameters
    endo      = parser.endogenous;
    nVars     = length(endo);
    typeAll   = [-ones(1,nVars),zeros(1,nVars),ones(1,nVars)];
    allVars   = [strcat(endo,'_lag'),endo,strcat(endo,'_lead')];
    varsCLag  = allVars(typeAll < 1);
    varsCLead = allVars(typeAll > - 1);
    
    % Sub for parameters
    [paramN,paramNS,pars] = nb_perfectForesight.getParameters(parser);
    
    % Sub for exogenous
    if inputs.blockDecompose
        % Add the prologue variables as exogenous variables, as these are
        % already solved for when doing block decomposition
        proVars          = [strcat(parser.prologueVars,'_lag'),parser.prologueVars,strcat(parser.prologueVars,'_lead')];
        epiVars          = parser.epilogueVars;
        parser.exogenous = [parser.exogenous,proVars,epiVars];
    end
    [varsExo,varsExoN,varsExoNS] = nb_perfectForesight.getExo(parser);
    
    % Translate (+) and (-1)
    if any(parser.isAuxiliary)
        eqs = parser.equationsParsed;
    else
        eqs = parser.equations;
    end
    eqs = nb_dsge.transLeadLag(eqs);
    eqs = nb_perfectForesight.substituteSS(eqs,obj.parser.endogenous);
    
    % Translate the equations of the first period
    %-----------------------------------------------
    matches = regexp(eqs,'[A-Za-z_]{1}[A-Za-z_0-9]*(?!\()','match');
    
    % Set the first periods equations
    %--------------------------------
    [stackedFirst,initN,varsCLeadN] = nb_perfectForesight.getStackedFirst(eqs,matches,pars,paramNS,varsExo,varsExoNS,varsCLead,inputs.initVal);
    
    % Set the middle equations
    %---------------------------------
    [stackedEqs,varsN] = nb_perfectForesight.getEqOfPeriod(eqs,matches,pars,paramNS,varsExo,varsExoNS,allVars);
    
    % Set the last periods equations
    %--------------------------------
    [stackedEnd,endN,varsCLagN] = nb_perfectForesight.getStackedEnd(eqs,matches,pars,paramNS,varsExo,varsExoNS,varsCLag,inputs.endVal);

    % Go from stacked equations to function handle
    %--------------------------------
    GFirst = nb_cell2func(stackedFirst,'(vars,pars,varsExo,initVal,ssVars)');
    GEqs   = nb_cell2func(stackedEqs,'(vars,pars,varsExo,ssVars)');
    GEnd   = nb_cell2func(stackedEnd,'(vars,pars,varsExo,endVal,ssVars)');
    
    % Store some info needed later
    inputs.nVars = nVars; 
    funcs.GFirst = GFirst;
    funcs.GEqs   = GEqs;
    funcs.GEnd   = GEnd;
    
    % Calculate symbolic derivatives
    funcs.symbolic = false;
    if strcmpi(inputs.derivativeMethod,'symbolic')
        
        funcs.symbolic = true;
        
        % Get the inputs to calculate the derivatives
        varsD      = nb_mySD(varsN);
        varsCLeadD = nb_mySD(varsCLeadN);
        varsCLagD  = nb_mySD(varsCLagN);
        varsExoD   = nb_param(varsExoN);
        paramD     = nb_param(paramN);
        initD      = nb_param(initN);
        endD       = nb_param(endN);
        ssVarsD    = nb_param(nb_createGenericNames(obj.parser.endogenous,'ssVars'));
        
        % Derivatives at first period
        symDeriv          = GFirst(varsCLeadD,paramD,varsExoD,initD,ssVarsD);
        derivEqs          = [symDeriv.derivatives];
        funcs.GFirstDeriv = nb_cell2func(derivEqs,'(vars,pars,varsExo,initVal,ssVars)');
        [I,J]             = nb_getSymbolicDerivIndex(symDeriv,'vars',derivEqs);
        funcs.firstInd    = [I,J];
        
        % Derivatives at middle period
        symDeriv        = GEqs(varsD,paramD,varsExoD,ssVarsD);
        derivEqs        = [symDeriv.derivatives];
        funcs.GEqsDeriv = nb_cell2func([symDeriv.derivatives],'(vars,pars,varsExo,ssVars)');
        [I,J]           = nb_getSymbolicDerivIndex(symDeriv,'vars',derivEqs);
        funcs.eqsInd    = [I,J];
        
        % Derivatives at end period
        symDeriv        = GEnd(varsCLagD,paramD,varsExoD,endD,ssVarsD);
        derivEqs        = [symDeriv.derivatives];
        funcs.GEndDeriv = nb_cell2func([symDeriv.derivatives],'(vars,pars,varsExo,endVal,ssVars)');
        [I,J]           = nb_getSymbolicDerivIndex(symDeriv,'vars',derivEqs);
        funcs.endInd    = [I,J];  
        
    end
    
end

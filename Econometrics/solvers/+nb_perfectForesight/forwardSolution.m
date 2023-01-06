function [Y,err] = forwardSolution(obj,Y,inputs,eqs,vars,exoVal,iter)
% Syntax:
%
% [Y,err] = nb_perfectForesight.forwardSolution(obj,Y,inputs,eqs,vars,...
%               exoVal,iter)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    err = '';

    % Get variables and parameters
    if nargin ~= 7
        if any(obj.parser.isAuxiliary)
            eqs = obj.parser.equationsParsed;
        else
            eqs = obj.parser.equations;
        end
        vars   = obj.parser.endogenous;
        exoVal = inputs.exoVal;
        iter   = 1;
    end
    
    % Get initial values
    if iter == 1
        initVal = inputs.initVal;
    else
        initVal = cell2struct(num2cell(inputs.initValU(inputs.initValLoc)),fieldnames(inputs.initVal));
    end
    
    % Get the variables of the forward solution
    allVars = [strcat(vars,'_lag'),vars];
    nVars   = length(vars);
    
    % Sub for parameters
    [paramN,paramNS,pars] = nb_perfectForesight.getParameters(obj.parser);

    % Sub for exogenous
    [varsExo,varsExoN,varsExoNS] = nb_perfectForesight.getExo(obj.parser);

    % Translate (+) and (-1)
    eqs = nb_dsge.transLeadLag(eqs);
    eqs = nb_perfectForesight.substituteSS(eqs,obj.parser.endogenous);
    
    % Get the sub names
    num    = 1:nVars;
    numS   = strtrim(cellstr(int2str(num')));
    varsN  = strcat('vars(',numS ,')');
    initN  = strcat('init(',numS ,')');
    varsNA = [initN,varsN];
    
    % Sub for endogenous (first period)
    [allVars,varOrder] = sort(allVars);
    varsNA             = varsNA(varOrder);
    
    % Translate the equations
    matches = regexp(eqs,'[A-Za-z_]{1}[A-Za-z_0-9]*(?!\()','match');
    stacked = nb_perfectForesight.getEqOfPeriod(eqs,matches,pars,paramNS,varsExo,varsExoNS,allVars,varsNA);
    G       = nb_cell2func(stacked,'(vars,pars,varsExo,init,ssVars)');
    funcs.G = G;
    
    % Derive symbolic derivatives if that method is used.
    funcs.symbolic = false;
    if strcmpi(inputs.derivativeMethod,'symbolic')
        
        varsD          = nb_mySD(varsN);
        varsExoD       = nb_param(varsExoN);
        paramD         = nb_param(paramN);
        initD          = nb_param(initN);
        ssVarsD        = nb_param(nb_createGenericNames(obj.parser.endogenous,'ssVars'));
        funcs.symbolic = true;
        symDeriv       = G(varsD,paramD,varsExoD,initD,ssVarsD);
        derivEqs       = [symDeriv.derivatives];
        funcs.GDeriv   = nb_cell2func(derivEqs,'(vars,pars,varsExo,init,ssVars)');
        [I,J]          = nb_getSymbolicDerivIndex(symDeriv,'vars',derivEqs);
        funcs.ind      = [I,J];
        
    end
    
    % Get initial values
    init  = zeros(nVars,1);
    for ii = 1:nVars
        if isfield(initVal,vars{ii})
            init(ii) = initVal.(vars{ii});
        end
    end
    
    % Solve forward
    Y = reshape(Y,[nVars,inputs.periodsU(iter)]);
    for ii = 1:inputs.periodsU(iter)
        
        funcs = nb_perfectForesight.updateSystemFunctionOnePeriod(obj,funcs,inputs,init,exoVal(ii,:),iter);
        F     = @(Y)nb_perfectForesight.getFunctionValueOnePeriod(Y,funcs);
        if strcmpi(inputs.solver,'nb_solve')
            JF                   = @(Y)nb_perfectForesight.getJacobianOnePeriod(Y,funcs);
            [Y(:,ii),~,exitflag] = nb_solve.call(F,Y(:,ii),inputs.optimset,JF);
        elseif strcmpi(inputs.solver,'nb_abc')
            [Y(:,ii),~,exitflag] = nb_abcSolve.call(F,Y(:,ii),[],[],inputs.optimset);
        else
            error([mfilename ':: Unsupported solver ' inputs.solver])
        end
        err = nb_interpretExitFlag(inputs.solver,exitflag);

        % Notify about outer loop, if some...
        if ~isempty(err)    
            if nargout == 1
                error([mfilename ':: ' err])
            end
            break
        else
            init = Y(:,ii);
        end
        
    end
    
    % Return it vectorized as is the case for all the other solvers
    Y = Y(:);
    
end

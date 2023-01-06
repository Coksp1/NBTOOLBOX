function [Y,err] = epiSolver(obj,inputs,Y,iter)
% Syntax:
%
% [Y,err] = nb_perfectForesight.epiSolver(obj,inputs,Y,iter)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    err   = '';
    endo  = obj.parser.endogenous;
    nEndo = length(endo);
    if iter == 1
        initVal       = zeros(nEndo,1);
        [~,indI]      = ismember(fieldnames(inputs.initVal),endo);      
        initVal(indI) = cell2mat(struct2cell(inputs.initVal));
    else
        initVal = inputs.initValU; 
    end

    block    = obj.parser.block;
    epilogue = block.epiEqs;
    if ~any(epilogue)
        return
    end
    
    % Get index of the variables to pass to the epilogue solver 
    epiInd   = obj.parser.block.epiEndo;
    locEpi   = find(epiInd);
    epiVars  = endo(epiInd);
    nEpiVars = endo(~epiInd);
    nEpiInd  = [~epiInd(:);~epiInd(:);~epiInd(:)];
    epiInd   = [false(nEndo,1);epiInd(:);false(nEndo,1)];
    allVars  = [strcat(nEpiVars,'_lag'),nEpiVars,strcat(nEpiVars,'_lead')];
    nAllVars = nEndo*3;

    % Append init and end values
    endVal       = zeros(nEndo,1);
    [~,indE]     = ismember(fieldnames(inputs.endVal),endo); 
    endVal(indE) = cell2mat(struct2cell(inputs.endVal(iter)));
    YF           = [initVal;Y;endVal];

    % Get function to use for each period
    if any(obj.parser.isAuxiliary)
        eqs = obj.parser.equationsParsed;
    else
        eqs = obj.parser.equations;
    end
    eqsEpi    = eqs(obj.parser.block.epiEqs);
    [~,funcs] = nb_perfectForesight.eqs2funcEpi(inputs,obj.parser.endogenous,epiVars,allVars,obj.parser.exogenous,obj.parser.parameters,eqsEpi);

    % Solve for the epilogue
    varsSS = inputs.ss(:,iter);
    exoVal = inputs.exoVal(inputs.startExo(iter):end,:,iter);
    parVal = obj.parameters.value;
    for ii = 1:inputs.periodsU(iter)

        % Get exogenous variables of sub-period
        exoValPer = exoVal(ii,:);
        parExoVal = [parVal;exoValPer(:)];

        % Get the vector of results of the endogenous variables
        % we are interested in
        indPeriod = nEndo*(ii-1) + (1:nAllVars); 
        Yperiod   = YF(indPeriod);
        Yepi      = Yperiod(epiInd);
        YNotEpi   = Yperiod(nEpiInd);

        % Solve the problem
        funcs = nb_perfectForesight.updateEpiFunctionOnePeriod(funcs,YNotEpi,parExoVal,varsSS);
        F     = @(Y)nb_perfectForesight.getFunctionValueOnePeriod(Y,funcs);
        if strcmpi(inputs.solver,'nb_solve')
            JF                = @(Y)nb_perfectForesight.getJacobianOnePeriod(Y,funcs);
            [Yepi,~,exitflag] = nb_solve.call(F,Yepi,inputs.optimset,JF);
        elseif strcmpi(inputs.solver,'nb_abc')
            [Yepi,~,exitflag] = nb_abcSolve.call(F,Yepi,[],[],inputs.optimset);
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
            Y(locEpi) = Yepi;
            locEpi    = locEpi + nEndo;
        end
        
    end
    
end

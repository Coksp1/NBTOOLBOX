function irfData = collect(options,inputs,Y,dep,results,ss)
% Syntax:
%
% irfData = nb_irfEngine.collect(options,inputs,Y,dep,results,ss)
%
% Description:
%
% Collect IRFs.
%
% See also:
% nb_irfEngine.irfPoint, nb_irfEngine.irfPointStochTrend
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Reported variables
    Y = permute(Y,[2,1,3]);
    if ~isempty(inputs.reporting)
        [Y,dep] = nb_irfEngine.createReportedVariables(options,inputs,Y,dep,results,ss);
    end
    
    % Normalize the IRFs
    nShocks   = length(inputs.shocks);
    normalize = inputs.normalize;
    if ~isempty(normalize) && strcmpi(inputs.normalizeTo,'draws')
        
        if strcmpi(options.class,'nb_dsge')
            % Set steady-state of reported variables to zero
            ssMatVar = getSteadyState(inputs,nShocks,ss);
            ssMat    = zeros(size(Y));
            if ~isempty(inputs.reporting)
                indRep = ismember(dep,inputs.reporting(:,1));
            else
                indRep = false(1,length(dep));
            end
            ssMat(:,~indRep,:) = ssMatVar;
            Ygap               = Y - ssMat; % Substract the steady-state before normalizing
        else
            Ygap = Y;
        end
        try
            normVar   = normalize{1};
            normLevel = normalize{2};
            try 
                normPeriod = normalize{3}; 
            catch %#ok<CTCH>
                normPeriod = 2; 
            end 
            normInd = find(strcmp(normVar,dep),1);
            if isempty(normInd)
                error('irfPoint:catchThis',[mfilename ':: The variable you want to normalize to (' normVar ') is not a variable of the model; ' toString(dep)])
            end
            if ~isfinite(normPeriod)
                [~,normPeriod] = max(Ygap(:,normInd,:),[],1);
                normFactor     = nan(1,1,nShocks);
                for ii = 1:nShocks
                    normFactor(ii) = normLevel./Ygap(normPeriod(ii),normInd,ii);
                end
            else
                normFactor = normLevel./Ygap(normPeriod,normInd,:);
            end
            normFactor(isinf(normFactor)) = 0;
            factorValue                   = repmat(normFactor,[inputs.periods + 1,size(Ygap,2),1]);
       
        catch Err
            if strcmpi(Err.identifier,'irfPoint:catchThis')
                rethrow(Err)
            else
                error([mfilename ':: Wrong input given to the ''normalize'' input. MATLAB error: ' Err.message])
            end
        end
        if strcmpi(options.class,'nb_dsge')
            Y = ssMat + Ygap.*factorValue;
        else
            Y = Ygap.*factorValue;
        end
        
    end
    
    % Collect irf of the variables
    nVars             = length(inputs.variables);
    [found,indV]      = ismember(dep,inputs.variables);
    indV              = indV(found);
    irfData           = nan(inputs.periods+1,nVars,nShocks);
    irfData(:,indV,:) = Y(:,found,:); 
    
    % Construct level variables
    if ~isempty(inputs.variablesLevel)
        
        nVars              = length(inputs.variablesLevel);
        [found,indV]       = ismember(dep,inputs.variablesLevel);
        indV               = indV(found);
        irfDataL           = zeros(inputs.periods+1,nVars,nShocks);
        irfDataL(:,indV,:) = Y(:,found,:); 
        
        if ~isempty(normalize)
            factorValue = repmat(normFactor,[inputs.periods + 1,nVars,1]);
            irfDataL    = irfDataL.*factorValue;
        end
        
        switch lower(inputs.levelMethod)
            case 'cumulative product'
                irfDataL = irfDataL + 1;
                irfDataL = cumprod(irfDataL,1);
            case 'cumulative sum'
                irfDataL = cumsum(irfDataL,1);
            case 'cumulative product (log)'
                irfDataL = irfDataL + 1;
                irfDataL = log(cumprod(irfDataL,1));
            case 'cumulative sum (exponential)'
                irfDataL = exp(cumsum(irfDataL,1));
            case 'cumulative product (%)'
                irfDataL = irfDataL/100 + 1;
                irfDataL = cumprod(irfDataL,1);
            case 'cumulative sum (%)'
                irfDataL = irfDataL/100 ;
                irfDataL = cumsum(irfDataL,1);
            case 'cumulative product (log) (%)'
                irfDataL = irfDataL/100 + 1;
                irfDataL = log(cumprod(irfDataL,1));
            case 'cumulative sum (exponential) (%)'
                irfDataL = irfDataL/100;
                irfDataL = exp(cumsum(irfDataL,1));
            case '4 period growth (log approx)' 
                irfDataL = nb_msum(irfDataL,3);
        end
        irfData = [irfData,irfDataL];
        
    end
    
end

%==========================================================================
function ssMat = getSteadyState(inputs,nShocks,ss)

    if ~iscell(ss)
        if size(ss,1) == inputs.periods + 1
            ssMat = ss;
            return
        end
    end
    
    if iscell(ss) && (isempty(inputs.startingValues) || ...
            any(strcmpi(inputs.startingValues,{'steady_state','steadystate'})))
        inputs.startingValues = 'steady_state(1)';
    end

    switch lower(inputs.startingValues)
        case {'zero','zeros','steady_state','steadystate',''}
            % In this case we have one steady-state for each period
            ssRow = ss';
            ssMat = ssRow(ones(1,inputs.periods+1),:,ones(1,nShocks));
        otherwise
            % In the steady-state may change, so we must find the
            % steady-state for each period of the simulation
            startState = regexp(inputs.startingValues,'(\d)','tokens');
            startState = str2double(startState{1}{1});
            states     = [startState;inputs.states];
            ssMat      = zeros(inputs.periods+1,size(ss{1},1),nShocks);
            for tt = 1:inputs.periods+1
                ssTT          = ss{states(tt)};
                ssTT          = ssTT(:,:,ones(nShocks,1));
                ssMat(tt,:,:) = ssTT;
            end
    end
    
end

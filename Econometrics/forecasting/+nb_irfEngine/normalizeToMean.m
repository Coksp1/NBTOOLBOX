function irfData = normalizeToMean(options,inputs,irfData)
% Syntax:
%
% irfData = nb_irfEngine.normalizeToMean(options,inputs,irfData)
%
% Description:
%
% Normalize IRFs to mean.
%
% See also:
% nb_irfEngine
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(inputs.variables)
        error('If ''normalizeTo'' is set to ''mean'' the ''variables'' input must be set.')
    end

    % Normalize the IRFs
    nShocks   = length(inputs.shocks);
    nPages    = size(irfData,4);
    normalize = inputs.normalize;
    if ~isempty(normalize) && strcmpi(inputs.normalizeTo,'mean')
             
        if strcmpi(options.class,'nb_dsge')
            ssMat = getSteadyState(inputs,nShocks,nPages,ss);
            Ygap  = irfData - ssMat; % Substract the steady-state before normalizing
        else
            Ygap = irfData;
        end
        try
            normVar   = normalize{1};
            normLevel = normalize{2};
            try 
                normPeriod = normalize{3}; 
            catch %#ok<CTCH>
                normPeriod = 2; 
            end 
            normInd = find(strcmp(normVar,inputs.variables),1);
            if isempty(normInd)
                error('irfPoint:catchThis',[mfilename ':: The variable you want to normalize to (' normVar ') is not a variable of the model; ' toString(inputs.variables)])
            end
            if ~isfinite(normPeriod)
                [~,normPeriod] = max(Ygap(:,normInd,:,end),[],1);
                normFactor     = nan(1,1,nShocks);
                for ii = 1:nShocks
                    normFactor(ii) = normLevel./Ygap(normPeriod(ii),normInd,ii,end);
                end
            else
                normFactor = normLevel./Ygap(normPeriod,normInd,:,end);
            end
            normFactor(isinf(normFactor)) = 0;
            factorValue                   = repmat(normFactor,[inputs.periods + 1,size(Ygap,2),1,size(irfData,4)]);
       
        catch Err
            if strcmpi(Err.identifier,'irfPoint:catchThis')
                rethrow(Err);
            else
                error([mfilename ':: Wrong input given to the ''normalize'' input. MATLAB error: ' Err.message])
            end
        end
        if strcmpi(options.class,'nb_dsge')
            irfData = ssMat + Ygap.*factorValue;
        else
            irfData = Ygap.*factorValue;
        end
        
    end
    
end

%==========================================================================
function ssMat = getSteadyState(inputs,nShocks,nPages,ss)

    if ~iscell(ss)
        if size(ss,1) == inputs.periods + 1
            ssMat = ss;
            return
        end
    end

    switch lower(inputs.startingValues)
        case {'zero','zeros','steady_state','steadystate',''}
            % In this case we have one steady-state for all period
            ssRow = ss';
            ssMat = ssRow(ones(1,inputs.periods+1),:,ones(1,nShocks),ones(1,nPages));
        otherwise
            % In the steady-state may change, so we must find the
            % steady-state for each period of the simulation
            startState = regexp(inputs.startingValues,'(\d)','tokens');
            startState = str2double(startState{1}{1});
            states     = [startState;inputs.states];
            ssMat      = zeros(inputs.periods+1,size(ss{1},1),nShocks,nPages);
            for tt = 1:inputs.periods+1
                ssTT          = ss{states(tt)};
                ssTT          = ssTT(:,:,ones(nShocks,1),ones(1,nPages));
                ssMat(tt,:,:) = ssTT;
            end
    end
    
end

function [H,y,mixing] = applyMeasurementEqRestriction(H,y,options,mixing)
% Syntax:
%
% [H,y,mixing] = nb_bVarEstimator.applyMeasurementEqRestriction(H,y,...
%       options,mixing)
%
% Description:
%
% Apply measurement equation restrictions.
% 
% See also:
% nb_var.setMeasurementEqRestriction, nb_bVarEstimator.estimate,
% nb_bVarEstimator.recursiveEstimation
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    allDep = [options.dependent,options.block_exogenous];
    if ~isfield(options,'indObservedOnly') || isempty(options.indObservedOnly)
        options.indObservedOnly = false(1,length(allDep));
    end
    allStates = allDep(~options.indObservedOnly); 
    measRest  = options.measurementEqRestriction;
    numRest   = length(measRest);
    measOnly  = false;
    sample    = options.estim_start_ind:options.estim_end_ind;
    T         = options.estim_end_ind - options.estim_start_ind + 1;
    if isempty(y) && nargout < 2
        % Only calculate measurement eq at the last period!
        measOnly = true;
    else
        yRest = nan(T,numRest);
    end
    
    timeVarying = false;
    for ii = 1:numRest
        if iscell(measRest(ii).parameters)
            timeVarying = true;
            break;
        end
    end
    if timeVarying
        nPages = T;
    else
        nPages = 1;
    end
    
    nStates      = size(H,2);
    HRest        = zeros(numRest,nStates,nPages);
    freq         = nan(1,numRest);
    [~,dataFreq] = nb_date.date2freq(options.dataStartDate);
    for ii = 1:numRest
        
        % Get restricted variable
        if ~measOnly
            [test,loc] = ismember(measRest(ii).restricted,options.dataVariables);
            if ~any(test)
                error(['The restricted field of the measurementEqRestriction ',...
                       'must be a variable that is also in the data of the model. ',...
                       measRest(ii).restricted ' is not among ', ...
                       toString(options.dataVariables)])
            end
            yRest(:,ii) = options.data(sample,loc);
        end
        
        % Get index of parameter restrictions
        [test2,locVars] = ismember(measRest(ii).variables,allStates);
        if any(~test2)
            error(['The variables field of the measurementEqRestriction ',...
                   'must be variables that are also state variables ',...
                   'of the model. ' toString(measRest(ii).variables(~test2)),...
                   ' are not among ',toString(allStates)])
        end
        
        % Get frequency
        if isfield(measRest(ii),'frequency')
            % If frequency is set, so is mapping, as assured for in
            % nb_var.setMeasurementEqRestriction
            freqThis = measRest(ii).frequency;
            mapping  = measRest(ii).mapping;
        else
            freqThis = [];
            mapping  = '';
        end
        
        % Get parameters
        if iscell(measRest(ii).parameters)
            
            % Parameters are time-varying
            [test3,locParam] = ismember(measRest(ii).parameters,options.dataVariables);
            if any(~test3)
                error(['The parameters field of the measurementEqRestriction (element ' int2str(ii) ') ',...
                       'must be found to be in the data of the model. Cannot find ',... 
                       toString(measRest(ii).parameters(~test3)) ' among the ',...
                       'variables of the dataset ' toString(options.dataVariables)])
            end
            params = options.data(options.estim_start_ind:options.estim_end_ind,locParam);
            if any(isnan(params(:)))
                error(['The parameters for the measurement equation restrictions ',...
                       'cannot be nan! Some of the variables ' toString(measRest(ii).parameters),...
                       ' have missing observations.'])
            end
            
            if ~isempty(freqThis)
                freq(ii)   = freqThis;
                nVars      = length(measRest(ii).variables);
                indMapping = ismember(allStates,measRest(ii).variables);
                if size(H,3) == 1 
                    % Get mapping for this restriction, and expand
                    Hi   = getMapping(mapping,dataFreq/freqThis);
                    lags = size(Hi,2);
                    Hi   = Hi(ones(1,nVars),:);
                    Hi   = Hi(:)';
                    
                    % Get time-varying parameters, where we need to lag
                    % the parameters according to the mapping
                    indMapping  = repmat(indMapping,[1,lags]);
                    indMapping  = [indMapping,false(1,nStates-size(indMapping,2))]; %#ok<AGROW>
                    paramsFirst = params(1,:);
                    paramsLags  = [params,nb_mlag(params,lags-1,'varFast')];
                    
                    % Backcast weights for lags!
                    for jj = 1:lags-1
                        ind                = nVars*jj+1:nVars*lags;
                        paramsLags(jj,ind) = repmat(paramsFirst,[1,lags-jj]);
                    end
                    
                    % Assign measurement equation
                    HRest(ii,indMapping,:) = permute(bsxfun(@times,paramsLags,Hi),[3,2,1]);
                else
                    error(['Weekly frequency is not yet supported when the ',...
                           'measurementEqRestriction option is used.'])
                end
            else
                % Assign measurement equation
                freq(ii)            = dataFreq;
                HRest(ii,locVars,:) = permute(options.data(sample,locParam),[3,2,1]);
            end

        else
            % Parameters are fixed for this restriction
            params = measRest(ii).parameters;
            if ~isempty(freqThis)
                freq(ii)   = freqThis;
                nVars      = length(measRest(ii).variables);
                indMapping = ismember(allStates,measRest(ii).variables);
                if size(H,3) == 1 
                    % Get mapping for this restriction, and expand
                    Hi   = getMapping(mapping,dataFreq/freqThis);
                    lags = size(Hi,2);
                    Hi   = Hi(ones(1,nVars),:);
                    Hi   = Hi(:)';
                    
                    % Get parameters, where we need to replicate the 
                    % parameters according to the mapping
                    indMapping       = repmat(indMapping,[1,lags]);
                    indMapping       = [indMapping,false(1,nStates-size(indMapping,2))]; %#ok<AGROW>
                    paramsLags       = repmat(params,[1,lags]);
                    paramsMappingLag = Hi.*paramsLags;
                    
                    % Assign measurement equation
                    HRest(ii,indMapping,:) = paramsMappingLag(:,:,ones(1,nPages));
                else
                    error(['Weekly frequency is not yet supported when the ',...
                           'measurementEqRestriction option is used.'])
                end
            else
                % Assign measurement equation
                freq(ii)            = dataFreq;
                HRest(ii,locVars,:) = params(:,:,ones(1,nPages));
            end
        end
        
    end
    
    % Append new measurement equations
    if nargout > 1
        if isempty(y)
            y = yRest;
        else
            y = [y,yRest];
        end
    end
    if size(H,3) ~= size(HRest,3)
        H = H(:,:,ones(1,nPages));
    end
    if size(H,2) < size(HRest,2)
        nLags       = size(H,2)/size(H,1);
        nLagsNeeded = size(HRest,2)/size(H,1);
        error(['The model has only ' int2str(nLags) ' lags, but ',...
            int2str(nLagsNeeded) ' are needed for the added measurement ',...
            'restrictions.']);
    end
    H = [H;HRest];
    
    % Update mixing input
    if nargout > 2
        if isempty(mixing)
            mixing = struct();
            mixing.indObservedOnly = [false(1,length(allDep)),true(1,numRest)];
            loc                    = length(allDep) + 1:length(allDep)+numRest;
            mixing.loc             = loc;
            mixing.locLow          = loc;
            mixing.locIn           = loc;
            mixing.frequency       = freq; 
        else
            mixing.indObservedOnly = [mixing.indObservedOnly,true(1,numRest)];
            loc                    = length(allDep) + 1:length(allDep)+numRest;
            mixing.loc             = [mixing.loc,loc];
            mixing.locLow          = [mixing.locLow,loc];
            mixing.locIn           = [mixing.locIn,loc];
            mixing.frequency       = [mixing.frequency,freq];    
        end
    end

end

%==========================================================================
function Hi = getMapping(mapping,divFreq)

    switch lower(mapping)
        case 'levelsummed'
            Hi = ones(1,divFreq);
        case 'diffsummed'
            Hi1 = 1:divFreq;
            Hi2 = divFreq-1:-1:1;
            Hi  = [Hi1,Hi2]; 
        case 'levelaverage'
            Hi = ones(1,divFreq)/divFreq;
        case 'diffaverage'
            Hi1 = 1:divFreq;
            Hi2 = divFreq-1:-1:1;
            Hi  = [Hi1,Hi2]/divFreq; 
        case 'end'
            Hi = 1;   
    end
    
end

function inputs = interpretBins(options,inputs)
% Syntax:
%
% inputs = interpretBins(options,inputs)
%
% Description:
%
% Interpret the 'bins' input.
% 
% See also:
% nb_forecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~iscell(inputs.bins)
        return
    end
    
    % Get forecasted variables
    if strcmpi(options.estimator,'nb_arimaEstimator')
        
        if options.integration > 0
       
            var  = options.dependent{1};
            uInd = strfind(var,'_');
            dep  = {var(uInd(1) + 1:end)};
            
        end
        
    else
        
        if isempty(inputs.varOfInterest)
            dep = options.dependent;
            if isfield(options,'block_exogenous')
                dep = [dep,options.block_exogenous];
            end
        else
            dep = {inputs.varOfInterest};
        end
        
    end
    
    % Get index of the forecast
    bins  = inputs.bins;
    nBins = size(bins,1);
    found = true(nBins,1);
    for ii = 1:nBins
        
        var = bins{ii,1};
        ind = find(strcmp(var,dep),1);
        if isempty(ind)
            found(ii) = false;
        else
            bins{ii,1} = ind;
        end
        
    end
    
    % Remove the variables that is not found
    inputs.bins = bins(found,:);
        
end

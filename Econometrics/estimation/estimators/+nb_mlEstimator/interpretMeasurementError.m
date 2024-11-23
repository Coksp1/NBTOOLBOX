function options = interpretMeasurementError(options)
% Syntax:
%
% options = nb_mlEstimator.interpretMeasurementError(options)
%
% Description:
%
% Get indicies of the measurement error parameters to estimate.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isfield(options,'measurementError')
        options.measurementErrorInd = [];
        return
    end

    if isempty(options.measurementError) 
        options.measurementErrorInd = [];
        return
    end
    options.measurementError = options.measurementError(:);
    if ~iscellstr(options.measurementError)
        error([mfilename ':: The measurementError option must be a cellstr.'])
    end

    depNames = options.dependent;
    if isfield(options,'block_exogenous')
       depNames = [depNames,options.block_exogenous];
    end
    [test,indC] = ismember(options.measurementError,depNames);
    if any(~test)
        error([mfilename ':: The following names cannot be associated with a measurement error, ',...
                         'as they are not a dependent or block exogenous variables of the model; ' toString(pCoeffN(~test)) '.'])
    end
    options.measurementErrorInd = indC;

end

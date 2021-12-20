function [options,varargout] = testSample(options,varargin)
% Syntax:
%
% [options,varargout] = nb_estimator.testSample(options,varargin)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    dataS    = nb_date.date2freq(options.dataStartDate);
    endInd   = options.estim_end_ind;
    startInd = options.estim_start_ind;
    X        = [varargin{:}];
    isNaN    = any(~isfinite(X),2);
    
    if isNaN(1)
        startI = find(~isNaN,1);
    else
        startI = 1;
    end
    endI = find(~isNaN,1,'last');
    if isempty(endI)
        error([mfilename ':: The data is unbalanced, which is not yet supported.'])
    end
    
    if isempty(startInd)
        startInd = startI;
    else
        if startInd < startI
            error([mfilename ':: The selected start date introduce missing observations in the data. First valid start date is ' toString(dataS + startI - 1)])
        end
    end

    if isempty(endInd)
        endInd = endI;
    else
        if endInd > endI
            error([mfilename ':: The selected end date introduce missing observations in the data. Last valid end date is ' toString(dataS + endI - 1)])
        end
    end
    options.estim_end_ind   = endInd;
    options.estim_start_ind = startInd;

    if any(isNaN(startInd:endInd))
        error([mfilename ':: The data contain missing observation in the middle of the sample, which this estimator does not support.'])
    end
    
    varargout = varargin;
    for ii = 1:length(varargout)
        varargout{ii} = varargout{ii}(startInd:endInd,:);
    end
    
end

function [y,options] = loadData(options,parser)
% Syntax:
%
% [y,options] = nb_statespaceEstimator.loadData(options,parser)
%
% Description:
%
% Load data on observables.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Missing observations is not problem here, so just use the size of the
    % data field as default
    if isempty(options.estim_start_ind)
        options.estim_start_ind = 1;
    end
    if isempty(options.estim_end_ind)
        options.estim_end_ind = size(options.data,1);
    end

    % Locate observables
    tempObs    = parser.observables;
    [test,ind] = ismember(tempObs,options.dataVariables);
    if ~all(test)
        error([mfilename ':: The following observables has not been decleared any data; ' toString(tempObs(~test)) '.'])
    end
    
    % Get the estimation data
    %------------------------------------------------------
    y = options.data(options.estim_start_ind:options.estim_end_ind,ind)';

end

function start = getEstimationStartDate(obj)
% Syntax:
%
% start = getEstimationStartDate(obj)
%
% Description:
%
% Get the start date of the estimation of the model.
% 
% Input:
% 
% - obj   : An object of class nb_model_recursive_detrending
% 
% Output:
% 
% - start : An object of class nb_date.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: Only scalar nb_model_recursive_detrending objects are supported.'])
    end

    if ~isestimated(obj)
        error([mfilename ':: The model is not estimated. Can''t get the estimation start date.'])
    end
    start = obj.modelIter(1).options.data.startDate + (obj.modelIter(1).estOptions.estim_start_ind - 1);
        
end

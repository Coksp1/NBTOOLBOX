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
% - obj   : An object of class nb_model_generic
% 
% Output:
% 
% - start : An object of class nb_date.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: Only scalar nb_model_generic objects are supported.'])
    end

    if ~isestimated(obj)
        error([mfilename ':: The model is not estimated. Can''t get the estimation start date.'])
    end
    start = obj.options.data.startDate + (obj.estOptions(end).estim_start_ind - 1);
        
end

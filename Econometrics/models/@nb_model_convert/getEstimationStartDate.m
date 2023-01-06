function start = getEstimationStartDate(obj)
% Syntax:
%
% start = getEstimationStartDate(obj)
%
% Description:
%
% Get the start date of the model. The return value is the
% estimation start date of the model that is ordered last.
% 
% Input:
% 
% - obj   : An object of class nb_model_convert
% 
% Output:
% 
% - start : An object of class nb_date.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(obj.model)
        error([mfilename ':: The nb_model_convert object is empty, so to call this function make no sense!'])
    end
    start = convert(getEstimationStartDate(obj.model),obj.options.freq,false);
        
end

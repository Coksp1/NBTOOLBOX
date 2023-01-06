function start = getEstimationStartDate(obj)
% Syntax:
%
% start = getEstimationStartDate(obj)
%
% Description:
%
% Get the start date of the model group. The return value is the
% estimation start date of the model that is ordered last.
% 
% Input:
% 
% - obj   : An object of class nb_model_group
% 
% Output:
% 
% - start : An object of class nb_date.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(obj.models)
        error([mfilename ':: The model group object is empty, so to call this function make no sense!'])
    end
    start = getEstimationStartDate(obj.models{1});
    for ii = 2:length(obj.models)
        
        startT = getEstimationStartDate(obj.models{ii});
        if ~isa(startT,class(start))
            
            if start.frequency > startT.frequency
                start = convert(start,startT.frequency);
            else
                startT = convert(startT,start.frequency);
            end
            
        end
        
        if start > startT
            start = startT;
        end
        
    end
        
end

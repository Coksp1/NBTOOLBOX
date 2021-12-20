function obj = checkReporting(obj)
% Syntax:
%
% obj = checkReporting(obj)
%
% Description:
%
% Check reporting, and store historical observation of reported variables
% 
% Input:
% 
% - obj : A scalar nb_model_recursive_detrending object with the reporting
%         property set.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        obj = nb_callMethod(obj,@checkReporting,@nb_model_recursive_detrending);
        return
    end
    if isempty(obj.reporting)
        error([mfilename ':: The property reporting cannot be empty.'])
    end
    if isempty(obj.modelIter)
        error([mfilename ':: You must first call the createVariables method.'])
    end
    for ii = 1:length(obj.modelIter)
        obj.modelIter(ii) = setReporting(obj.modelIter(ii),obj.reporting);
        obj.modelIter(ii) = checkReporting(obj.modelIter(ii));
    end
    obj.reported = true;
    
end

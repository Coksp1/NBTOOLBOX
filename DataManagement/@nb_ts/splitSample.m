function data = splitSample(obj,nSteps,appendNaN)
% Syntax:
%
% data = splitSample(obj,nSteps,appendNaN)
%
% Description:
%
% Split a sample into a multipaged nb_data object with size nSteps x nvar 
% x nobs. Will append nan values for the last observations as default. 
% 
% Input:
% 
% - data      : An object of class nb_ts.
% 
% - nSteps    : The number of period of the splitted data. As a scalar
%               integer.
%
% - appendNaN : true or false. Default is true.
%
% Output:
% 
% - data   : An object of class nb_data with size nSteps x nvar x nobs.
%
% Examples:
%
% data = splitSample(nb_ts.rand(1,20,2),4)
%
% See also:
% nb_ts, nb_ts.splitSeries
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        appendNaN = true;
    end

    data   = nb_splitSample(obj.data,nSteps);
    dNames = dates(obj);
    if ~appendNaN
        per    = size(data,3) - nSteps + 1;
        data   = data(:,:,1:per);
        dNames = dNames(1:per);
    end
    data                = nb_data(data,'',1,obj.variables,obj.sorted);
    data.dataNames      = dNames;
    data.localVariables = obj.localVariables;
    
    if obj.isUpdateable()
        obj   = obj.addOperation(@splitSample,{nSteps});
        links = obj.links;
        data  = data.setLinks(links);   
    end
    
end

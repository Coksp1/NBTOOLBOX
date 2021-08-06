function obj = removeObservations(obj,numPer)
% Syntax: 
%
% obj = removeObservations(obj,numPer)
%
% Description:
%
% Remove the number of wanted observation from each series stored in the
% data of the object. If one variable contain less observation than 
% another it will still be removed another observation, so as to 
% preserve the ragged edge of the data.
% 
% Input: 
%
% - obj    : A nb_modelData object
% 
% - numPer : The amount of observations to remove at the end of the sample
%            for each series. By removal we meen setting it to nan.
% 
% Output: 
%
% - obj    : A nb_modelData object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(obj.dataOrig)
        error([mfilename ':: The data of the model is empty, so cannot remove any observations.']) 
    end
    obj.dataOrig = removeObservations(obj.dataOrig,numPer);
    
    if isa(obj,'nb_model_selection_group')
        for ii = 1:length(obj.models)
            obj.models{ii} = removeObservations(obj.models{ii},numPer);
        end
    end
    
end

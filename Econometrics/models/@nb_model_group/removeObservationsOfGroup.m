function obj = removeObservationsOfGroup(obj,numPer)
% Syntax: 
%
% obj = removeObservationsOfGroup(obj,numPer)
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
% - obj    : A nb_model_group or nb_model_selection_group object.
% 
% - numPer : The amount of observations to remove at the end of the sample
%            for each series. By removal we meen setting it to nan.
% 
% Output: 
%
% - obj    : A nb_model_group or nb_model_selection_group object.
%
% See also:
% nb_model_selection_group.removeObservations
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(obj,'nb_model_selection_group')
        
        if isempty(obj.dataOrig)
            error([mfilename ':: The data of the model is empty, so cannot remove any observations.']) 
        end
        obj.dataOrig = removeObservations(obj.dataOrig,numPer);
        
    end
       
    for ii = 1:length(obj.models)
        obj.models{ii} = removeObservations(obj.models{ii},numPer);
    end
    
end

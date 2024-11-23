function temp = setDataOfModels(temp,data)
% Syntax:
%
% temp = nb_setDataOfModels(temp,data)
%
% Description:
%
% Sets the data property of the models and combinator model in the template.
% 
% Input:
% 
% - temp : A nb_synthesizer template.
%
% - data : A nb_ts object. 
% 
% Output:
% 
% - temp : The nb_synthesizer template with updated data.
%
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    % Update data of models in object
    modelsWithData = temp.models;
    for ii = 1:length(modelsWithData)
        modelsWithData(ii).data = data.window('','',modelsWithData(ii).dependent);
    end
    temp.models = modelsWithData;
    
    % Update data of combinator model
    temp.combinatorModel.data = data.window('','',temp.combinatorModel.dependent);
    
end

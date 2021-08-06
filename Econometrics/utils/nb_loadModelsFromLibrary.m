function models = nb_loadModelsFromLibrary(folder)
% Syntax:
%
% models = nb_loadModelsFromLibrary(folder)
%
% Description:
%
% Load models from library folder.
% 
% Input:
% 
% - folder : A full absolute path to the model library.
% 
% Output:
% 
% - models : A vector of nb_model_update_vintages.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    modelList = nb_getModelListFromLibrary(folder);
    
    models(1,length(modelList)) = nb_model_vintages();
    for ii = 1:length(modelList)
        try
            models(ii) = nb_load(modelList{ii});
        catch Err
            nb_error(['Could not load ' modelList{ii}],Err)
        end
    end
    
end

function obj = loadModelsFromPath(pathName)
% Syntax:
%
% obj = nb_model_group.loadModelsFromPath(pathName)
%
% Description:
%
% Load models saved to seperate .mat files stored in a folder to a model 
% group object. The models must be stored as nb_model_generic or
% nb_model_group objects.
% 
% Input:
% 
% - pathName : Full path name of the folder the model files are stored.
%              As a string.
% 
% Output:
% 
% - obj      : An object of class nb_model_group
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    w        = what(pathName);
    matFiles = w.mat;
    matFiles = strcat(pathName,filesep(),matFiles);
    numFiles = length(matFiles);
    models   = cell(1,numFiles);
    for ii = 1:numFiles
        
        try
            models{ii} = nb_load(matFiles{ii});
        catch
            error([mfilename ':: The file ' matFiles{ii} ' cannot be loaded.'])
        end
        if not(isa(models{ii},'nb_model_generic') || isa(models{ii},'nb_model_group'))
            error([mfilename ':: The file ' matFiles{ii} ' does not contain a nb_model_generic or nb_model_group object.'])
        end
        
    end
    obj = nb_model_group(models);   

end

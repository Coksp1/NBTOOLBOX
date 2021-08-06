function storeModelsToPath(obj,pathName)
% Syntax:
%
% storeModelsToPath(obj,pathName)
%
% Description:
%
% Save the different models of the nb_model_group object to seperate
% .mat files to a given folder.
% 
% Input:
% 
% - obj      : An object of class nb_model_group
%
% - pathName : Full path name of the folder the model files should be 
%              stored. As a string. Must be ended with a '\'.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    pathName = fileparts(pathName);
    if isempty(pathName)
        error([mfilename ':: The input given to pathName is not a path.'])
    elseif isempty(strfind(pathName,':\'))
        error([mfilename ':: The input given to pathName is not a path.'])
    end
    
    if ~exist(pathName,'dir') 
        mkdir(pathName)
    end
    
    names = nb_getModelNames(obj.models{:});
    names = strcat(pathName,filesep(),names);
    for ii = 1:length(obj.models)
        storedObj = obj.models{ii}; %#ok<NASGU>
        save(names{ii},'storedObj');
    end

end

function modelList = nb_getModelListFromLibrary(folder)
% Syntax:
%
% modelList = nb_getModelListFromLibrary(folder)
%
% Description:
%
% Get model list from library folder.
% 
% Input:
% 
% - folder : A full absolute path to the model library.
% 
% Output:
% 
% - modelList : A list of all models stores as .mat files.
%
% Written by Erlend Salvesen Njølstad

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    modelList = dir(fullfile(folder,'*.mat'));
    modelList = join({modelList.folder;modelList.name}','/');
    
end

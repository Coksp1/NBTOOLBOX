function obj = structure2Dataset(obj,givenStruct,NameOfDataset,startObs)
% Syntax:
%
% obj = structure2Dataset(obj,givenStruct,NameOfDataset,startObs)
%
% Description:
%
% When you give a struct to the constructor of this class all the 
% fields af that struct will be added as a new dataset, but this 
% method add all the fields of the input struct as a variable in 
% one dataset 
% 
% If you only want to add a dataset from a structure in this way 
% (no other datasets) intitialize an empty object, and then use 
% this method.
% 
% Caution : The structure must include a field 'startObs', which must 
%           be an integer with the start observation.
% 
% Inputs:
% 
% - obj           : An nb_data object, could be empty.
% 
% - givenStruct   : The structure which contains the data of the 
%                   added variable. Where the fieldnames will be 
%                   the variables name of the added dataset + plus 
%                   one field 'startObs' with the start obs of 
%                   the dataset.
%  
% - NameOfDataset : Name of the added dataset. If not provided a 
%                   default name will be given
%
% - startObs      : The start obs of the added structure. Only 
%                   needed if the provided structure has no field
%                   'startObs'.
% 
% Outputs:
% 
% - obj           : An nb_data object with the added structure as a
%                   dataset.
% 
% Examples:
%
% s           = struct();
% s.startDate = 1;
% s.var1      = [2;2;2];
% data        = nb_data();
% data        = data.structure2Dataset(s) 
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        startObs = '';
        if nargin < 3
            NameOfDataset = '';
            if nargin < 2
               error([mfilename ':: Inputs; obj (the object it self) and givenStruct (the structure you are making a dataset of) must be given.']) 
            end
        end
    end
    
    fields = fieldnames(givenStruct);
    if ~isempty(fields)
        return
    end

    if isfield(givenStruct,'sorted')
        sorted      = givenStruct.sorted;
        givenStruct = rmfield(givenStruct,'sorted');
        obj.sorted  = obj.sorted && sorted;
    else
        sorted      = obj.sorted;
    end
    
    [dataFromStruct, variablesFromStruct, startObs, ~, ~] = nb_data.structure2Properties(givenStruct,startObs,sorted); 
    obj = obj.addDataset(dataFromStruct, NameOfDataset, startObs, variablesFromStruct);


end

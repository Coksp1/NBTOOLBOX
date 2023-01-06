function obj = structure2Dataset(obj,givenStruct,NameOfDataset)
% Syntax:
%
% obj = structure2Dataset(obj,givenStruct,NameOfDataset)
%
% Description:
%
% When you give a struct to the constructor of this class all the 
% fields af that struct will be added as a new dataset, but this 
% method add all the fields of the input givenStruct as a variable 
% in one dataset 
% 
% If you only want to add a dataset from a structure in this way 
% (no other datasets) initialize a empty object, and then use this
% method.
% 
% Caution : The structure must include a field 'types', which must 
%           be a cellstr with the added types of the nb_cs object. 
%           This cellstr must have the same number length as the 
%           length of the data of the other field 
% 
% Inputs:
% 
% - obj           : The object itself, could be empty.
% 
% - givenStruct   : The structure which contains the data of the 
%                   added variable. Where the fieldnames will be 
%                   the variables name of the added dataset + plus 
%                   one field 'types' with the data types of the 
%                   dataset.
% 
% - NameOfDataset : Name of the added dataset. If not provided
%                   default name will be used, i.e Database<jj>
% 
% Outputs:
% 
% - obj           : An nb_cs object with the added dataset.
% 
% Examples:
%
% s       = struct();
% s.types = {'First'};
% s.var1  = 2;
% obj     = nb_cs;
% obj     = obj.structure2Dataset(s)
% 
% obj = 
% 
%     'Types'    'var1'
%     'First'    [   2]
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        NameOfDataset = '';
        if nargin < 2
           error([mfilename ':: Inputs; ''obj'' (the object it self) and ''givenStruct'' (the structure you are making a dataset of) must be given.']) 
        end
    end

    fields = fieldnames(givenStruct);
    if isempty(fields)
        error([mfilename ':: The structure is empty and it is not possible to add a empty struct.'])
    end

    if isfield(givenStruct,'sorted')
        sorted      = givenStruct.sorted;
        givenStruct = rmfield(givenStruct,'sorted');
        obj.sorted  = obj.sorted && sorted;
    else
        sorted      = obj.sorted;
    end
    
    [dataFromStruct, variablesFromStruct, typesFromStruct] = nb_cs.structure2Properties(givenStruct,sorted); 
    obj = obj.addDataset(dataFromStruct, NameOfDataset, typesFromStruct, variablesFromStruct);

end

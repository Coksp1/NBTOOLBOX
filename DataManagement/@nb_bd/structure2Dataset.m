function obj = structure2Dataset(obj,givenStruct,nameOfDataset,startDate)
% Syntax:
%
% obj = structure2Dataset(obj,givenStruct,NameOfDataset)
%
% Description:
%
% When you give a struct to the constructor of this class all the 
% fields of that struct will be added as a new dataset, but this 
% method add all the fields of the input givenStruct as a variable 
% in one dataset 
% 
% If you only want to add a dataset from a structure in this way 
% (no other datasets) initialize a empty object, and then use this
% method.
% 
% Caution : The structure must include a field 'startDate', which must 
%           be a string with the start date of the data to add
% 
% Inputs:
% 
% - obj           : The object itself, could be empty.
% 
% - givenStruct   : The structure which contains the data of the 
%                   added variable. Where the fieldnames will be 
%                   the variables name of the added dataset + plus 
%                   one field 'startDate' with the start date of the 
%                   dataset.
% 
% - nameOfDataset : Name of the added dataset. If not provided
%                   default name will be used, i.e Database<jj>
%
% - startDate     : The start date of the new dataset. Only needed if
%                   the structure <givenStruct> has no field 'startDate'.
% 
% Outputs:
% 
% - obj           : An nb_bd object with the added dataset.
% 
% Examples:
%
% s           = struct();
% s.startDate = '2012';
% s.Var1      = [2;2;2];
% obj         = nb_bd();
% obj         = obj.structure2Dataset(s) 
% 
% data = 
% 
%     'Time'    'var1'
%     '2012'    [   2]
%     '2013'    [   2]
%     '2014'    [   2]
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        startDate = '';
        if nargin < 3
            nameOfDataset = '';
            if nargin < 2
               error([mfilename ':: Inputs; ''obj'' (the object it self) and ''givenStruct'' (the structure you are making a dataset of) must be given.']) 
            end
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
    
    [dataFromStruct, variablesFromStruct, startDateFromStruct] = nb_bd.structure2Properties(givenStruct,startDate,sorted); 
    obj = obj.addDataset(dataFromStruct, nameOfDataset, startDateFromStruct,[],[],variablesFromStruct);

end

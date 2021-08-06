function obj = structure2Dataset(obj,givenStruct,NameOfDataset,startDate)
% Syntax:
%
% obj = structure2Dataset(obj,givenStruct,NameOfDataset,startDate)
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
% Caution : The structure must include a field 'startDate', which must 
%           be a string with the start date of the data to add.
% 
% Inputs:
% 
% - obj           : An nb_ts object, could be empty.
% 
% - givenStruct   : The structure which contains the data of the 
%                   added variable. Where the fieldnames will be 
%                   the variables name of the added dataset + plus 
%                   one field 'startDate' with the start date of 
%                   the dataset.
%  
% - NameOfDataset : Name of the added dataset. If not provided a 
%                   default name will be given
%
% - startDate     : The start date of the added structure. Only 
%                   needed if the provided structure has no field
%                   'startDate'.
% 
% Outputs:
% 
% - obj           : An nb_ts object with the added structure as a
%                   dataset.
% 
% Examples:
%
% s           = struct();
% s.startDate = '2012';
% s.var1      = [2;2;2];
% data        = nb_ts();
% data        = data.structure2Dataset(s) 
% 
% data = 
% 
%     'Time'    'var1'
%     '2012'    [   2]
%     '2013'    [   2]
%     '2014'    [   2]
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        startDate = '';
        if nargin < 3
            NameOfDataset = '';
            if nargin < 2
               error([mfilename ':: Inputs; obj (the object it self) and givenStruct (the structure you are making a dataset of) must be given.']) 
            end
        end
    end
    
    fields = fieldnames(givenStruct);
    if isempty(fields)
        return
    end
    
    if isempty(startDate)
        tested = givenStruct.(fields{1});
        if isa(tested,'nb_ts')
            startDate = tested.startDate;
        elseif isa(tested,'ts')
            startDate = tested.start;
        end
    end
    
    if isfield(givenStruct,'sorted')
        sorted      = givenStruct.sorted;
        givenStruct = rmfield(givenStruct,'sorted');
        obj.sorted  = obj.sorted && sorted;
    else
        sorted      = obj.sorted;
    end
    
    [dataFromStruct, variablesFromStruct, startDate, ~, ~] = nb_ts.structure2Properties(givenStruct,startDate,sorted); 
    obj = obj.addDataset(dataFromStruct, NameOfDataset, startDate, variablesFromStruct);

end

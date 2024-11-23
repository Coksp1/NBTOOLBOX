function obj = add(obj,dataObject,id)
% Syntax:
%
% obj = add(obj,dataObject,id)
%
% Description:
%
% Adding an object of class nb_ts or nb_cs to a nb_DataCollection
% object.
% 
% Caution : The added object can only have one page (dataset)
% 
% Input:
% 
% - obj        : An object of class nb_DataCollection
% 
% - dataObject : An nb_ts or nb_cs object with only on page
%                (dataset).
% 
% - id         : A string with the identifier of the provided 
%                object.
% 
% Output:
% 
% - obj        : An object of class nb_DataCollection with the 
%                added data object.
% 
% Examples:
%
% obj        = nb_DataCollection();
% dataObject = nb_ts([2,2],'','2012Q1','Var1');
% obj        = obj.add(dataObject,'Dataset1');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(dataObject,'nb_ts') || isa(dataObject,'nb_cs') || isa(dataObject,'nb_data')

        if dataObject.numberOfDatasets > 1
            error([mfilename ':: The added nb_data, nb_ts or nb_cs object can only have on page (dataset).'])
        end

        obj.list = obj.list.add(dataObject,id);

    else
        error([mfilename ':: The added object must be a nb_ts or a nb_cs object.'])
    end

    obj.objectsID = obj.list.ids;

end

function obj = reset(obj,dataObject,id)
% Syntax:
%
% obj = reset(obj,dataObject,id)
%
% Description:
%
% Resetting an object of class nb_ts or nb_cs of an 
% nb_DataCollection object.
% 
% Caution : The reset object can only have one page (dataset)
% 
% Input:
% 
% - obj        : An object of class nb_DataCollection
% 
% - dataObject : An nb_ts or nb_cs object with only on page
%                (dataset).
% 
% - id         : A string with the identifier of the reset 
%                object.
% 
% Output:
% 
% - obj        : An object of class nb_DataCollection with the 
%                reset data object.
% 
% Examples:
%
% obj        = obj.reset(dataObject,'Dataset1');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(dataObject,'nb_ts') || isa(dataObject,'nb_cs') || isa(dataObject,'nb_data')

        if dataObject.numberOfDatasets > 1
            error([mfilename ':: The added nb_data, nb_ts or nb_cs object can only have on page (dataset).'])
        end

        obj.list = obj.list.reset(dataObject,id);

    else
        error([mfilename ':: The added object must be a nb_ts, nb_cs or nb_data object.'])
    end

end

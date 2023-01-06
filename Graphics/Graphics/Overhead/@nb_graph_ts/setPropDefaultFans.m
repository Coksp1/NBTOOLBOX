function setPropDefaultFans(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropBarDefaultFans(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the defaultFans property of the nb_graph_ts class. This method 
% is used by the set method of nb_graph to set defaultFans and do 
% additional housekeeping.
%
% See documentation NB Toolbox or type help('nb_graph_ts') for more
% on the properties of the class.
% 
% Input:
% 
% - obj           : An object of class nb_graph_ts. 
% 
% - propertyName  : n x 1 char. Propertyname to set. (Should be 
%                   'defaultFans' for expected behavior). 
%
% - propertyValue : Value to set the defaultFans property to.
%
% Output:
%
% No actual output, but the input object defaultFans property will have 
% been set to the new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    oldValue           = obj.(propertyName);
    obj.(propertyName) = propertyValue;
    if obj.DB.frequency == 4
        try
            obj.(propertyName);
        catch %#ok<CTCH>
            obj.(propertyName) = oldValue;
            error([mfilename ':: The input after ''defaultFans'' must be a string or a nb_date object with the date of the first forecasting period.']);
        end
    else
        error([mfilename ':: Cannot add default fans for the variables QSA_GAPNB_Y, QSA_GAP_Y, QUA_DPY_PCPIXE, QUA_DPY_PCPIXE_R, QUA_RNFOLIO, '...
                         'when the frequency of the data is not ''quarterly'' (4).'])
    end

end

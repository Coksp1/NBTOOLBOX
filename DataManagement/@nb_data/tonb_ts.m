function nb_ts_DB = tonb_ts(obj,startDate)
% Syntax:
%
% nb_ts_DB = tonb_ts(obj,startDate)
%
% Description:
%
% Transform from a nb_data object to a nb_ts object
% 
% Input: 
% 
% - obj        : An object of class nb_data
%
% - startDate  : Sets the start date of the nb_ts object. If empty or
%                not given it is default to use startObs as the start date.
%   
% Output:
% 
% - nb_ts_DB : An object of class nb_ts
%               
% Examples:
% 
% nb_ts_DB = obj.tonb_ts();
% 
% Written by Kenneth S. Paulsen      

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        startDate = '';
    end
    
    if isempty(startDate)
        startDate = int2str(obj.startObs);
    end
    
    nb_ts_DB = nb_ts(obj.data,'',startDate,obj.variables,obj.sorted);
    nb_ts_DB.localVariables = obj.localVariables;
    
    if obj.isUpdateable()
        
        obj      = obj.addOperation(@tonb_ts,{startDate});
        links    = obj.links;
        nb_ts_DB = nb_ts_DB.setLinks(links);
        
    end

end

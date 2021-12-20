function nb_cs_DB = tonb_cs(obj,dateFormat,strip)
% Syntax:
%
% nb_cs_DB = tonb_cs(obj,dateFormat)
%
% Description:
%
% Transform from an nb_ts object to an nb_cs object
% 
% Input: 
% 
% - obj        : An object of class nb_ts
%
% - dateFormat : The date format of the dates of the return nb_cs 
%                object.
%
%                > 'default' (default)
%                > 'fame'
%                > 'NBEnglish' or 'NBEngelsk'
%                > 'NBNorsk' or 'NBNorwegian'
%                > 'xls'
%
% - strip      : - 'on'  : Strip all observation dates where all 
%                          the variables has no value. 
% 
%                - 'off' : Does not strip all observation dates 
%                          where all the variables has no value. 
%                          Default. 
%   
% Output:
% 
% - nb_cs_DB : An object of class nb_cs
%               
% Examples:
% 
% nb_cs_DB = obj.tonb_cs();
% 
% Written by Kenneth S. Paulsen      

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        strip = 'off';
        if nargin < 2
            dateFormat = 'default';
        end
    end
    
    if strcmpi(strip,'on')
                   
        d        = obj.data;
        ind      = all(all(isnan(d),2),3);
        d        = d(~ind,:,:);
        dates    = obj.startDate.toDates(0:obj.numberOfObservations - 1,dateFormat,obj.frequency);
        dates    = dates(~ind,1);
        nb_cs_DB = nb_cs(d,'',dates',obj.variables,obj.sorted);

    else
        
        dates    = obj.startDate.toDates(0:obj.numberOfObservations - 1,dateFormat,obj.frequency);
        nb_cs_DB = nb_cs(obj.data,'',dates',obj.variables,obj.sorted);
        
    end
    
    nb_cs_DB.localVariables = obj.localVariables;
    if obj.isUpdateable()
        obj      = obj.addOperation(@tonb_cs,{dateFormat,strip});
        links    = obj.links;
        nb_cs_DB = nb_cs_DB.setLinks(links);
    end

end

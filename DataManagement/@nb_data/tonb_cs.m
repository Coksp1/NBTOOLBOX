function nb_cs_DB = tonb_cs(obj,strip)
% Syntax:
%
% nb_cs_DB = tonb_cs(obj)
%
% Description:
%
% Transform from a nb_data object to a nb_cs object
% 
% Input: 
% 
% - obj        : An object of class nb_data
%
% - strip      : - 'on'  : Strip all observations where all 
%                          the variables has no value. 
% 
%                - 'off' : Does not strip all observations 
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        strip = 'off';
    end
    
    if strcmpi(strip,'on')
                   
        d        = obj.data;
        ind      = all(all(isnan(d),2),3);
        d        = d(~ind,:,:);
        obs      = observations(obj,'cellstr');
        obs      = obs(~ind,1);
        nb_cs_DB = nb_cs(d,'',obs',obj.variables,obj.sorted);

    else
        
        obs      = observations(obj,'cellstr');
        nb_cs_DB = nb_cs(obj.data,'',obs',obj.variables,obj.sorted);
        
    end
    
    if obj.isUpdateable()
        
        obj      = obj.addOperation(@tonb_cs,{strip});
        links    = obj.links;
        nb_cs_DB = nb_cs_DB.setLinks(links);
        
    end

end

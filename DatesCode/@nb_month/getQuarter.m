function quarter = getQuarter(obj)
% Syntax:
% 
% quarter = getQuarter(obj,first)
%
% Description:
%   
% Get the current quarter of the month, given as an nb_quarter 
% object
% 
% Input:
% 
% - obj     : An object of class nb_mont
% 
% Output:
% 
% - quarter : An nb_quarter object
% 
% Examples:
%
% quarter = obj.getQuarter();  
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if numel(obj) > 1
        siz           = size(obj);
        obj           = obj(:);
        s             = prod(siz);
        quarter(1,s)  = nb_quarter;
        for ii = 1:s  
            quarter(ii) = getQuarter(obj(ii));
        end
        quarter = reshape(quarter,siz);
        return
    end

    quarter           = nb_quarter(obj.quarter,obj.year);
    quarter.dayOfWeek = obj.dayOfWeek;

end
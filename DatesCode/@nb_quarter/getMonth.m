function month = getMonth(obj,first)
% Syntax:
% 
% month = getMonth(obj,first)
%
% Description:
%   
% Get the first or last month of the quarter, given as a nb_month 
% object
% 
% Input:
% 
% - obj     : An object of class nb_quarter
% 
% - first   : 1 : first month
%             0 : last month
% 
% Output:
% 
% - month   : An nb_month object
% 
% Examples:
%
% month = obj.getMonth();   % Will return the first month
% month = obj.getMonth(0);  % Will return the last month
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        first = 1;
    end
    
    if numel(obj) > 1
        siz         = size(obj);
        obj         = obj(:);
        s           = prod(siz);
        month(1,s)  = nb_month;
        for ii = 1:s  
            month(ii) = getMonth(obj(ii),first);
        end
        month = reshape(month,siz);
        return
    end

    if first
        month = nb_month(1 + 3*(obj.quarter - 1),obj.year);
    else
        month = nb_month(3*obj.quarter,obj.year);
    end
    month.dayOfWeek = obj.dayOfWeek;
            
end

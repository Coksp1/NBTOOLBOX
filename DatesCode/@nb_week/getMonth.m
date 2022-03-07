function month = getMonth(obj)
% Syntax:
% 
% month = getMonth(obj)
%
% Description:
%   
% Get the month of the week, given as a nb_month object
% 
% Input:
% 
% - obj     : An object of class nb_week
% 
% Output:
% 
% - month   : An nb_month object
% 
% Examples:
%
% month = obj.getMonth();   % Will return the month
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        siz         = size(obj);
        obj         = obj(:);
        s           = prod(siz);
        month(1,s)  = nb_month;
        for ii = 1:s  
            month(ii) = getMonth(obj(ii));
        end
        month = reshape(month,siz);
        return
    end

    day             = getDay(obj,2);
    month           = getMonth(day);
    month.dayOfWeek = obj.dayOfWeek;

end

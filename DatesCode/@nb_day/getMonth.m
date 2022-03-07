function month = getMonth(obj)
% Syntax:
% 
% month = getMonth(obj)
%
% Description:
%   
% Get the month of the day, given as a nb_month object
% 
% Input:
% 
% - obj     : An object of class nb_day
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

    month           = nb_month(obj.month,obj.year);
    month.dayOfWeek = obj.dayOfWeek;

end

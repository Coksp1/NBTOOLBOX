function quarter = getQuarter(obj)
% Syntax:
% 
% quarter = getQuarter(obj)
%
% Description:
%   
% Get the quarter of the day, given as a nb_quarter object
% 
% Input:
% 
% - obj     : An object of class nb_day
% 
% Output:
% 
% - quarter : An nb_quarter object
% 
% Examples:
%
% quarter = obj.getQuarter();  % Will return the current quarter
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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

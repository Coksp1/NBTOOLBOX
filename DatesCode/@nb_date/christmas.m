function day = christmas(obj,~)
% Syntax:
%
% day = christmas(obj,~)
%
% Description:
%
% Give the holidays of christmas (25th and 26th) of the year the date is
% located.
% 
% Input:
% 
% - obj  : An object of class nb_date.
%
% Output:
% 
% - days : All the holidays as a vector of nb_day objects.
%
% See also:
% nb_easter, nb_date.ascensionDay, nb_date.pentecost, nb_date.easter
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function only handle a scalar nb_date object.'])
    end
    
    if ~isa(obj,'nb_year')
        obj = getYear(obj);
    end
    day(1,2) = nb_day(26,12,obj.year);
    day(1,1) = nb_day(25,12,obj.year);

end

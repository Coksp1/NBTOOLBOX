function day = pentecost(obj,~)
% Syntax:
%
% day = pentecost(obj,~)
%
% Description:
%
% Give the pentecost (monday) of the year the date is located.
% 
% Input:
% 
% - obj  : An object of class nb_date.
% 
% Output:
% 
% - days : The holiday as a nb_day object.
%
% See also:
% nb_easter, nb_date.easter, nb_date.ascensionDay
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function only handle a scalar nb_date object.'])
    end

    if ~isa(obj,'nb_year')
        obj = getYear(obj);
    end
    easter = nb_easter(obj.year);
    day    = nb_day(easter{1});
    day    = day + (7*7 + 1);

end

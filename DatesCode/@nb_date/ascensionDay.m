function day = ascensionDay(obj,~)
% Syntax:
%
% day = ascensionDay(obj,~)
%
% Description:
%
% Give the ascension day of the year the date is located.
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
% nb_easter, nb_date.easter, nb_date.pentecost
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
    day    = day + (6*7 - 3);

end

function year = getYear(obj)
% Syntax:
% 
% year = getYear(obj)
%
% Description:
%   
% Get the year of the day, given as a nb_year object
% 
% Input:
% 
% - obj     : An object of class nb_day
% 
% Output:
% 
% - year    : A nb_Year object
% 
% Examples:
%
% day  = nb_day(1,1,2020);
% year = day.getYear();  % Will return the current year
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    siz       = size(obj);
    s         = prod(siz);
    year(1,s) = nb_year;
    for ii = 1:s
        year(ii)           = nb_year(obj(ii).year);
        year(ii).dayOfWeek = obj(ii).dayOfWeek;
    end
    year = reshape(year,siz);

end

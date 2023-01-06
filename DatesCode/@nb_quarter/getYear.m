function year = getYear(obj)
% Syntax:
% 
% year = getYear(obj)
%
% Description:
%   
% Get the year of the quarter, given as a nb_year object
% 
% Input:
% 
% - obj     : An object of class nb_quarter
% 
% Output:
% 
% - year    : A nb_year object
% 
% Examples:
%
% quarter = nb_quarter(1,2020);
% year    = quarter.getYear();  % Will return the current year
% 
% Written by Kenneth S. Paulsen
            
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

	siz       = size(obj);
    s         = prod(siz);
    year(1,s) = nb_year;
    for ii = 1:s
        year(ii)           = nb_year(obj(ii).year);
        year(ii).dayOfWeek = obj(ii).dayOfWeek;
    end
    year = reshape(year,siz);
            
end

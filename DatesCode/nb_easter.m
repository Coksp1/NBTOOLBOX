function easter = nb_easter(years)
% Syntax:
%
% easter = nb_easter(years)
%
% Description:
%
% A function to identify the date of easter for a given year. Utilizes
% Gauss' Easter Algorithm. 
% https://en.wikipedia.org/wiki/Computus#Gauss's_Easter_algorithm
% 
% Input:
% 
% - years : A double vector of years
% 
% Output:
% 
% - easter : A cellstring with the dates of easter corresponding to each 
%            year
%
% Examples:
% years = 1950:2050;
% easter = nb_easter(years)
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if size(years,2)>1
        years = years';
    end
    try
        init = datetime([repmat('03/01/',length(years),1),int2str(years)],...
            'InputFormat','MM/dd/yyyy');
    catch
        init = datenum([repmat('03/01/',length(years),1),int2str(years)]);
    end

    A1      = 24;
    A2      = 5;
    A3      = mod(years,19);
    A4      = mod(years,4);
    A5      = mod(years,7);
    A6      = mod(19*A3+A1,30);
    A7      = mod(2*A4+4*A5+6*A6+A2,7);
    A8      = 22+A6+A7;
    ind     = A8 == 57 | (A8==56 & A7==6 & A3>10);
    A8(ind) = A8(ind)-7;

    try
        easter = cellstr(char(init + caldays(A8-1),'dd.MM.yyyy'));
    catch
        easter = cellstr(datestr(init+A8-1,'dd.mm.yyyy'));
    end

end

function year = getYear(obj)
% Syntax:
%
% year = getYear(obj)
%
% Description:
%
% Get the year of the half year, given as a nb_year object
%        
% Input:
%         
% - obj  : An object of class nb_semiAnnual
%
% Output:
%        
% - year : A object of class nb_year 
%
% Examples:
%
% sAnnual = nb_semiAnnual(1,2020);
% year    = sAnnual.getYear();
% 
% Written by Kenneth S. Paulsen
         
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    siz       = size(obj);
    s         = prod(siz);
    year(1,s) = nb_year;
    for ii = 1:s
        year(ii)           = nb_year(obj(ii).year);
        year(ii).dayOfWeek = obj(ii).dayOfWeek;
    end
    year = reshape(year,siz);
            
end

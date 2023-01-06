function day = easter(obj,type)
% Syntax:
%
% day = easter(obj,type)
%
% Description:
%
% Give the holidays or the sunday of easter of the year the date is 
% located.
% 
% Input:
% 
% - obj  : An object of class nb_date.
%
% - type : 'all' or 'sunday' (default).
% 
% Output:
% 
% - days : All the holidays as a vector of nb_day objects.
%
% See also:
% nb_easter, nb_date.ascensionDay, nb_date.pentecost
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = 'sunday';
    end 

    if numel(obj) > 1
        error([mfilename ':: This function only handle a scalar nb_date object.'])
    end
    
    if ~isa(obj,'nb_year')
        obj = getYear(obj);
    end
    easter = nb_easter(obj.year);
    day    = nb_day(easter{1});
    if strcmpi(type,'all')
        day = day + [-3,-2,0,1];       
    end

end

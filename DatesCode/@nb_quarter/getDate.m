function date = getDate(obj,freq)
% Syntax:
% 
% date = getDate(obj,freq)
%
% Description:
%
% Get the date of the object at another frequency. If the frequency
% is higher the first period is returned
%        
% Input:
%         
% - obj  : An object of class nb_quarter
%
% - freq : The frequency you want to convert to. 
%
%          - 1   : nb_year
%          - 2   : nb_semiAnnual
%          - 4   : nb_quarter
%          - 12  : nb_month
%          - 52  : nb_week
%          - 365 : nb_day
%
% Output:
%        
% - date : The date of the object at the new frequency. As an 
%          object which is a subclass of the nb_date class.
%
% Examples:
%
% date = obj.getDate(2); % Will return a nb_semiAnnual object
% 
% See also:
% nb_quarter.convert
%
% Written by Kenneth S. Paulsen
         
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: The getDate method is only supported for scalar ' class(obj) ' objects.'])
    end

    switch freq
        case 1
            date = obj.getYear();
        case 2
            date = obj.getHalfYear();
        case 4
            date = obj;
        case 12
            date = obj.getMonth();
        case 52
            date = obj.getWeek();
        case 365
            date = obj.getDay();
        otherwise
            error([mfilename ':: Unsupported frequency ' int2str(freq)])
    end
                    
end

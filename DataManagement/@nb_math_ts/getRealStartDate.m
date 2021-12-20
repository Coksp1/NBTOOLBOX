function realStartDate = getRealStartDate(obj,format)
% Syntax:
%
% realStartDate = getRealStartDate(obj,format)
%
% Description:
%
% Get the real start date of the nb_math_ts object. I.e the first 
% observation which is not nan or infinite. 
% 
% Input:
% 
% - obj           : An object of class nb_math_ts
% 
% - format        : The date format returned.
%
%                   Return a string:                   
%                   > 'xls'                        
%                   > 'pprnorsk' or 'mprnorwegian' 
%                   > 'pprengelsk' or 'mprenglish' 
%                   > 'default' (otherwise) 
%
%                   Return a date object which is of a subclass of 
%                   the nb_date class:
%                   > 'nb_date' 
%
% Output:
% 
% - realStartDate : The first observation of the object which is 
%                   not nan or infinite. As a string
%
% Examples:
%
% realEndDate = obj.getRealStartDate();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        format = 'default';
    end

    isFinite = isfinite(obj.data);
    isFinite = any(any(isFinite,2),3);
    first    = find(isFinite,1);

    realStartDate = obj.startDate + first - 1;
    if ~strcmpi(format,'nb_date')
        realStartDate = toString(realStartDate, format);
    end

end

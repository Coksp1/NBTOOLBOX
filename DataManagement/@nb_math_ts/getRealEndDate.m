function realEndDate = getRealEndDate(obj,format,type)
% Syntax:
%
% realEndDate = getRealEndDate(obj)
% realEndDate = getRealEndDate(obj,format,type)
%
% Description:
%
% Get the real end date of the nb_math_ts object. I.e the last 
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
% - type          : Either 'any' (default) or 'all'.
%
% Output:
% 
% - realEndData   : The last observation of the object which is not 
%                   nan or infinite. As a string
%
% Examples:
%
% realEndDate = obj.getRealEndDate();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'any';
        if nargin < 2
            format = 'default';
        end
    end

    isFinite = isfinite(obj.data);
    if strcmpi(type,'all')
        isFinite = all(all(isFinite,2),3);
    else
        isFinite = any(any(isFinite,2),3);
    end
    first       = find(isFinite,1,'last');
    realEndDate = obj.startDate + first - 1;
    if ~strcmpi(format,'nb_date')
        realEndDate = realEndDate.toString(format);
    end

end

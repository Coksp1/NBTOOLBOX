function realEndDate = getRealEndDate(obj,format)
% Syntax:
%
% realEndDate = getRealEndDate(obj,format)
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        format = 'default';
    end

    isFinite = isfinite(obj.data);
    isFinite = any(any(isFinite,2),3);
    first    = find(isFinite,1,'last');

    realEndDate = obj.startDate + first - 1;
    if ~strcmpi(format,'nb_date')
        realEndDate = realEndDate.toString(format);
    end

end

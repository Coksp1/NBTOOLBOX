function realEndDate = getRealEndDate(obj,format,type,variables)
% Syntax:
%
% realEndDate = getRealEndDate(obj)
% realEndDate = getRealEndDate(obj,format,type)
% realEndDate = getRealEndDate(obj,format,type,variables)
%
% Description:
%
% Get the real end date of the nb_ts object. I.e the last 
% observation which is not nan or infinite. 
% 
% Input:
% 
% - obj           : An object of class nb_ts
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
% - variables     : A cellstr of the variables to check.
% 
% Output:
% 
% - realEndData   : The last observation of the object which is not 
%                   nan or infinite. As a string
%
% Examples:
%
% realEndDate = obj.getRealEndDate();
% realEndDate = obj.getRealEndDate('pprnorsk');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        variables = {};
        if nargin < 3
            type = 'any';
            if nargin < 2
                format = 'default';
            end
        end
    end
    
    if isempty(variables)
        indV = true(size(obj.variables));
    else
        if ischar(variables)
            variables = cellstr(variables);
        end
        indV = ismember(obj.variables,variables);
    end

    isFinite = isfinite(obj.data(:,indV,:));
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

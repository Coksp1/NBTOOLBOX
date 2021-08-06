function realStartDate = getRealStartDate(obj,format,type,variables)
% Syntax:
%
% realStartDate = getRealStartDate(obj)
% realStartDate = getRealStartDate(obj,format,type,variables)
%
% Description:
%
% Get the real start date of the nb_bd object. I.e the first 
% observation which is not nan or infinite. 
% 
% Input:
% 
% - obj           : An object of class nb_bd
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
% - realStartDate : The first observation of the object which is 
%                   not nan or infinite. As a string
%
% Examples:
%
% realStartDate = obj.getRealStartDate();
% realStartDate = obj.getRealStartDate('pprnorsk');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
        variables = obj.variables;
    end
    if ischar(variables)
        variables = cellstr(variables);
    end
    indV     = ismember(obj.variables,variables);
    dataT    = double(obj);
    isFinite = isfinite(dataT(:,indV,:));
    if strcmpi(type,'all')
        isFinite = all(all(isFinite,2),3);
    else
        isFinite = any(any(isFinite,2),3);
    end
    first         = find(isFinite,1);
    realStartDate = obj.startDate + (first - 1);

    if ~strcmpi(format,'nb_date')
        realStartDate = realStartDate.toString(format);
    end

end

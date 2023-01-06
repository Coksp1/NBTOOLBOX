function realEndDate = getRealEndDateVariables(obj,format,type,pages)
% Syntax:
%
% realEndDate = getRealEndDateVariables(obj)
% realEndDate = getRealEndDateVariables(obj,format)
% realEndDate = getRealEndDateVariables(obj,format,type,pages)
%
% Description:
%
% Get the real end date of each variable of the nb_ts object. I.e the last 
% observation which is not nan or infinite for each variable. 
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
% - pages         : A double array with whole numbers with the pages to
%                   check.
%
% Output:
% 
% - realEndDates  : The last observation of the object which is not 
%                   nan or infinite for each variable. Either a cellstr 
%                   or a vecor of objects which is of a subclass of the 
%                   nb_date class.
%
% Examples:
%
% realEndDates = obj.getRealEndDateVariables();
% realEndDates = obj.getRealEndDateVariables('nb_date');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        pages = [];
        if nargin < 3
            type = 'any';
            if nargin < 2
                format = 'default';
            end
        end
    end
    
    if isempty(pages)
        pages = 1:obj.numberOfDatasets;
    else
        pages = nb_rowVector(pages);
    end
    
    func                 = str2func(class(obj.startDate));
    nVars                = obj.numberOfVariables;
    realEndDate(1,nVars) = func(); 
    for ii = 1:nVars
        isFinite = isfinite(obj.data(:,ii,pages));
        if strcmpi(type,'all')
            isFinite = all(isFinite,3);
        else
            isFinite = any(isFinite,3);
        end    
        first           = find(isFinite,1,'last');   
        realEndDate(ii) = obj.startDate + first - 1;
    end
    if ~strcmpi(format,'nb_date')
        realEndDate = realEndDate.toString(format);
    end

end

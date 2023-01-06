function realStartDate = getRealStartDateVariables(obj,format,type,pages)
% Syntax:
%
% realEndDate = getRealStartDateVariables(obj)
% realEndDate = getRealStartDateVariables(obj,format)
% realEndDate = getRealStartDateVariables(obj,format,type,pages)
%
% Description:
%
% Get the real start date of each variable of the nb_ts object. I.e the 
% first observation which is not nan or infinite for each variable. 
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
% - realStartDates : The first observation of the object which is not 
%                    nan or infinite for each variable. Either a cellstr 
%                    or a vecor of objects which is of a subclass of the 
%                    nb_date class.
%
% Examples:
%
% realEndDates = obj.getRealStartDateVariables();
% realEndDates = obj.getRealStartDateVariables('nb_date');
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
    realStartDate(1,nVars) = func(); 
    for ii = 1:nVars
        isFinite = isfinite(obj.data(:,ii,pages));
        if strcmpi(type,'all')
            isFinite = all(isFinite,3);
        else
            isFinite = any(isFinite,3);
        end    
        first             = find(isFinite,1);   
        realStartDate(ii) = obj.startDate + first - 1;
    end
    if ~strcmpi(format,'nb_date')
        realStartDate = realStartDate.toString(format);
    end

end

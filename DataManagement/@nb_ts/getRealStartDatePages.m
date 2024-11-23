function realStartDate = getRealStartDatePages(obj,format,type,variables,pages)
% Syntax:
%
% realEndDate = getRealStartDatePages(obj)
% realEndDate = getRealStartDatePages(obj,format,type)
% realEndDate = getRealStartDatePages(obj,format,type,variable,pages)
%
% Description:
%
% Get the real end date of each page of the nb_ts object. I.e the last 
% observation which is not nan or infinite for each page. 
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
% - pages         : A double array with whole numbers with the pages to
%                   check.
%
% Output:
% 
% - realEndDate   : The first observation of the object which is not 
%                   nan or infinite for each page. Either a cellstr or a
%                   vecor of objects which is of a subclass of the nb_date
%                   class.
%
% Examples:
%
% realEndDate = obj.getRealStartDatePages();
% realEndDate = obj.getRealStartDatePages('pprnorsk');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        pages = [];
        if nargin < 4
            variables = {};
            if nargin < 3
                type = 'any';
                if nargin < 2
                    format = 'default';
                end
            end
        end
    end
    
    if isempty(pages)
        pages = 1:obj.numberOfDatasets;
    else
        pages = nb_rowVector(pages);
    end
    
    if isempty(variables)
        indV = true(size(obj.variables));
    else
        if ischar(variables)
            variables = cellstr(variables);
        end
        indV = ismember(obj.variables,variables);
    end

    func                    = str2func(class(obj.startDate));
    nPages                  = size(pages,2);
    realStartDate(1,nPages) = func(); 
    isFinite                = isfinite(obj.data(:,indV,pages));
    if strcmpi(type,'all')
        isFinite = all(isFinite,2);
    else
        isFinite = any(isFinite,2);
    end
    for ii = 1:nPages     
        first             = find(isFinite(:,:,ii),1);   
        realStartDate(ii) = obj.startDate + first - 1;
    end
    if ~strcmpi(format,'nb_date')
        realStartDate = realStartDate.toString(format);
    end

end

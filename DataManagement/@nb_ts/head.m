function head(obj,nRows,page)
% Syntax:
%
% head(obj,nRows,page)
%
% Description:
%
% Display the first n rows of a nb_ts object.
% 
% Input:
% 
% - obj   : An nb_ts object.
%
% - nRows : An integer with the number of rows to display. Defaults to 6.
%
% - page  : An integer with what page to display. Defaults to 1.
%
% See also:
% nb_ts, window, tail
%
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3 
        page = 1;
        if nargin < 2
            nRows = 6;
        end
    end
    
    if ~nb_isScalarInteger(nRows,0)
        error([mfilename ':: nRows must be a strictly positive integer.'])
    end
    
    if ~nb_isScalarInteger(page,0)
        error([mfilename ':: page must be a strictly positive integer.'])
    end    
    
    if page > obj.numberOfDatasets
        error([mfilename ':: Cannot display page ' num2str(page) ' since the dataset only has ',...
            num2str(obj.numberOfDatasets) ' page(s).'])
    end

    stop = obj.startDate + nRows - 1;
    
    disp(' ');
    if stop > obj.endDate
        disp(window(obj,'','',{},page));
    else
        disp(window(obj,obj.startDate,stop,{},page));
    end

end

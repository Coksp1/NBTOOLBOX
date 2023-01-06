function tail(obj,nRows,page)
% Syntax:
%
% tail(obj,nRows,page)
%
% Description:
%
% Display the last n rows of a nb_cs object.
% 
% Input:
% 
% - obj   : An nb_cs object.
%
% - nRows : An integer with the number of rows to display. Defaults to 6.
%
% - page  : An integer with what page to display. Defaults to 1.
%
% See also:
% nb_cs, window, head
%
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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
    
    start = length(obj.types) - nRows + 1;
    
    disp(' ');
    if start < 1
        disp(window(obj,{},{},page));
    else
        disp(window(obj,obj.types(start:length(obj.types)),{},page));
    end

end

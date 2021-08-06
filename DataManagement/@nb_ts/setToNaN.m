function obj = setToNaN(obj,startDateWin,endDateWin,variablesWin,pages)
% Syntax:
%
% obj = setToNaN(obj,startDateWin,endDateWin,variablesWin,pages)
%
% Description:
%
% Set a window of the object to nan
% 
% Input:
% 
% - obj          : An object of class nb_ts
% 
% - startDateWin : The start date of the nan data of the
%                  object. Must be a string on the format; 
%                  'yyyyQq', 'yyyyMmm' or 'yyyy'. If empty, 
%                  i.e. '', nothing is done to the start date of 
%                  the data. 
%
%                  Can also be an object which is a subclass of
%                  the nb_date class.
% 
% - endDateWin   : The end date of the nan data of the 
%                  object. Must be a string on the format.
%                  'yyyyQq', 'yyyyMmm' or 'yyyy'. If empty, 
%                  i.e. '', nothing is done to the end date of the 
%                  data.
%
%                  Can also be an object which is a subclass of
%                  the nb_date class.
%
% - variablesWin : A cellstr array of the variables you want to 
%                  set to nan. If empty all the variables is set to nan.
% 
% - pages        : A numerical index of the pages you want to set to nan.
% 
% Output:
% 
% - obj : An nb_ts object where the wanted data is set to nan. 
%
% See also:
% nb_ts
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        pages = [];
        if nargin < 4
            variablesWin = {};
            if nargin < 3
                endDateWin = '';
                if nargin < 2
                    startDateWin = '';
                end
            end
        end
    end
    
    if isempty(obj)
        
        warning('nb_ts:EmptyObject',[mfilename ':: The object you are trying to take a window of is empty. Returning a empty object.']);
        return
        
    end

    % Interpret dates
    startDateWinT = interpretDateInput(obj,startDateWin);
    endDateWinT   = interpretDateInput(obj,endDateWin);

    % Get selected window to set to nan
    [~,~,~,startInd,endInd,variablesInd,pages] = getWindow(obj,startDateWinT,endDateWinT,variablesWin,pages);

    % Give the data properties
    obj.data(startInd:endInd, variablesInd, pages) = nan;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object. (Cannot give pages, because the links are already
        % removed)
        obj = obj.addOperation(@setToNan,{startDateWin,endDateWin,variablesWin,pages});
        
    end

end

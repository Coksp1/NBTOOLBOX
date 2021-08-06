function obj = window(obj,startDateWin,endDateWin,variablesWin,pages)
% Syntax:
%
% obj = window(obj,startDateWin,endDateWin,variablesWin,pages)
%
% Description:
%
% Narrow down window of the data of the nb_bd object
% 
% Input:
% 
% - obj          : An object of class nb_bd
% 
% - startDateWin : The new wanted start date of the data of the
%                  object. Must be a string on the format; 
%                  'yyyyQq', 'yyyyMmm' or 'yyyy'. If empty, 
%                  i.e. '', nothing is done to the start date of 
%                  the data. 
%
%                  Can also be an object which is a subclass of
%                  the nb_date class.
% 
% - endDateWin   : The new wanted end date of the data of the 
%                  object. Must be a string on the format.
%                  'yyyyQq', 'yyyyMmm' or 'yyyy'. If empty, 
%                  i.e. '', nothing is done to the end date of the 
%                  data.
%
%                  Can also be an object which is a subclass of
%                  the nb_date class.
%
% - variablesWin : A cellstr array of the variables you want to 
%                  keep of the given object. If empty all the 
%                  variables is kept.
% 
% - pages        : A numerical index of the pages you want to keep.
%                  E.g. if you want to keep the first 3 datasets
%                  (pages of the data) of the object. And the 
%                  number of datasets of the object is larger than
%                  3. You can use; 1:3. If empty all pages is kept.
% 
%                  I.e. obj = obj.window('','',{},1:3)
% 
% Output:
% 
% - obj : An nb_bd object where the datasets of the object is
%         narrowed down to the specified window.
%         
% Examples:
%
%  obj = nb_bd(ones(7,1),'','2012Q1',{'Var1'});
%  obj = obj.window('2012Q2')
%
% See also:
%
% Written by Per Bjarne Bye 

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
        warning('nb_bd:EmptyObject',[mfilename ':: The object you are trying to take a window of is empty. Returning a empty object.']);
        return
    end
    
    pagesIn = pages;
    if ischar(pages)
        if strcmpi(pages,'end')
            pages = obj.numberOfDatasets;
        end
    end
    
    % Interpret dates
    startDateWinT = interpretDateInput(obj,startDateWin);
    endDateWinT   = interpretDateInput(obj,endDateWin);

    % Get the selected window 
    % This function interprets some input and does some error checking
    [startDateWinT,endDateWinT,variablesWin,startInd,endInd,variablesInd,pages] = getWindow(obj,startDateWinT,endDateWinT,variablesWin,pages);

    % Update properties given the new window
    if sum(variablesInd)==0 || startInd > endInd% If all variables is removed

        obj = obj.empty();

    else
        % Give the data properties
        fullData = getFullRep(obj);
        fullData = fullData(startInd:endInd,variablesInd,pages);
        
        [loc,ind,dataOut,~] = nb_bd.getLocInd(fullData);
        
        obj.locations = loc;
        obj.indicator = ind;
        obj.data      = dataOut;
        obj.variables = obj.variables(variablesInd);
        obj.dataNames = obj.dataNames(pages);
        obj.startDate = startDateWinT;
        obj.endDate   = endDateWinT;
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object. (Cannot give pages, because the links are already
        % removed)
        obj = obj.addOperation(@window,{startDateWin,endDateWin,variablesWin,pagesIn});
        
    end

end

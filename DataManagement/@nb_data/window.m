function obj = window(obj,startObsWin,endObsWin,variablesWin,pages)
% Syntax:
%
% obj = window(obj,startObsWin,endObsWin,variablesWin,pages)
%
% Description:
%
% Narrow down window of the data of the nb_data object
% 
% Input:
% 
% - obj          : An object of class nb_data
% 
% - startObsWin  : The new wanted start obs of the data of the
%                  object. Must be an integer.
% 
% - endObsWin    : The new wanted end obs of the data of the 
%                  object. Must be an integer.
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
% - obj : An nb_data object where the datasets of the object is
%         narrowed down to the specified window.
%         
% Examples:
%
%  obj = nb_data(ones(10,2,2),'',1,{'Var1','Var2'});
%  obj = obj.window(2)
%  obj = obj.window('',5)
%  obj = obj.window('','',{'Var1'})
%  obj = obj.window('','',{},1)
%
% See also:
% subsref
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        pages = [];
        if nargin < 4
            variablesWin = {};
            if nargin < 3
                endObsWin = '';
                if nargin < 2
                    startObsWin = '';
                end
            end
        end
    end
    
    if isempty(obj)
        warning('nb_data:EmptyObject',[mfilename ':: The object you are trying to take a window of is empty. Returning a empty object.']);
        return
    end
    
    pagesIn = pages;
    if ischar(pages)
        if strcmpi(pages,'end')
            pages = obj.numberOfDatasets;
        end
    end

    [startObsWin,endObsWin,variablesWin,startInd,endInd,variablesInd,pages] = getWindow(obj,startObsWin,endObsWin,variablesWin,pages);

    if sum(variablesInd)==0 || startInd > endInd% If all variables is removed

        obj = obj.empty();

    else

        % Give the data properties
        obj.variables = obj.variables(variablesInd);
        obj.data      = obj.data(startInd:endInd, variablesInd, pages);
        obj.dataNames = obj.dataNames(pages);
        obj.startObs  = startObsWin;
        obj.endObs    = endObsWin;
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object. (Cannot give pages, because the links are already
        % removed)
        obj = obj.addOperation(@window,{startObsWin,endObsWin,variablesWin,pagesIn});
        
    end

end

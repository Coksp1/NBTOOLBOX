function obj = window(obj,typesWin,variablesWin,pages)
% Syntax:
%
% obj = window(obj,typesWin,variablesWin,pages)
%
% Description:
%
% Narrow down the dataset(s) of the nb_cs object
% 
% Input:
% 
% - obj          : An object of class nb_cs
% 
% - typesWin     : A cellstr array of the types you want to keep 
%                  of the given object. If empty all the types is
%                  kept.
% 
% - variablesWin : A cellstr array of the variables you want to 
%                  keep of the given object. If empty all the 
%                  variables is kept.
% 
% - pages        : A numerical index of the pages you want to keep.
%                  E.g. if you want to keep the first 3 datasets
%                  (pages of the data) of the object. And the 
%                  number of datasets of the object is larger then 
%                  3. You can use; 1:3. If empty all pages is kept.
% 
%                  I.e. obj = obj.window('','','',1:3)
% 
%                  Or it can be the name of the dataset you want to
%                  keep. Then the input must be a string. 
% 
%                  I.e. obj = obj.window('','','','Database1')
% 
%                  Or it can be a cell array of the datasets names 
%                  to keep.
% 
%                  I.e obj = obj.window('','','',{'Database1',...
%                  'DataBase2'})
% 
% Output:
% 
% - obj : An nb_cs object where the datasets of the input object 
%         are narrowed down to the given window.
% 
% Examples:
%
% obj = nb_cs([2,2],'test',{'First'},{'Var1','Var2'});
% obj = obj.window({},{'Var1'},1);
%
% Written by Kenneth S. Paulsen      
      
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % obj = window(obj,typesWin,variablesWin,pages)

    if nargin < 4
        pages = [];
        if nargin < 3
            variablesWin = {};
            if nargin < 2
                typesWin = '';
            end
        end
    end

    pagesIn = pages;
    if ischar(pages)
        if strcmpi(pages,'end')
            pages = obj.numberOfDatasets;
        end
    end
    
    [~,~,typesInd,variablesInd,pages] = getWindow(obj,typesWin,variablesWin,pages);

    if sum(variablesInd)==0 || sum(typesInd)==0 % If all variables is removed

        obj = obj.empty();

    else

        % Give the data properties
        obj.variables = obj.variables(variablesInd);
        obj.data      = obj.data(typesInd, variablesInd, pages);
        obj.dataNames = obj.dataNames(pages);
        obj.types     = obj.types(typesInd);
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object. (Cannot give pages, because the links are already
        % removed)
        obj = obj.addOperation(@window,{typesWin,variablesWin,pagesIn});
        
    end

end

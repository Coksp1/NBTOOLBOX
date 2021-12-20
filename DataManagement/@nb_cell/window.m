function obj = window(obj,rows,columns,pages)
% Syntax:
%
% obj = window(obj,rows,colums,pages)
%
% Description:
%
% Narrow down the dataset(s) of the nb_cell object
% 
% Input:
% 
% - obj          : An object of class nb_cell
% 
% - rows         : The row indexes. As a 1 x N integer.
% 
% - columns      : The columns indexes. As a 1 x N integer.
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
% - obj : An nb_cell object where the datasets of the input object 
%         are narrowed down to the given window.
% 
% Written by Kenneth S. Paulsen      
      
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % obj = window(obj,typesWin,variablesWin,pages)

    if nargin < 4
        pages = [];
        if nargin < 3
            columns = [];
            if nargin < 2
                rows = [];
            end
        end
    end

    pagesIn = pages;
    if ischar(pages)
        if strcmpi(pages,'end')
            pages = obj.numberOfDatasets;
        end
    end
    
    if sum(columns)==0 || sum(rows)==0 % If all variables is removed
        obj = obj.empty();
    else

        % Give the data properties
        obj.data      = obj.data(rows, columns, pages);
        obj.c         = obj.c(rows, columns, pages);
        obj.dataNames = obj.dataNames(pages);

    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object. (Cannot give pages, because the links are already
        % removed)
        obj = obj.addOperation(@window,{rows,columns,pagesIn});
        
    end

end

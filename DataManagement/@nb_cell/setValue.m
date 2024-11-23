function obj = setValue(obj,column,Value,rows,pages)
% Syntax:
%
% obj = setValue(obj,columns,Value,rows,pages)
%
% Description:
%
% Set some values of the dataset(s). (Only one column.)
% 
% Input:
% 
% - obj     : An object of class nb_cs
% 
% - column  : The index of the column you want to set some values
%             of. As an integer.
% 
% - Value   : The values you want to assign to the column. Must be 
%             a cell vector (with the same number of pages as 
%             given by pages or as the number of dataset the object 
%             consists of.) Must have the same length as the input
%             given by rows. (If this is not provided this input
%             must the same number of rows as the cdata property)
% 
% - rows    : A vector of row indexes to set.
% 
% - pages   : At which pages you want to set the values of a
%             column. Must be a numerical index of the pages you 
%             want to set.
%             E.g. if you want to set the values of the 3 first 
%             datasets (pages of the data) of the object. And the 
%             number of datasets of the object is larger then 3. 
%             You can use; 1:3. If empty all pages must be set.
% 
% Output:
% 
% - obj : An nb_cell object with the added variable
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin<5
        pages = 1:obj.numberOfDatasets;
        if nargin<4
            rows = 1:size(obj.data,1);
            if nargin<3
                error([mfilename,':: All but the two last inputs must be provided. I.e. setValue(obj,columns,Value)'])
            end
        end
    end

    if isempty(obj.data)
        error([mfilename,':: cannot set a value for a dataset which has no data'])
    end

    if ~isempty(pages)
        m = max(pages);
        if m > obj.numberOfDatasets
            error([mfilename ':: The object consist only of ' int2str(obj.numberOfDatasets) ' datasets. You are trying to set '
                             'values for the dataset ' int2str(m) ', which is not possible.'])
        end 
    else
        error([mfilename ':: You cannot set the values of no pages at all!'])
    end

    if ~iscell(Value)
        error([mfilename ':: The Value input must be a cell!'])
    end
    if size(Value,2)>1
        error([mfilename,':: data must be a vertical cell vector'])
    end
    
    
    try
        obj.c(rows,column,pages)    = Value;
        ind                         = cellfun(@(x)isa(x,'numeric'),Value);
        newData                     = obj.data(rows,column,pages);
        newData(ind)                = cell2mat(Value(ind));
        obj.data(rows,column,pages) = newData;
    catch Err
        if obj.numberOfDatasets ~= size(Value,3)
            error([mfilename ':: the third dimension of the data values given (' int2str(size(Value,3)) ') doesn''t match the number of pages (datasets) of the object (' int2str(obj.numberOfDatasets) ').'])
        else
            rethrow(Err)
        end
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@setValue,{column,Value,rows,pages});
        
    end

end

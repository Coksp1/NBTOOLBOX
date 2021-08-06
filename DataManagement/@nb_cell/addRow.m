function obj = addRow(obj,location,elements)
% Syntax:
%
% obj = addRow(obj,location,elements)
%
% Description:
%
% Add a row at a given location.
% 
% Input:
% 
% - obj      : A nb_cell object.
% 
% - location : The location to add a row. It will be added after this row. 
%              If empty a empty row will be added last in the nb_cell 
%              object.
%
% - elements : A cell with size 1 x size(obj.cdata,2) x size(obj.cdata,3). 
%              If empty, a empty row will be added.
%
% Output:
% 
% - obj      : A nb_cell object with a added row.
%
% See also:
% addColumn
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        elements = {};
        if nargin < 2
            location = [];
        end
    end
    
    if isempty(elements)
        elementsT = cell(1,size(obj.data,2),size(obj.data,3));
    else
        elementsT = elements;
    end
    
    if isempty(location)
        locationT = size(obj.data,1);
    else
        locationT = location;
    end
    
    [r1,c1,p1] = size(obj.data);
    [r2,c2,p2] = size(elementsT);
    if r2 ~= 1
        error([mfilename ':: The elements input must have only one row.'])
    end
    if c1 ~= c2
        error([mfilename ':: The elements input must have the same number of columns as the object has (' int2str(c1) ').'])
    end
    if p1 ~= p2
        error([mfilename ':: The elements input must have the same number of pages as the object has (' int2str(p1) ').'])
    end
    
    if locationT > r1
        error([mfilename ':: The location input cannot be greater than the number of rows of the object (' int2str(r1) ')'])
    elseif locationT < 1
        error([mfilename ':: The location input cannot be less than 1'])
    end
    
    % Fix a issue here
    indEmpty              = cellfun(@isempty,elementsT);
    [elementsT{indEmpty}] = deal('');
    
    % What is numbers and what is not?
    eData = nan(r2,c2,p2);
    ind   = cellfun(@(x)isa(x,'numeric'),elementsT);
    if all(~ind)
        eData(ind) = cell2mat(elementsT(ind));
    end
    
    % Assign data property
    newData  = obj.data;
    newData  = [newData(1:locationT,:,:);eData;newData(locationT+1:end,:,:)];
    obj.data = newData;

    % Assign cell property
    newC  = obj.c;
    newC  = [newC(1:locationT,:,:);elementsT;newC(locationT+1:end,:,:)];
    obj.c = newC;
    
    if obj.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@addRow,{location,elements});
    end
    
end

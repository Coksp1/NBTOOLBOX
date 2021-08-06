function obj = intertwine(varargin)
% Syntax:
%
% obj = intertwine(varargin)
%
% Description:
%
% Intertwine objects of class nb_cell objects with equal sizes.
% 
% Caution: This method will break the link to the data source.
%
% Optional input:
%
% - 'header' : Intertwine header, i.e. first row. true or false.
%              Default is false.
%
% - varargin : Supply nb_cell objects (obj, obj2, ...)
% 
% Output:
% 
% - obj : An object of class nb_cell
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [header,varargin] = nb_parseOneOptionalSingle('header',false,true,varargin{:});

    test = cellfun(@(x)isa(x,'nb_cell'),varargin);
    if any(~test)
        error('All inputs must be of class nb_cell');
    end
    
    nObj = size(varargin,2);
    dim1 = cellfun(@(x)size(x,1),varargin);
    if any(dim1(1) ~= dim1)
        error('The first dimension must be equal for all objects.')
    end
    dim2 = cellfun(@(x)size(x,2),varargin);
    if any(dim2(1) ~= dim2)
        error('The second dimension must be equal for all objects.')
    end
    dim3 = cellfun(@(x)size(x,3),varargin);
    if any(dim3(1) ~= dim3)
        error('The third dimension must be equal for all objects.')
    end
    
    if header
        data = cellfun(@(x)x.data,varargin,'uniformOutput',false);
        c    = cellfun(@(x)x.c,varargin,'uniformOutput',false);
    else
        data       = cellfun(@(x)x.data(2:end,:,:),varargin,'uniformOutput',false);
        c          = cellfun(@(x)x.c(2:end,:,:),varargin,'uniformOutput',false);
        headerData = varargin{1}.data(1,:,:);
        headerC    = varargin{1}.c(1,:,:);
    end
    data = vertcat(data{:});
    c    = vertcat(c{:});
    rows = size(data,1);
    r    = rows/nObj;
    ind  = nan(rows,1);
    for ii = 1:r
        i      = (ii - 1)*nObj+1:ii*nObj;
        ind(i) = ii:r:rows;
    end
    obj      = varargin{1};
    obj.data = data(ind,:,:);
    obj.c    = c(ind,:,:);
    if ~header
        obj.data = [headerData; obj.data];
        obj.c    = [headerC; obj.c];
    end
    obj = breakLink(obj);
    
end

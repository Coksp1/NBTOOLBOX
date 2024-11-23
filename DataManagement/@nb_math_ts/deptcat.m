function obj = deptcat(a,b,varargin)
% Syntax:
%
% obj = deptcat(a,b,varargin)
%
% Description:
%
% Depth concatenation (add pages of different nb_math_ts objects) 
% (No short hand notation)
% 
% Input:
%
% - a        : An object of class nb_math_ts
%
% - b        : An object of class nb_math_ts
%
% Optional inputs:
%
% - varargin : Optional number of nb_math_ts objects
%
% - 'expand' : true or false. If set to true, the pages with fewer
%              observations are expanded. Default is false.
% 
% Output:
% 
% obj        : An object of class nb_math_ts, which will result 
%              from adding all the pages from the input objects.
%
% Examples:
%
% obj = deptcat(a,b);
% obj = deptcat(a,b,c);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(a,'nb_math_ts') && ~isa(b,'nb_math_ts')
        error(['Undefined function ''deptcat'' for input arguments ',...
            'of type ''' class(a) ''' and ''' class(b) '''.'])
    end
    [doExpand,varargin] = nb_parseOneOptional('expand',false,varargin{:});

    if ~doExpand
        if a.dim1 ~= b.dim1
            error('The data of the two objects has not the same number of rows.')
        end
    end

    if a.dim2 ~= b.dim2
        error('The data of the two objects has not the same number of pages.')
    end

    % Initialize empty object
    obj = nb_math_ts();

    % Assign properties
    if doExpand
        a = expand(a,b.startDate,b.endDate,'nan','off');
        b = expand(b,a.startDate,a.endDate,'nan','off');
    end

    obj.data                     = nan(a.dim1,a.dim2,a.dim3 + b.dim3);
    obj.data(:,:,1:a.dim3)       = a.data;
    obj.data(:,:,a.dim3 + 1:end) = b.data;

    obj.startDate = a.startDate;
    obj.endDate   = a.endDate;
    
    % Concatenate the rest
    if ~isempty(varargin)        
        obj = deptcat(obj,varargin{:},'expand',doExpand);
    end

end

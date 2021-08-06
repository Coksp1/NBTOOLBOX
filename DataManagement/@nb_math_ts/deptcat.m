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
% - varargin : Optional number of nb_math_ts objects
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isa(a,'nb_math_ts') && ~isa(a,'nb_math_ts')
        error([mfilename ':: Undefined function ''deptcat'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

    if a.dim1 ~= b.dim1
        error([mfilename ':: The data of the two objects has not the same number of rows.'])
    end

    if a.dim2 ~= b.dim2
        error([mfilename ':: The data of the two objects has not the same number of pages.'])
    end

    % Initialize empty object
    obj = nb_math_ts();

    % Assign properties
    obj.data                     = nan(a.dim1,a.dim2,a.dim3 + b.dim3);
    obj.data(:,:,1:a.dim3)       = a.data;
    obj.data(:,:,a.dim3 + 1:end) = b.data;
    
    % Concatenate the rest
    if ~isempty(varargin)
        
        obj = deptcat(obj,varargin{ii});
        
    end

end

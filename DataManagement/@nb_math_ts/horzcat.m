function obj = horzcat(a,b,varargin)
% Syntax:
%
% obj = horzcat(a,b,varargin)
%
% Description:
%
% Horizontal concatenation ([a,b])
% 
% If the start or end dates differ, nan values will be appended
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
% obj        : An object of class nb_math_ts with the input objects
%              data are horizontally concatenated
% 
% Examples:
%
% obj = [a,b];
% obj = [a,b,c];
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin == 1
        obj = a;
        return
    end

    if isa(a,'cell') 
        obj = [a,{b}];
        obj = horzcat(obj,varargin{:});
        return
    elseif isa(b,'cell')
        obj = [{a},b]; 
        obj = horzcat(obj,varargin{:});
        return
    elseif ~isa(a,'nb_math_ts') || ~isa(b,'nb_math_ts')
        error([mfilename ':: Undefined function ''horzcat'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

    if a.dim3 ~= b.dim3
        error([mfilename ':: The data of the two objects has not the same number of pages.'])
    end

    obj = a;

    % Ensure that the objects has the same start dates
    diff = a.startDate - b.startDate;
    if diff < 0
        b.data        = [nan(abs(diff),b.dim2,b.dim3); b.data];
        obj.startDate = a.startDate;
    elseif diff > 0
        a.data        = [nan(diff,a.dim2,a.dim3); a.data];
        obj.startDate = b.startDate;
    end

    % Ensure that the objects has the same end dates
    diff = a.endDate - b.endDate;
    if diff > 0
        b.data      = [b.data; nan(abs(diff),b.dim2,b.dim3)];
        obj.endDate = a.endDate;
    elseif diff < 0
        a.data      = [a.data; nan(abs(diff),a.dim2,a.dim3)];
        obj.endDate = b.endDate;
    end

    % Assign properties
    obj.data = [a.data,b.data];
    
    % Concatenate the rest
    if ~isempty(varargin)
        obj = horzcat(obj,varargin{:});
    end

end

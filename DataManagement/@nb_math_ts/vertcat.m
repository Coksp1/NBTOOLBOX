function a = vertcat(a,b,varargin)
% Syntax:
%
% obj = vertcat(a,b,varargin)
%
% Description:
% 
% Vertical concatenation ([a;b])
% 
% Input:
% 
% - a         : An object of class nb_math_ts
% 
% - b         : An object of class nb_math_ts
% 
% - varargin  : Optional numbers of objects of class nb_math_ts
% 
% Output:
% 
% - a         : An nb_math_ts object where the data from the 
%               different objects are appended to each other.
% 
% Examples:
% 
% obj  = nb_math_ts(ones(2,1),'2012Q1');
% aObj = nb_math_ts(ones(2,1),'2012Q3');
% m    = [obj;aObj]
% 
% m = 
% 
%     '2012Q1'    [   1]
%     '2012Q2'    [   1]
%     '2012Q3'    [   1]
%     '2012Q4'    [   1]
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(a,'nb_math_ts') && ~isa(b,'nb_math_ts')
        error([mfilename ':: Undefined function ''vertcat'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

    if a.dim2 ~= b.dim2
        error([mfilename ':: The data of the two objects has not the same number of columns.'])
    end

    if a.dim3 ~= b.dim3
        error([mfilename ':: The data of the two objects has not the same number of pages.'])
    end

    if ~(a.endDate == (b.startDate - 1))
        error([mfilename ':: The first inputs ''endDate'' (' a.endDate.toString() ') property must be the date following '...
                         'the second inputs ''startDate'' property. (' b.startDate.toString() ').'])
    end

    a.data    = [a.data;b.data];
    a.endDate = a.startDate + a.dim1 - 1;
    if ~isempty(varargin)
        a = vertcat(a,varargin{:});
    end

end

function obj = vertcat(a,b,varargin)
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
% - a         : An object of class nb_ts
% 
% - b         : An object of class nb_ts
% 
% - varargin  : Optional numbers of objects of class nb_ts
% 
% Output:
% 
% - a         : An nb_ts object where the data from the different
%               objects are appended to each other.
% 
% Examples:
% 
% obj  = nb_ts(ones(2,1),'','2012Q1',{'Var1'});
% aObj = nb_ts(ones(2,1),'','2012Q3',{'Var1'});
% m    = [obj;aObj]
% 
% m = 
% 
%     'Time'      'Var1'
%     '2012Q1'    [   1]
%     '2012Q2'    [   1]
%     '2012Q3'    [   1]
%     '2012Q4'    [   1]
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isa(a,'nb_ts') && ~isa(b,'nb_ts')
        error([mfilename ':: Undefined function ''vertcat'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end
    
    if a.frequency ~= b.frequency
        error([mfilename ':: The objects vertically concatenated do not share the same frequency.'])
    end
    
    if ~(a.endDate == (b.startDate - 1))
        error([mfilename ':: The second inputs ''startDate'' (' b.startDate.toString() ') property must be the date following '...
                         'the first inputs ''endDate'' property. (' a.endDate.toString() ').'])
    end

    % Then it is okay to merge them
    obj = merge(a,b);
    
    % Merge the rest
    if ~isempty(varargin)
        
        obj = vertcat(obj,varargin{:});
        
    end

end

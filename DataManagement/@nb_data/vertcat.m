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
% - a         : An object of class nb_data
% 
% - b         : An object of class nb_data
% 
% - varargin  : Optional numbers of objects of class nb_data
% 
% Output:
% 
% - a         : An nb_data object where the data from the different
%               objects are appended to each other.
% 
% Examples:
% 
% obj  = nb_data(ones(2,1),'',1,{'Var1'});
% aObj = nb_data(ones(2,1),'',3,{'Var1'});
% m    = [obj;aObj]
% 
% m = 
% 
%     'Time'      'Var1'
%     '1'         [   1]
%     '2'         [   1]
%     '3'         [   1]
%     '4'         [   1]
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isa(a,'nb_data') && ~isa(a,'nb_data')
        error([mfilename ':: Undefined function ''vertcat'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end
    
    
    if ~(a.endObs == (b.startObs - 1))
        error([mfilename ':: The second inputs ''startObs'' (' int2str(b.startObs) ') property must be the obs following '...
                         'the first inputs ''endObs'' property. (' int2str(a.endObs) ').'])
    end

    % Then it is okay to merge them
    obj = merge(a,b);
    
    % Merge the rest
    if ~isempty(varargin)
        
        obj = vertcat(obj,varargin{:});
        
    end

end

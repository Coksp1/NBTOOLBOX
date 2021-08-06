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
% - a         : An object of class nb_cs
% 
% - b         : An object of class nb_cs
% 
% - varargin  : Optional numbers of objects of class nb_cs
% 
% Output:
% 
% - a         : An nb_cs object where the data from the different
%               objects are appended to each other.
% 
% Examples:
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isa(a,'nb_cs') && ~isa(a,'nb_cs')
        error([mfilename ':: Undefined function ''vertcat'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

    % Then it is okay to merge them
    obj = merge(a,b);
    
    % Merge the rest
    if ~isempty(varargin)
        
        obj = vertcat(obj,varargin{:});
        
    end

end

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
% - a         : An object of class nb_cell
% 
% - b         : An object of class nb_cell
% 
% - varargin  : Optional numbers of objects of class nb_cell
% 
% Output:
% 
% - a         : An nb_cell object where the data from the different
%               objects are appended to each other.
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(a,'nb_cell') && ~isa(a,'nb_cell')
        error([mfilename ':: Undefined function ''vertcat'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

    % Then it is okay to merge them
    obj = merge(a,b,'vertcat');
    
    % Merge the rest
    if ~isempty(varargin)  
        obj = vertcat(obj,varargin{:});
    end

end

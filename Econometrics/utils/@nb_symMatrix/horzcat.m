function obj = horzcat(a,varargin)
% Syntax:
%
% obj = horzcat(a,b,varargin)
%
% Description:
%
% Horizontal concatenation of nb_symMatrix objects ([a,b]).
% 
% Input:
%
% - a        : An object of class nb_symMatrix.
%
% - varargin : Optional number of nb_symMatrix objects.
% 
% Output:
%
% - obj      : An nb_symMatrix object.
% 
% Examples:
%
% obj = [a,b];
% obj = [a,b,c];
%
% See also:
% nb_symMatrix.vertcat
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj      = a;
    varargin = [{a},varargin];
    sym      = cell(1,nargin);
    for ii = 1:nargin
        sym{ii} = varargin{ii}.symbols;
    end   
    try
        obj.symbols = horzcat(sym{:});    
    catch Err
        throwAsCaller(Err);
    end
    
end

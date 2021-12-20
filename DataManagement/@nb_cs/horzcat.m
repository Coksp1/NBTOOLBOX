function obj = horzcat(a,varargin)
% Syntax:
%
% obj = horzcat(a,b,varargin)
%
% Description:
%
% Horizontal concatenation of nb_cs objects. ([a,b]) This is only 
% possible if the different objects contain differen variables or
% have variables with the same values (types can differ). Uses the 
% merge method.
% 
% If the types differ, nan values will be added. 
% 
% Input:
%
% - a        : An object of class nb_cs
%
% - varargin : Optional number of nb_cs objects
% 
% Output:
%
% - obj      : An nb_cs object with all the variables from the 
%              different nb_cs object merge into one dataset 
% 
% Examples:
%
% obj = [a,b];
% obj = [a,b,c];
%
% See also:
% merge
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    for ii = 1:size(varargin,2)
        a = merge(a,varargin{ii});
    end
    obj = a;

end

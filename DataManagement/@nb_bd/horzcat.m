function obj = horzcat(a,varargin)
% Syntax:
%
% obj = horzcat(a,b,varargin)
%
% Description:
%
% Horizontal concatenation of nb_bd objects. ([a,b]) This is only 
% possible if the different objects contain different variables or
% have variables with the same values (start and/or end dates can 
% differ). Uses the merge method.
% 
% Input:
%
% - a        : An object of class nb_bd
%
% - varargin : Optional number of nb_bd objects
% 
% Output:
%
% - obj      : An nb_bd object with all the variables from the 
%              different nb_bd object merged into one dataset 
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    for ii = 1:size(varargin,2)
        a = merge(a,varargin{ii});
    end
    obj = a;

end

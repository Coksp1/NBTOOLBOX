function obj = horzcat(a,varargin)
% Syntax:
%
% obj = horzcat(a,varargin)
%
% Description:
%
% Horizontal concatenation of nb_data objects. ([a,b]) This is only 
% possible if the different objects contain differen variables or
% have variables with the same values (start and/or end obs can 
% differ). Uses the merge method.
% 
% If the start and/or end obs differ, nan values will be 
% appended. 
% 
% Input:
%
% - a        : An object of class nb_data
%
% - varargin : Optional number of nb_data objects
% 
% Output:
%
% - obj      : An nb_data object with all the variables from the 
%              different nb_data object merge into one dataset 
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    for ii = 1:size(varargin,2)
        a = merge(a,varargin{ii});
    end
    obj = a;

end

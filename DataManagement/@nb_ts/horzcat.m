function obj = horzcat(a,varargin)
% Syntax:
%
% obj = horzcat(a,b,varargin)
%
% Description:
%
% Horizontal concatenation of nb_ts objects. ([a,b]) This is only 
% possible if the different objects contain differen variables or
% have variables with the same values (start and/or end dates can 
% differ). Uses the merge method.
% 
% If the start and/or end dates differ, nan values will be 
% appended. 
% 
% Input:
%
% - a        : An object of class nb_ts
%
% - varargin : Optional number of nb_ts objects
% 
% Output:
%
% - obj      : An nb_ts object with all the variables from the 
%              different nb_ts object merge into one dataset 
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

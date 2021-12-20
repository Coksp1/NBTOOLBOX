function obj = stdise(obj,flag)
% Syntax:
%
% obj = stdise(obj,flag)
%
% Description:
%
% Standardise data of the object by subtracting mean and dividing 
% by std deviation.
% 
% Input :
% 
% - obj  : An object of class nb_math_ts
% 
% - flag : - 0 : normalises by N-1 (Default)
%          - 1 : normalises by N
% 
%          Where N is the sample length.
%          
% Output:
% 
% - obj  : An nb_math_ts object with the standardised data
% 
% Examples:
% 
% obj = stdise(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj = mean(obj)./std(obj,flag);

end

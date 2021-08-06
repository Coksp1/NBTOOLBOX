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
% - obj  : An object of class nb_data
% 
% - flag : - 0 : normalises by N-1 (Default)
%          - 1 : normalises by N
% 
%          Where N is the sample length.
%          
% Output:
% 
% - obj  : An nb_data object with the standardised data
% 
% Examples:
% 
% obj = stdise(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        flag = 0;
    end

    obj = mean(obj)./std(obj,flag);
    
    % Caution : If the object is updateable the standardisation 
    %           will be taken care of in the rdivide, mean and std methods.
    
end

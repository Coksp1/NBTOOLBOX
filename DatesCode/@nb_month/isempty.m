function ret = isempty(obj)
% Syntax:
% 
% ret = isempty(obj)
%
% Description:
%   
% Test if the object is empty
% 
% Input:
% 
% - obj   : An object of class nb_month
% 
% Output:
% 
% - ret   : 1 if empty, 0 else. Always false for vectors of objects.
%     
% Examples:
%
% ret = obj.isempty();
% ret = isempty(obj);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        ret = false;
    else
        ret = isempty(obj.monthNr);
    end
    
end

function ret = isempty(obj)
% Syntax:
%
% ret = isempty(obj)
%
% Description:
%
% Test if an nb_graph_bd object is empty. I.e. if no data is stored 
% in the object. Return 1 if true, otherwise 0.
% 
% Input:
% 
% - obj       : An object of class nb_graph_bd
% 
% Output:
% 
% - ret       : True (1) if the series isempty, false (0) if not
% 
% Examples:
%
% ret = isempty(obj);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if numel(obj) == 1
        ret = isempty(obj.DB);
    else
        obj = obj(:);
        ret = true;
        for ii = 1:size(obj,1)
            ret = ret && isempty(obj(ii).DB);
        end
    end
    
end

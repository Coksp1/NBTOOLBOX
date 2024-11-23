function s = struct(obj)
% Syntax:
%
% s = struct(obj)
%
% Description:
%
% Convert object to struct.
% 
% Input:
% 
% - obj : An object of class nb_model_convert.
% 
% Output:
% 
% - s   : A struct representing the nb_model_convert object.
%
% See also:
% nb_model_convert.unstruct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    s     = struct('class',class(obj));
    props = properties(obj);
    for ii = 1:length(props)
        s.(props{ii}) = obj.(props{ii});
    end
    s.model         = struct(obj.model);
    s.historyOutput = struct(obj.historyOutput);
    
end

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
% - obj : An object of class nb_model_recursive_detrending.
% 
% Output:
% 
% - s   : A struct representing the nb_model_recursive_detrending object.
%
% See also:
% nb_model_group.unstruct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    s     = struct('class',class(obj));
    props = properties(obj);
    for ii = 1:length(props)
        s.(props{ii}) = obj.(props{ii});
    end

    % Convert the models to struct as well
    s.model    = struct(s.model);
    modelIter  = obj.modelIter;
    modelIterC = cell(size(modelIter));
    for tt = 1:length(modelIter)
        modelIterC{ii} = struct(modelIter(tt));
    end
    s.modelIter = modelIterC;
    
end

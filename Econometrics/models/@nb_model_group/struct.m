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
% - obj : An object of class nb_model_group.
% 
% Output:
% 
% - s   : A struct representing the nb_model_group object.
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

    % Convert data to structure as well
    if isa(obj,'nb_model_selection_group')
        opt           = s.options;
        opt.data      = [];
        s.options     = opt;
        s.dataOrig    = struct(obj.dataOrig);
        s.fcstHorizon = obj.fcstHorizon;
    end
    
    % Convert the models to struct as well
    models = s.models;
    for ii = 1:length(models)
        models{ii} = struct(models{ii});
    end
    s.models = models;
    
end

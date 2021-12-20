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
% - obj : An object of class nb_calculate_vintages.
% 
% Output:
% 
% - s   : A struct representing the nb_calculate_vintages object.
%
% See also:
% nb_calculate_vintages.unstruct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    s     = struct('class',class(obj));
    props = properties(obj);
    props = setdiff(props,{'model','results','name'}); % Name is a dependent property!
    for ii = 1:length(props)
        s.(props{ii}) = obj.(props{ii});
    end
    
    % Naming
    s.addAutoName  = getAddAutoName(obj);
    s.addIDIfLocal = getAddIDIfLocal(obj);
    s.identifier   = getIdentifier(obj);
    s.nameLocal    = getNameLocal(obj);
    
    % Convert fields to struct as well
    s.options.dataSource = struct(s.options.dataSource);
    s.options.model      = struct(s.options.model);
    s.options.store2     = struct(s.options.store2);

end

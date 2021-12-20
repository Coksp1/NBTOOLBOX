function obj = unstruct(s)
% Syntax:
%
% obj = nb_calculate_vintages.unstruct(s)
%
% Description:
%
% Convert a struct to an object which is a subclass of the 
% nb_calculate_vintages class.
% 
% Input:
% 
% - s   : A struct. See nb_calculate_vintages.struct.
% 
% Output:
% 
% - obj : An object of class nb_calculate_vintages.
%
% See also:
% nb_calculate_vintages.struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isfield(s,'name')
        % Old versions had a non-dependent property name, so we interpret
        % that in the new setup
        s.addAutoName  = false;
        s.addIDIfLocal = false;
        s.nameLocal    = s.name;
        s.identifier   = nb_model_name.findIdentifier();
        s              = rmfield(s,'name');
    end
    s.options.model      = nb_model_estimate.unstruct(s.options.model);
    s.options.dataSource = nb_modelDataSource.unstruct(s.options.dataSource);
    if ~isfield(s.options,'store2')
        s.options.store2 = '';
    end
    if ~isempty(s.options.store2)
        s.options.store2 = nb_store2Database.unstruct(s.options.store2);
    end
    
    obj   = nb_calculate_vintages();
    s     = nb_rmfield(s,{'class','updateContext'});
    props = fieldnames(s);
    for ii = 1:length(props)
        obj.(props{ii}) = s.(props{ii});
    end
    obj = checkModel(obj);

end

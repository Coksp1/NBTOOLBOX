function obj = define(obj,name,statement)
% Syntax:
%
% obj = define(obj,name,statement)
%
% Description:
%
% Define a new macro variable.
% 
% Input:
% 
% - obj       : A 1 x N vector of nb_macro objects.
%
% - name      : A one line char with the name of the defined variable. 
%
% - statement : A one line char to interpret.
% 
% Output:
% 
% - obj       : A 1 x (N + 1) vector of nb_macro objects.
%
% See also:
% nb_macro.parse
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isrow(obj)
        obj = nb_rowVector(obj);
    end
    if any(strcmpi(name,{obj.name}))
        error('nb_macro:define:alreadyDefined',['The macro variable ''' name ''' is already defined.'])
    end
    statement = strrep(statement,';','');
    new       = eval(obj,statement); %#ok<EVLC>
    new.name  = name;
    obj       = [obj,new];

end

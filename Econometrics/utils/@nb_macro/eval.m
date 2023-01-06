function value = eval(obj,expression)
% Syntax:
%
% value = eval(obj,expression)
%
% Description:
%
% Evaluate a expression using the macro processor language.
% 
% Input:
% 
% - obj        : A vector of nb_macro objects.
%
% - expression : A one line char.
% 
% Output:
% 
% - value      : A scalar nb_macro object.
%
% See also:
% nb_eval
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj        = nb_rowVector(obj);
    expression = strrep(expression,'-:','-');
    value      = nb_eval(expression,{obj.name},obj,true);
    if ~isa(value,'nb_macro')
        value = nb_macro(expression,value);
    end

end

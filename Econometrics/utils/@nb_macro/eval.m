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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj        = nb_rowVector(obj);
    expression = strrep(expression,'-:','-');
    value      = nb_eval(expression,{obj.name},obj,true);
    if ~isa(value,'nb_macro')
        value = nb_macro(expression,value);
    end

end

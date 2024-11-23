function [obj,statement] = ifElseEnd(obj,condition,statementTrue,statmentFalse)
% Syntax:
%
% [obj,statement] = ifElseEnd(obj,condition,statementTrue,statmentFalse)
%
% Description:
%
% Running an @#if @#else @#endif block in the macro processing language.
% 
% Input:
% 
% - obj           : A vector of nb_macro objects storing the macro 
%                   variables.
%
% - condition     : The condition to be tested. If true the statementTrue
%                   lines will be used.
%
% - statementTrue : A N x 1 (3) cellstr with a set of model file 
%                   statements.
%
% - statmentFalse : A M x 1 (3) cellstr with a set of model file 
%                   statements.
% 
% Output:
% 
% - statement     : A Q x 1 cellstr with the parsed version of the model
%                   file statements.
%
% See also:
% nb_macro.forEnd, nb_macro.parse
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nb_isOneLineChar(condition)
        try
            test = eval(obj,condition); %#ok<EV2IN>
        catch
            error('nb_macro:ifElseEnd:condition',['The condition to be tested in a @#if block could not be interpreted; ' condition '.'])
        end
    elseif ~isa(condition,'nb_macro')
        error('nb_macro:ifElseEnd:condition','Could not interpret the condition to be tested.')
    else
        test = condition;
    end
    if ~(nb_isScalarLogical(test.value) || nb_isScalarNumber(test.value))
        error('nb_macro:ifElseEnd:condition','The condition to be tested in a @#if block must return a scalar logical (or number).')
    end
    if test.value
        [obj,statement] = parse(obj,statementTrue);
    else
        [obj,statement] = parse(obj,statmentFalse);
    end

end

function nb_optimizerMessageState(value)
% Syntax:
%
% nb_optimizerMessageState(value)
%
% Description:
%
% If state is set to 'true'/true, the nb_interpretExitFlag and 
% nb_callOptimizer functions only throws warnings instead of errors 
%
% Caution: Ignored if the error message is asked to be returned as a one 
% line char!.
%
% Input:
%
% - e           : The exit flag of the given optimizer or solver.
%
% - type        : The optimizer or solver used as a string. E.g. 
%                 'fmincon', 'fminsearch', 'fsolve', etc.
%
% - extra       : A string with extra information on the error. Will be
%                 appended. Default is ''.
%
% - homotopyErr : If nb_homotopy is used you can provide the err output
%                 of that function as this input.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nb_isScalarLogical(value)
        if value 
            value = 'true';
        else
            value = 'false';
        end
    elseif nb_isOneLineChar(value)
        if ~any(strcmp(value,{'true','false'}))
            error('If the value input is a one line char it must be either ''true'' or ''false''')
        end
    else
        error('The value input must be scalar logical or a one line char.')
    end
    setenv('optimizerMessageState',value);
    
end

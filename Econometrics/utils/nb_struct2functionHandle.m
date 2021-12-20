function f = nb_struct2functionHandle(structThatRepresentsTheFunctionHandle)
% Syntax:
%
% f = nb_struct2functionHandle(structThatRepresentsTheFunctionHandle)
%
% Description:
%
% Convert struct to function_handle.
% 
% Input:
% 
% - structThatRepresentsTheFunctionHandle : A struct which is an output 
%                                           from the 
%                                           nb_functionHandle2Struct 
%                                           function.
% 
% Output:
% 
% - f : A function_handle.
%
% See also:
% nb_functionHandle2Struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if not(isfield(structThatRepresentsTheFunctionHandle,'function') && ...
        isfield(structThatRepresentsTheFunctionHandle,'workspace'))
        error('The struct is not possible to convert to function_handle')   
    end
    if iscell(structThatRepresentsTheFunctionHandle.workspace)
        w = structThatRepresentsTheFunctionHandle.workspace{1};
    else
        w = structThatRepresentsTheFunctionHandle.workspace;
    end
    vars = fields(w);
    for ii = 1:length(vars)
        putVariableIntoLocalWorkspace(vars{ii},w.(vars{ii}));
    end
    f = eval(structThatRepresentsTheFunctionHandle.function);
        
end

function putVariableIntoLocalWorkspace(var,field)
    assignin('caller', var, field);
end

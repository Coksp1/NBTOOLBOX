function ret = nb_isStructOfFunctionHandle(structThatRepresentsTheFunctionHandle)
% Syntax:
%
% ret = nb_isStructOfFunctionHandle(structThatRepresentsTheFunctionHandle)
%
% Description:
%
% Is the struct representing a function_handle object?
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
% - ret : true or false.
%
% See also:
% nb_functionHandle2Struct, nb_struct2functionHandle
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isstruct(structThatRepresentsTheFunctionHandle) && ...
        isfield(structThatRepresentsTheFunctionHandle,'function') && ...
        isfield(structThatRepresentsTheFunctionHandle,'workspace')
        ret = true;
    else
        ret = false;
    end

end

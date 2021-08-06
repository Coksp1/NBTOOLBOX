function s = nb_functionHandle2Struct(f)
% Syntax:
%
% s = nb_functionHandle2Struct(f)
%
% Description:
%
% Convert function handle to struct.
% 
% Input:
% 
% - f : function_handle to convert to struct.
% 
% Output:
% 
% - s : A struct representing the function_handle
%
% Examples:
%
% s  = 2;
% s2 = 3;
% f  = @(x)x + s + s2
% s  = nb_functionHandle2Struct(f)
%
% See also:
% nb_struct2functionHandle
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    s = functions(f);
    s = rmfield(s, setdiff(fieldnames(s),{'function','workspace'}));

end

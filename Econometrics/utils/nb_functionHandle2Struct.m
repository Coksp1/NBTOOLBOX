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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    s = functions(f);
    s = rmfield(s, setdiff(fieldnames(s),{'function','workspace'}));
    if ~isfield(s,'workspace')
        s.workspace = struct();
    end
    if ~strncmp(s.function,'@',1)
        % If function handle is on the format @func, it skips the @
        s.function = ['@',s.function];
    end
end

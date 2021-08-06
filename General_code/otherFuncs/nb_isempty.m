function ret = nb_isempty(in)
% Syntax:
%
% ret = nb_isempty(in)
%
% Description:
%
% Same as isempty function, but will return true also for structs without
% fields.
% 
% Input:
% 
% - in : Any type of inputs.
% 
% Output:
% 
% - ret : 1 if empty otherwise 0.
%
% See also:
% isempty
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isstruct(in)
        ret = isempty(fieldnames(in));
        if ~ret
            ret = numel(in) == 0;
        end
    else
        ret = isempty(in);
    end
    
end

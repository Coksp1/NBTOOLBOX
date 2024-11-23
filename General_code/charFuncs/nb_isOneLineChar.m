function ret = nb_isOneLineChar(in)
% Syntax:
%
% ret = nb_isOneLineChar(str)
%
% Description:
%
% Test if an input is a one line (row) char.
% 
% Input:
% 
% - in : Any input
% 
% Output:
% 
% - ret : true if in is a one line char, otherwise false.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    ret = false;
    if ischar(in)
        if size(in,1) == 1 || isempty(in)
           ret = true; 
        end
    end
    
end

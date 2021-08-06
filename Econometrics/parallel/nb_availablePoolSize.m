function s = nb_availablePoolSize()
% Syntax:
%
% s = nb_availablePoolSize()
%
% Description:
%
% Get number of available workers when running in parallel.
% 
% Output:
% 
% - s : An interger with the number of workers.
%
% See also:
% nb_openPool, nb_closePool, nb_poolSize
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    s = getenv('NUMBER_OF_PROCESSORS');
    if ischar(s)
        s = str2double(s);
    end
    
end

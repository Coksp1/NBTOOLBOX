function [ret,D] = nb_parCheck()
% Syntax:
%
% [ret,D] = nb_parCheck()
%
% Description:
%
% Test if it is possible to make a waitbar in parfor using the 
% parallel.pool.DataQueue class or not.
% 
% Output:
% 
% - ret : true or false
%
% - D   : Handle to the parallel.pool.DataQueue object if ret is true,
%         otherwise D is empty.
%
% See also:
% nb_waitbar
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    ret = true;
    try
        D = parallel.pool.DataQueue;
    catch
        ret = false;
        D   = [];
    end

end

function nb_updateWaitbarParallel(note,h)
% Syntax:
%
% nb_updateWaitbarParallel(note,h)
%
% Description:
%
% Function that can be given to the afterEach method of the 
% parallel.pool.DataQueue to update the nb_waitbar class during parfor.
% 
% Input:
% 
% - note : The increment at update.
%
% - h    : The handle to the nb_waitbar object.
% 
% Examples:
%
% D = parallel.pool.DataQueue;
% afterEach(D,@(x)nb_updateWaitbarParallel(x,h));
%
% See also:
% nb_waitbar
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    h.status = h.status + note;  
    
end

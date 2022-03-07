function ret = nb_oldGraphVersion()
% Syntax:
%
% ret = nb_oldGraphVersion()
%
% Description:
%
% MATLAB handle graphical objects in a new way since version 8.4. This
% return true if the version the user is using is less than this.
% 
% Output:
% 
% - ret : true or false.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ret = verLessThan('matlab','8.4');
    
end

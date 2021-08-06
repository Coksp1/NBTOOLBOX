function pop(gui,index)
% Syntax:
%
% pop(gui,index)
%
% Description:
%
% Increment the status of the bar with index given by the index input.
% 
% Input:
% 
% - gui   : A nb_waitbar5 object
% 
% - index : Which bar to increment. A number between 1 and 5.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    property       = ['status' int2str(index)];
    gui.(property) = gui.(property) + 1;
            
end

function out = nb_getSelectedFromListbox(handle)
% Syntax:
%
% out = nb_getSelectedFromListbox(handle)
%
% Description:
%
% Get selected string from list box.
%
% Input:
%
% - handle : A uicontrol handle.
%
% Output:
%
% - out    : The selected string.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    string = get(handle,'string');
    ind    = get(handle,'value');
    out    = string(ind);

end

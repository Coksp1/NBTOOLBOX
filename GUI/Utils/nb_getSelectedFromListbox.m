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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    string = get(handle,'string');
    ind    = get(handle,'value');
    out    = string(ind);

end

function [out,ind] = nb_getSelectedFromPop(handle,type)
% Syntax:
%
% [out,ind] = nb_getSelectedFromPop(handle,type)
%
% Description:
%
% Get selected string from pop up menu.
%
% Input:
%
% - handle : A uicontrol handle.
%
% - type   : Give 'numeric' to return a double.
%
% Output:
%
% - out    : The selected string (or string converted to double).
% 
% - ind    : The index of the selected string.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = '';
    end

    string = get(handle,'string');
    ind    = get(handle,'value');
    if iscell(string)
        out = string{ind};
    else
        out = string(ind,:);
    end
    
    if strcmpi(type,'numeric')
       out = str2double(out); 
    end

end

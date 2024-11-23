function index = nb_setPopupValue(control, string, varargin)
% Syntax:
%
% index = nb_setPopupValue(control, string, varargin)
%
% Description:
%
% Set pop up menu value.
% 
% Input:
% 
% - control : The handle to the uicontrol.
%
% - string  : A char.
% 
% Optional input:
%
% - 'UserData' : Give this as input to get the alteratives from the 
%                'userdata' property of the uicontrol instead of from the
%                'string' property.
%
% Output:
% 
% - index   : The value.
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    options = varargin;

    alternatives = nb_conditional(...
        any(strcmpi('UserData', options)), ...
        get(control, 'UserData'), ...
        get(control, 'String'));
    index = find(cellfun(@(alt)isequal(alt, string), alternatives));
    if isempty(index)
        index = 1;
    end
    set(control, 'Value', index);
    
end

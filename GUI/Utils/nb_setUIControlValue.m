function handle = nb_setUIControlValue(handle, value, varargin)
% Syntax:
%
% handle = nb_setUIControlValue(handle, value, varargin)
%
% Description:
%
% Set uicontrol string/value.
% 
% Input:
% 
% - handle : The handle to the uicontrol.
%
% - value  : A char or double.
% 
% Optional input:
%
% - 'UserData' : Give this as input to get the alteratives from the 
%                'userdata' property of the uicontrol instead of from the
%                'string' property. Only of uicontrol of style 'popupmenu'.
%
% Output:
% 
% - handle : The handle to the uicontrol.
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    varargin = lower(varargin); 
    style    = get(handle, 'style');
    switch lower(style)
        case {'edit', 'text'}
            set(handle, 'String', value);     
        case 'popupmenu'
            nb_setPopupValue(handle, value, varargin{:});
        case {'checkbox', 'radiobutton'}
            set(handle, 'Value', value);
        otherwise
            warning(['uicontrols of type ' style ' is not supported']);
    end

end

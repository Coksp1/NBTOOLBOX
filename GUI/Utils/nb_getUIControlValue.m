function [value, index] = nb_getUIControlValue(handle, varargin)
% Syntax:
%
% [value, index] = nb_getUIControlValue(handle, varargin)
%
% Description:
%
% Get selected string from pop up menu.
%
% Input:
%
% - handle : A uicontrol handle.
%
% Optional input:
%
% - 'numeric' : Return a double. '' is converted to [] and not nan!
%
% - 'logical' : Return a logical.
%
% Output:
%
% - out    : The selected string (or string converted to double).
% 
% - ind    : The index of the selected string.
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    varargin = lower(varargin);
    
    style = get(handle, 'style');
    switch lower(style)
        case {'edit', 'text'}
            value = get(handle, 'string');
            
        case 'popupmenu'
            string = nb_conditional(...
                ismember('userdata', varargin), ...
                get(handle, 'UserData'), ...
                cellstr(get(handle, 'String')));
            index = get(handle, 'Value');
            value = string{index};
            
        case 'listbox'
            % OBS: This is NOT equal to the 'popupmenu' case
            string = get(handle, 'string');
            index = get(handle, 'value');
            value = string(index);
            
        case {'checkbox', 'radiobutton'}
            value = get(handle, 'value');
    end
    
    % Return [] for empty "numerical strings"
    if ismember('numeric', varargin) 
        value = nb_conditional(~isempty(value),nb_str2double(value),[]);
    end
    
    if ismember('logical', varargin) 
        value = logical(value);
    end

end

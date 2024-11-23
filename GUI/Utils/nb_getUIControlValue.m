function [value, index] = nb_getUIControlValue(handle, varargin)
% Syntax:
%
% [value, index] = nb_getUIControlValue(handle, varargin)
%
% Description:
%
% Get selected string from ui control handle.
%
% Input:
%
% - handle    : A uicontrol handle.
%
% Optional input:
%
% - 'numeric' : Return a double. '' is converted to [] and not nan!
%
% - 'logical' : Return a logical.
%
% - 'userdata' : Return the matching element from userdata instead of 
%                displayed element. Only if handle input is of 
%                style 'popupmenu' or a matlab.ui.control.DropDown object.
%
% Output:
%
% - out    : The selected string (or string converted to double).
% 
% - ind    : The index of the selected string.
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    varargin = lower(varargin);
    index    = [];
    
    if isa(handle,'matlab.ui.control.EditField') || isa(handle,'matlab.ui.control.TextArea')

        value = handle.Value;

    elseif isa(handle,'matlab.ui.control.DropDown')

        if isempty(handle.Items)
            value = '';
            index = [];
        else
            value = handle.Value;
            index = find(strcmp(value,handle.Items));
        end
        if ismember('userdata', varargin)
            value = handle.UserData{index};
        end

    elseif isa(handle,'matlab.ui.control.ListBox')

        value = handle.Value;
        if nb_isOneLineChar(value)
            % Always return cellstr! Also when Multiselect == 'off'
            value = cellstr(value);
        end
        index = find(ismember(value,handle.Items));

    elseif isa(handle,'matlab.ui.control.CheckBox') || isa(handle,'matlab.ui.control.RadioButton')

        value = handle.Value;

    else

        % Old uicontrol class
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
    
                string = get(handle, 'string');
                index = get(handle, 'value');
                value = string(index);
                
            case {'checkbox', 'radiobutton'}

                value = get(handle, 'value');

            otherwise

                error(['Unsupported style ' style])

        end

    end
    
    % Return [] for empty "numerical strings"
    if ismember('numeric', varargin) 
        value = nb_conditional(~isempty(value),nb_str2double(value),[]);
    end
    
    if ismember('logical', varargin) 
        value = logical(value);
    end

end

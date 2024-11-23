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
% - 'integer'  : Using int2str to convert to char. Only if handle input is 
%                of style 'edit' or 'text', or a 
%                matlab.ui.control.EditField object.
%
% - 'numeric'  : Using num2str to convert to char. Only if handle input is 
%                of style 'edit' or 'text', or a 
%                matlab.ui.control.EditField object.
%
% - 'logical'  : Convert from logical to char, using that false is 0 and 
%                true is 1. Only if handle input is of style 'edit' or 
%                'text', or a matlab.ui.control.EditField object.
%
% - 'UserData' : Give this as input to get the alteratives from the 
%                'userdata' property of the uicontrol instead of from the
%                'string' or 'Items' property. Only if handle input is of 
%                style 'popupmenu' or a matlab.ui.control.DropDown object.
%
% - 'nb_date'  : Convert from nb_date to char. Only if handle input is 
%                of style 'edit' or 'text', or a 
%                matlab.ui.control.EditField object.
%
% Output:
% 
% - handle : The handle to the uicontrol.
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(handle,'matlab.ui.control.EditField') || ...
            isa(handle,'matlab.ui.control.TextArea')

        if any(strcmpi('integer', varargin))
            value = int2str(value);
        elseif any(strcmpi('numeric', varargin))
            value = num2str(value);
        elseif any(strcmpi('logical', varargin))
            value = int2str(double(value));
        elseif any(strcmpi('nb_date', varargin))
            value = toString(value,'gui');
        end
        handle.Value = value;

    elseif isa(handle,'matlab.ui.control.DropDown')

        alternatives = nb_conditional(...
            any(strcmpi('UserData', varargin)), ...
            handle.UserData, ...
            handle.Items);
        if ~isempty(alternatives)
            handle.ValueIndex = find(cellfun(@(alt)isequal(alt, value), alternatives));
        end

    elseif isa(handle,'matlab.ui.control.ListBox')

        if nb_isOneLineChar(value)
            value = cellstr(value);
        end

        alternatives = handle.Items;
        if ~isempty(alternatives)
            index = find(ismember(value,alternatives));
            if isempty(index)
                handle.Value = {};
            else
                handle.Value = alternatives(index);
            end
        end

    elseif isa(handle,'matlab.ui.control.CheckBox') || ...
            isa(handle,'matlab.ui.control.RadioButton')

        handle.Value = value;

    else    

        varargin = lower(varargin); 
        style    = get(handle, 'style');
        switch lower(style)
            case {'edit', 'text'}
                if any(strcmpi('integer', varargin))
                    value = int2str(value);
                elseif any(strcmpi('numeric', varargin))
                    value = num2str(value);
                elseif any(strcmpi('logical', varargin))
                    value = int2str(double(value));
                elseif any(strcmpi('nb_date', varargin))
                    value = toString(value);    
                end
                set(handle, 'String', value);     
            case 'popupmenu'
                nb_setPopupValue(handle, value, varargin{:});
            case {'checkbox', 'radiobutton'}
                set(handle, 'Value', value);
            otherwise
                warning(['uicontrols of type ' style ' is not supported']);
        end

    end

end

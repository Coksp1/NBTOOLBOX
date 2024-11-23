function set(obj,varargin)
% Syntax:
%
% obj = set(obj,varargin)
%
% Description:
%
% Sets the properties of the nb_selectionPanel object.
%
% Input:
%
% - obj      : A nb_selectionPanel object.
%
% Optional input:
%
% - varargin : ...,'inputName',inputValue,... arguments.
%
%                 Where you can set some properties of the object.
%
% Output:
%
% - obj      : A nb_selectionPanel object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    for ii = 1:2:size(varargin,2)
        
        propertyName  = varargin{ii};
        propertyValue = varargin{ii + 1};
        
        switch lower(propertyName)
            
            case 'string'
                
                if ~iscellstr(propertyValue)
                    error(['The property ' propertyName ' must be set to a cellstr array.'])
                end
                
                set(obj.selListbox,'string',propertyValue,...
                                   'max',length(propertyValue),...
                                   'value',1);
                               
            case 'value'
                if ~isdouble(propertyValue)
                    error(['The property ' propertyName ' must be a double.'])
                end
                
                set(obj.selListBox,'value',propertyValue);
                
            otherwise
                
                error(['Unsupported property ' propertyName ' or you are not able to set it.'])
                
        end
        
    end

end

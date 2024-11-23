function TF = nb_isfield(obj, varargin)
% Syntax:
%
% TF = nb_isfield(obj, varargin)
%
% Description:
%
% Recursive expansion of isfield.
% 
% Input:
% 
% - obj : An object of class nb_struct.
% 
% Output:
% 
% - TF : true if the fieldnames provided are recursive fields of the 
%        nb_struct.
%
% Examples:
%
% s.fieldLevelOne.fieldLevelTwo = 'valueLevelTwo';
% TF = nb_isfield(s, 'fieldLevelOne', 'fieldLevelTwo');
%
% See also:
% nb_struct.isfield
%
% Written by Henrik Hortemo Halvorsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    TF    = false;
    index = 1;
    s     = obj.s;
    while index <= length(varargin)        
        field = varargin{index};
        TF    = isfield(s, field);
        if not(TF)
            return
        end
        s     = s.(field);
        index = index + 1;
    end
    
end

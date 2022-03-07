function TF = nb_isfield(s, varargin)
% Syntax:
%
% TF = nb_isfield(s, varargin)
%
% Description:
%
% Recursive expansion of isfield.
% 
% Input:
% 
% - s  : A struct.
% 
% Output:
% 
% - TF : true if the fieldnames provided are recursive fields of the 
%        struct.
%
% Examples:
%
% s.fieldLevelOne.fieldLevelTwo = 'valueLevelTwo';
% TF = nb_isfield(s, 'fieldLevelOne', 'fieldLevelTwo');
%
% See also:
% isfield
%
% Written by Henrik Hortemo Halvorsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    TF    = false;
    index = 1;
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

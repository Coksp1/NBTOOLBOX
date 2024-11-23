function s = assignAll(s,field,value)
% Syntax:
%
% s = assignAll(s,field,value)
%
% Description:
%
% Assign all elements of an array of struct objects.
%
% PS: This is the same as doing;
%     [s(:).fieldName] = deal(value)
% 
% Input:
% 
% - s     : A N x M x P struct.
% 
% - field : The field to assign of all elements.
%
% - value : The value to assign to all elements.
%
% Examples:
%
% s(3) = struct('fieldName',4);
% s    = assignAll(s,'fieldName',2);
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~nb_isOneLineChar(field)
        error('The field input must be a one line char!')
    end
    [s(:).(field)] = deal(value);

end
    

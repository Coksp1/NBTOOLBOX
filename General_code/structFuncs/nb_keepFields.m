function s = nb_keepFields(s, fields)
% Syntax:
%
% s = nb_keepFields(s, fields)
%
% Description:
%
% Keep selected fields of struct.
% 
% Input:
% 
% - s      : A struct.
% 
% - fields : A cellstr.
%
% Output:
% 
% - s : A struct.
%
% Written by Henrik Hortemo Halvorsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    s = rmfield(s, setdiff(fieldnames(s), fields));
    
end

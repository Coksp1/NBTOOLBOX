function string = nb_input2String(anyObject)
% Syntax:
%
% string = nb_input2String(anyObject)
%
% Description:
%
% Converts a input into a string. This function is used by the method 
% getMethodCalls of the classes nb_ts, nb_cs and nb_data.
%
% Caution : Some inputs that are classified as not editable will be
% returned as a string, i.e. 'Not editable'.
% 
% Input:
% 
% - anyObject : Any type of object
% 
% Output:
% 
% - string    : A string
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if iscellstr(anyObject)
        string = ['{' nb_cellstr2String(anyObject,' \\ ') '}'];
    elseif isa(anyObject,'nb_date')
        string = toString(anyObject);
    elseif isnumeric(anyObject) && numel(anyObject) == 1
        string = num2str(anyObject); 
    elseif ischar(anyObject)
        string = anyObject;    
    else
        string = 'Not editable';
    end

end

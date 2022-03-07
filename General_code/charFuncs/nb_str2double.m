function num = nb_str2double(string)
% Syntax:
%
% num = nb_str2double(string)
%
% Description:
%
% Convert a string to double. Added the possibility to convert a interval
% from a string to a double compared to str2double. See examples
%
% Input:
% 
% - string : A string.
% 
% Output:
% 
% - num    : A double
%
% Examples:
% nb_str2double('2')
% nb_str2double('1:3')
% nb_str2double('[1,3]')
% nb_str2double('[1:3,6]')
%
% See also:
% str2double
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    indC  = strfind(string,':');
    indBO = strfind(string,'[');
    if isempty(indC) && isempty(indBO)
        num = str2double(string);
    elseif isempty(indC)
        
        indBC = strfind(string,']');
        if isempty(indBC)
            num = nan;
            return
        end
        stringN  = string(indBO+1:indBC-1);
        splitted = regexp(stringN,',','split');
        N        = length(splitted);
        num      = nan(1,N);
        for ii = 1:N
            num(ii) = str2double(splitted{ii});
        end
        
    elseif isempty(indBO)
        
        string1 = string(1:indC-1);
        string2 = string(indC+1:end);
        num1    = str2double(string1);
        num2    = str2double(string2);
        num     = num1:num2;
        
    else
        
        indBC = strfind(string,']');
        if isempty(indBC)
            num = nan;
            return
        end
        stringN  = string(indBO+1:indBC-1);
        splitted = regexp(stringN,',','split');
        N        = length(splitted);
        num      = [];
        for ii = 1:N
            num = [num,nb_str2double(splitted{ii})]; %#ok<AGROW>
        end
        
    end
        
end

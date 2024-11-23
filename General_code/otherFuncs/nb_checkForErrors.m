function str = nb_checkForErrors(expression,macro)
% Syntax:
%
% str = nb_checkForErrors(expression,macro)
%
% Description:
%
% Check for basic errors in an expression to be interpreted by the 
% shunting yard algorithm.
% 
% Input:
% 
% - expression : A char with the expression to be interpreted.
% 
% - macro      : Set to true to also handle the NB Toolbox macro processing
%                language as well. Default is false.
%
% Output:
% 
% - str        : If a non-empty char is returned, the expression cannot
%                be interpreted by the shunting yard algorithm.
%
% See also:
% nb_shuntingYardAlgorithm
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        macro = false;
    end

    if ~ischar(expression)
       str = 'The expression input must be a string.';
       return
    end

    % Check for unsupported chars
    if macro
        ind = regexp(expression,'[§£¤$%?`\´¨;]','once');
    else
        ind = regexp(expression,'[§#£¤$%?`\´¨{}]','once');
    end
    if ~isempty(ind)
        if macro
            str = 'The following characters is not supported; § £ ¤ $ %% & ? ` \\ ´ ¨ ;';
        else
            str = 'The following characters is not supported; ! § # £ ¤ $ %% { } ? ` \\ ´ ¨';
        end
        return
    end
    
    % Check for missing parentheses
    str = checkParentheses(expression);
           
end

%==========================================================================
function strError = checkParentheses(string)

    indO = strfind(string,'(');
    indC = strfind(string,')');
    if isempty(indC) && ~isempty(indO)
        strError = 'Missing parentheses; )';
        return
    elseif ~isempty(indC) && isempty(indO)
        strError = 'Missing parentheses; (';
        return
    elseif isempty(indC) && isempty(indO)
        strError = '';
        return
    end
          
    count      = 0;
    firstfound = 0;
    startparen = 1;
    endparen   = 0;
    for jj = 1:length(string)

        strcleft  = strncmp(string(jj),'(',1);
        strcright = strncmp(string(jj),')',1);
        if strcleft
            if count == 0
               firstfound = 1;
               startparen = jj;
            end
            count = count + 1;
        end
        if strcright
            count = count - 1;
        end

        if count == 0 && firstfound == 1
            endparen = jj;
            break;
        end
        
    end
    
    if jj == length(string) && endparen ~= jj
        strError = 'Missing parentheses; )';
        return
    end
    
    s  = string(startparen:endparen);
    if isempty(s)
        strError = '';
    else
        strError = checkParentheses(string(endparen+1:end));       
    end
       
end

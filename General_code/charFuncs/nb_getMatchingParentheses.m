function match = nb_getMatchingParentheses(expr,reverse)
% Syntax:
%
% match = nb_getMatchingParentheses(expr,reverse) 
%
% Description:
%
% Find index of matching parentheses.
% 
% Input:
% 
% - expr : A one-line char that starts with (.
% 
% - reverse : Set to true to match in from end to start. Default is false. 
%
% Output:
% 
% - match : A 1 x 2 integer with the index of the matching parentheses 
%           in expr. Will be given as [0,0], if not located.
%
% Examples:
%
% match = nb_getMatchingParentheses('(y*x+(1-y)*x)') 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        reverse = false;
    end

    if reverse
        
        indC = strfind(expr,')');
        if ~nb_contains(expr,'(')
            match = [0,0];
            return
        elseif isempty(indC)
            error([mfilename ':: The expression must contain at least one )'])  
        end

        count = 0;
        first = false;
        match = [0,indC(end)];
        for jj = length(expr):-1:1

            strcleft  = strncmp(expr(jj),'(',1);
            strcright = strncmp(expr(jj),')',1);
            if strcright
                count = count + 1;
                first = true;
            end
            if strcleft && first
                count = count - 1;
            end
            if count == 0 && first
                match(1) = jj;
                break
            end

        end
        
    else
    
        indO = strfind(expr,'(');
        if ~nb_contains(expr,')')
            match = [0,0];
            return
        elseif isempty(indO)
            error([mfilename ':: The expression must contain at least one ('])  
        end

        count = 0;
        first = false;
        match = [indO(1),0];
        for jj = 1:length(expr)

            strcleft  = strncmp(expr(jj),'(',1);
            strcright = strncmp(expr(jj),')',1);
            if strcleft
                count = count + 1;
                first = true;
            end
            if strcright && first
                count = count - 1;
            end
            if count == 0 && first
                match(2) = jj;
                break
            end

        end
        
    end
    
end

function [breaks,split,addPar] = nb_splitIntoTerms(expr,op,notOp)
% Syntax:
%
% breaks                = nb_splitIntoTerms(expr)
% [breaks,split,addPar] = nb_splitIntoTerms(expr,op,notOp)
%
% Description:
%
% Split a mathematical expression into seperate terms.
% 
% Input:
% 
% - expr  : A one-line char that include a mathematical expression.
% 
% - op    : Operators to split at. Default is {'+','-'}. Must be a cellstr.
%
% - notOp : Operators that will invalidates break-points if just in front
%           of any operator in op. Default is {'*','^','/'}. Must be a 
%           cellstr.
%
% Output:
% 
% - breaks : The indexes of '+' and '-' signs.
%
% - split  : A nBreaks + 1 cell array.
%
% - addPar : The expression should be enclosed with parentheses again. 
%
% Examples:
%
% [breaks,split,addPar] = nb_splitIntoTerms('y*x+(1-y)*x') 
% [breaks,split,addPar] = nb_splitIntoTerms('(y*x+(1-y)*x)') 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        notOp = {'*','^','/'};
        if nargin < 2
            op = {'+','-'};
        end
    end
    type1  = '(';
    type2  = ')';
    addPar = false;
    match  = nb_getMatchingParentheses(expr);
    if match(1) == 1 && match(2) == size(expr,2)
        expr   = expr(2:end-1);
        addPar = true;
    end

    breakTerm  = false(1,length(expr));
    numOpen    = 0;
    numClosed  = 0;
    for ii = 1:length(expr)

        if strncmp(expr(ii),type1,1)
            numOpen   = numOpen + 1;
            continue
        end
        if strncmp(expr(ii),type2,1)
            numClosed = numClosed + 1;
            continue
        end
        if any(strncmp(expr(ii),op,1)) && numOpen - numClosed == 0
            breakTerm(ii) = true;
        end
        if ii > 2
            if any(strncmp(expr(ii-1),notOp,1))
                breakTerm(ii) = false;
            end
        end

    end
    breaks = find(breakTerm);

    if nargout > 1
        
        nBreaks = size(breaks,2);
        split   = cell(1,nBreaks + 1);
        breaksT = [0,breaks];
        for ii = 2:nBreaks+1
            split{ii-1} = expr(breaksT(ii-1)+1:breaksT(ii)-1);
        end
        split{end} = expr(breaksT(end)+1:end);
        
    end
    
end

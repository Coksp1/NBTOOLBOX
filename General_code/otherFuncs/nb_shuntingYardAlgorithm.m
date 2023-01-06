function [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression,variables,macro,out,stack,prec,nInp,nInpStack,last)
% Syntax:
%
% [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(...
%           expression,variables,macro)
% [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(...
%           expression,variables,macro,out,stack,prec,nInp,nInpStack,last)
%
% Description:
%
% MATLAB implementation of the shunting yard algorithm for interpreting
% a mathematical expression.
% 
% Input:
% 
% - expression : The expression to interpret. As a 1 x n char.
%
% - variables  : The list of variables of the function that the expression
%                consists of.
% 
% - macro      : Set to true to also handle the NB Toolbox macro processing
%                language as well. Default is false.
%
% The rest of the inputs is used internally in this function. 
%
% Output:
% 
% - str        : If a non-empty char is returned, the expression cannot
%                be interpreted by the shunting yard algorithm.
%
% - out        : A cell with the interpretation of the expression.
%
% - nInp       : Number of inputs to each function.
%
% See also:
% nb_eval, nb_checkForErrors
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin == 3
        stack      = {};
        out        = {};
        prec       = [];
        nInp       = [];
        nInpStack  = [];
        last       = true;
        expression = regexprep(expression, '\s+',''); % Remove all white spaces
    elseif nargin ~= 9
        error([mfilename ':: Either 3 or 9 inputs must be given to this function.'])
    end
    
    if isempty(expression)
        % End of expression so we pop all the rest from the stack
        out  = [out,stack];
        nInp = [nInp,nInpStack];
        str  = '';
        return
    end
    
    % Is a variable
    ind = isType(expression,variables,true); 
    if ~isempty(ind) 

        last  = false;
        check = regexp(expression,['^' ind '[\(\[][\w\d\:,]+[\)\]]'],'match');
        if ~isempty(check)
            ind = check{1};
        end
        indE = size(ind,2);
        out  = [out,ind];
        nInp = [nInp,0];
        [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
        return
        
    end
    
    % Is a date, type or a genaral string (Can be used as inputs to different functions)
    if ~macro
        
        ind = regexp(expression,'^"[\w\d:]+"{0,1}','match');
        if ~isempty(ind)

            last = false;
            indE = size(ind{1},2);
            out  = [out,ind];
            nInp = [nInp,0];
            [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
            return

        end
        
    end
    
    % Is a function
    [ind,indE] = regexp(expression,'^\w[\w\.]*(','match','end');
    if ~isempty(ind) 
        
        last      = true;
        nInpT     = findNumberOfInputs(expression);
        func      = expression(1:indE-1);
        stack     = [func,stack];
        nInpStack = [nInpT,nInpStack];
        prec      = [0,prec];
        [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
        return
        
    end
        
    % Is a parentheses (
    ind = regexp(expression,'^(','match');
    if ~isempty(ind) 

        last      = true;
        func      = '(';
        stack     = [func,stack];
        nInpStack = [inf,nInpStack];
        prec      = [1,prec];
        [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(2:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
        return
        
    end
        
    % Is + or -
    ind = regexp(expression,'^[+-]','match');
    if ~isempty(ind) 

        if ~last
            [nInp,nInpStack] = popStack(nInp,nInpStack,prec,2);
            [out,stack,prec] = popStack(out,stack,prec,2);
            func             = ind; 
            stack            = [func,stack];
            nInpStack        = [2,nInpStack];
            prec             = [2,prec];
        else
            func             = ind; 
            stack            = [func,stack];
            nInpStack        = [1,nInpStack];
            prec             = [4,prec];
        end
        last = true;
        [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(2:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
        return
        
    end
    
    % Is |,||,& or &&
    ops = {'|','||','&','&&'};
    ind = isType(expression,ops,false);
    if ~isempty(ind) 

        [nInp,nInpStack] = popStack(nInp,nInpStack,prec,2);
        [out,stack,prec] = popStack(out,stack,prec,2);
        func             = ind; 
        stack            = [func,stack];
        nInpStack        = [2,nInpStack];
        prec             = [2,prec];
        last             = true;
        [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(size(ind,2)+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
        return
        
    end
        
    % Is ./ / .* or *
    ops = {'./','.*','/','*'};
    ind = isType(expression,ops,false); 
    if ~isempty(ind)

        last             = true;
        indE             = size(ind,2);
        [nInp,nInpStack] = popStack(nInp,nInpStack,prec,3);
        [out,stack,prec] = popStack(out,stack,prec,3);
        func             = ind; 
        stack            = [func,stack];
        nInpStack        = [2,nInpStack];
        prec             = [3,prec];
        [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
        return
        
    end
    
    % Is .^ ^    
    ops = {'.^','^'};
    ind = isType(expression,ops,false); 
    if ~isempty(ind) 

        last      = true;
        indE      = size(ind,2);
        func      = ind; 
        stack     = [func,stack];
        nInpStack = [2,nInpStack];
        prec      = [4,prec];
        [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
        return
        
    end
    
    % Is != ~= == <= >= (or macro version !)  
    ind = regexp(expression,'^[!~=\<\>]=','match');
    if ~isempty(ind) 

        last      = true;
        stack     = [ind,stack];
        nInpStack = [2,nInpStack];
        prec      = [4,prec];
        [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(3:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
        return
        
    end
    
    % Is ~ : (or macro version !)  
    ind = regexp(expression,'^[~!:><]','match');
    if ~isempty(ind) 

        last      = true;
        if strcmp(ind{1},'!') || strcmp(ind{1},'~')
            nInpT = 1;
        else
            nInpT = 2;
        end
        stack     = [ind,stack];
        nInpStack = [nInpT,nInpStack];
        prec      = [4,prec];
        [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(2:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
        return
        
    end

    % Is a number
    [num,indE] = regexp(expression,'^\d*\.{0,1}\d*','match','end');
    if ~isempty(num) && ~strcmp(num{1},'.')

        last = false;
        out  = [out,num];
        nInp = [nInp,0];
        [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
        return
        
    end
    
    % Is a string on the format, e.g. 'test'
    if macro % Support of the NB Toolbox macro language
    
        % Is a the in function (#)
        [ind,indE] = regexp(expression,'^\#','match','end');
        if ~isempty(ind) 

            last      = true;
            stack     = ['in',stack];
            nInpStack = [2,nInpStack];
            prec      = [0,prec];
            [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
            return

        end
        
        % Expression enclosed in {}
        [cstr,indE] = regexp(expression,'^{.+}','match','end');
        if ~isempty(cstr)
            
            last = false;
            out  = [out,cstr,cstr,'nb_macro'];
            nInp = [nInp,0,0,2];
            [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
            return
            
        end
        
        [cstr,indE] = regexp(expression,'^\[.+\]','match','end');
        if ~isempty(cstr)
            
            last = false;
            out  = [out,cstr,cstr,'nb_macro'];
            nInp = [nInp,0,0,2];
            [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
            return
            
        end
        
        [str,indE] = regexp(expression,'^''.+?''','match','end');
        if ~isempty(str) 

            last = false;
            out  = [out,str,str,'nb_macro'];
            nInp = [nInp,0,0,2];
            [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
            return

        end
        
        [str,indE] = regexp(expression,'^".+?"','match','end');
        if ~isempty(str) 

            last = false;
            out  = [out,str,str,'nb_macro'];
            nInp = [nInp,0,0,2];
            [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
            return

        end
        
    else
        
        % Is it a one line char?
        [str,indE] = regexp(expression,'^''.+?''','match','end');
        if ~isempty(str) 

            last = false;
            out  = [out,str];
            nInp = [nInp,0];
            [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
            return

        end
        
        % Is it a function handle?
        if strncmp(expression,'@',1)

            indEP = strfind(expression,')');
            if size(indEP,2) > 1
                indE  = indEP(2);
                last  = false;
                try %#ok<TRYNC>
                    out   = [out,{expression(1:indE)}];
                    nInp  = [nInp,0];
                    [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
                    return
                end
                
            end

        end
        
        % Is it a matrix enclosed in []
        [cstr,indE] = regexp(expression,'^\[.+\]','match','end');
        if ~isempty(cstr)
            
            last = false;
            out  = [out,cstr];
            nInp = [nInp,0];
            [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
            return
            
        end
        
    end % macro
             
    % New input to function
    ind = regexp(expression,'^,','match');
    if ~isempty(ind) 

        last             = true;
        [nInp,nInpStack] = popStack(nInp,nInpStack,prec,1);
        [out,stack,prec] = popStack(out,stack,prec,1);
        out              = [out,',']; % Idicate more input into function
        nInp             = [nInp,0];
        [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(2:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
        return
        
    end

    % End of function or grouped expression
    ind = regexp(expression,'^)','match');
    if ~isempty(ind) 
        last             = false;
        [nInp,nInpStack] = popStackClose(nInp,nInpStack,prec,1,0);
        [out,stack,prec] = popStackClose(out,stack,prec,1,0);
        [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(2:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
        return
    end
    
    % true
    ind = regexp(expression,'^true','match');
    if ~isempty(ind) 
        last = false;
        out  = [out,'true'];
        nInp = [nInp,0];
        indE = 4;
        [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
        return
    end
    
    % false
    ind = regexp(expression,'^false','match');
    if ~isempty(ind) 
        last = false;
        out  = [out,'false'];
        nInp = [nInp,0];
        indE = 5;
        [str,out,nInp,stack,nInpStack,prec] = nb_shuntingYardAlgorithm(expression(indE+1:end),variables,macro,out,stack,prec,nInp,nInpStack,last);
        return
    end
    
    problem = regexp(expression,'^\w+','match');
    if ~isempty(problem)
        str = ['The following variable/type is not in the data; ' problem{1}];    
    else
        str = ['Could not evaluate the following part of the expression; ' expression];
    end

end

%==========================================================================
function [out,stack,prec] = popStack(out,stack,prec,level)

    if isempty(prec)
        return
    end

    ind = find(level > prec,1,'first');
    if isempty(ind)
        ind = length(prec);
    else
        ind = ind - 1;
    end
%     check = prec(1:ind-1);
%     if any(check < level)
%         return
%     end
    temp  = stack(1:ind);
    if isnumeric(temp)
        indB = ~isfinite(temp);
    else
        indB = strcmp('(',temp); 
    end
    temp  = temp(~indB);
    out   = [out,temp];
    stack = stack(ind+1:end);
    prec  = prec(ind+1:end);
    
end

%==========================================================================
function [out,stack,prec] = popStackClose(out,stack,prec,level1,level2)

    ind1  = find(level1 == prec,1);
    ind2  = find(level2 == prec,1);
    if isempty(ind1) && isempty(ind2)
        return
    elseif isempty(ind1)
        ind = ind2;
    elseif isempty(ind2)
        ind = ind1;
    else
        ind = min(ind1,ind2);
    end
    temp  = stack(1:ind);
    if isnumeric(temp)
        indB = ~isfinite(temp);
    else
        indB = strcmp('(',temp); 
    end
    temp  = temp(~indB);
    out   = [out,temp];
    stack = stack(ind+1:end);
    prec  = prec(ind+1:end);
    
end

%==========================================================================
function ind = isType(expression,ops,variable)

    ind = '';
    ops = fliplr(ops);
    if variable
        first   = cellfun(@(str)str(1,1),ops);
        check   = first == expression(1);
        ops     = ops(check);
        opsPar  = strrep(ops,'(','\(');
        opsPar  = strrep(opsPar,')','\)');
        opsExpr = strcat('^',opsPar,'(?![A-Za-z_])');
        for ii = 1:length(ops)
            indF = regexp(expression,opsExpr{ii},'start');
            if ~isempty(indF)
                ind = ops{ii};
                break
            end
        end
    else
        for ii = 1:length(ops)
            n    = size(ops{ii},2);
            indF = strncmp(expression,ops{ii},n);
            if indF
                ind = ops{ii};
                break
            end
        end
    end
        
end

function nInp = findNumberOfInputs(expression)

    match = nb_getMatchingParentheses(expression);
    indO  = regexp(expression,'[\[\(]');
    indC  = regexp(expression,'[\]\)]');
    indO  = indO(indO > match(1) & indO < match(2));
    indC  = indC(indC < match(2));
    indD  = strfind(expression(1:match(2)),',');
    if isempty(indD)
        nInp = 1;
        return
    end
    if isempty(indO)
        indD = indD(indD > match(1) & indD < match(2));
        nInp = length(indD) + 1;
    elseif size(indO,2) == 1
        indD = indD(indD < indO | indD > indC);
        nInp = size(indD,2) + 1;
    else
        indDF  = indD(indD < indO(1));
        nInp   = size(indDF,2) + 1;
        open   = 1;
        iOpen  = 2;
        iClose = 1;
        iComma = size(indDF,2) + 1;
        for ii = indO(1)+1:match(2)
            if indO(iOpen) == ii
                open = open + 1;
                iOpen = min(iOpen + 1,size(indO,2));
            end
            if indC(iClose) == ii
                open   = open - 1;
                iClose = min(iClose + 1,size(indC,2));
            end
            if indD(iComma) == ii 
                if open == 0
                    nInp = nInp + 1;
                end
                iComma = min(iComma + 1,size(indD,2));
            end
        end
    end

end



function obj = split(expr,waitbar)
% Syntax:
%
% obj = nb_term.split(expr)
% obj = nb_term.split(expr,waitbar)
%
% Description:
%
% Split the mathematical expression into separate terms.
% 
% Input:
% 
% - expr    : A one line char with a mathematical expression.
% 
% - waitbar : A nb_waitbar5 object. If empty no waitbar is added.
%
% Output:
% 
% - obj  : A nb_term object representing the mathematical expression.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    if nargin < 2
        waitbar = [];
    end
    
    if iscellstr(expr) 
        if isscalar(expr)
            expr = expr{1};
        else
            if isempty(waitbar)
                obj = nb_callMethod(expr,@nb_term.split,@nb_num);
            else
                obj = nb_callMethodWaitbar(expr,@nb_term.split,@nb_num,waitbar);
            end
            return
        end
    end
    expr = nb_term.correct(expr);
    obj  = splitSub(expr);
    
end

%==========================================================================
function obj = splitSub(expr)

    if iscellstr(expr)
        obj = nb_term.initialize(length(expr),1);
        for ii = 1:length(expr)
            obj(ii) = splitSub(expr{ii});
        end
        return
    end

    % Is it a number?
    expr = nb_term.removePar(expr);
    num  = str2double(expr);
    if ~isnan(num) && isreal(num)
        obj = nb_num(num);
        return
    end
    
    % Any + or - signs to split the expr at?
    [breaks,split] = nb_splitIntoTerms(expr);
    if ~isempty(breaks)
        if isempty(split{1})
            signs = cellstr(expr(breaks)')';
            split = split(2:end);
        else
            signs = ['+',cellstr(expr(breaks)')'];
        end
        mInd        = strcmp(signs,'-');
        split(mInd) = strcat('(-1)*',split(mInd));
        terms       = splitSub(split); % Split terms recursivly
        obj         = plus(terms);
        return
    end
    
    % Any * or / signs to split the expr at?
    [breaks,split] = nb_splitIntoTerms(expr,{'*','/'},{});
    if ~isempty(breaks)
        if isempty(split{1})
            signs = cellstr(expr(breaks)')';
            split = split(2:end);
        else
            signs = ['*',cellstr(expr(breaks)')'];
        end
        dInd        = strcmp(signs,'/');
        split(dInd) = strcat(split(dInd),'^(-1)');
        terms       = splitSub(split); % Split terms recursivly
        obj         = times(terms);
        return
    end
    
    % Any ^ or minus signs to split the expr at?
    [breaks,split] = nb_splitIntoTerms(expr,{'^'},{});
    if ~isempty(breaks)
        terms = splitSub(split); % Split terms recursivly
        obj   = power(terms);
        return
    end
    
    % Are we dealing with a function?
    match = regexp(expr,'^\w{1,1}.*\([\w\d]{1,1}.*\)$','match');
    if ~isempty(match)
        match  = match{1};
        indO   = strfind(match,'(');
        indC   = strfind(match,')');
        inputs = strsplit(match(indO(1)+1:indC(end)-1),',');
        func   = str2func(match(1:indO(1)-1));
        terms  = nb_obj2cell(splitSub(inputs)); % Split terms recursivly
        obj    = func(terms{:});
        return
    end
    
    % We are dealing with a base value
    obj = nb_base(expr);
    
end

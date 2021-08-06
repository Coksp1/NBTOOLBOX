function obj = callTimesOnSub(obj,another)
% Syntax:
%
% obj = callTimesOnSub(obj,another)
%
% See also:
% nb_term.plus
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isa(obj,'nb_equation')
        temp    = obj;
        obj     = another;
        another = temp;
    end
    if isnumeric(another)
        another = nb_num(another);
    end

    if isa(obj,'nb_equation') && isa(another,'nb_base')
        % E.g: (2*x * y) * x -> 2*x^2*y
        % E.g: (2 + x) * x -> 2*x + x^2
        obj = timesEqAndBase(obj,another);
    elseif isa(obj,'nb_equation') && isa(another,'nb_num')
        % E.g: (x+y)*2 -> 2*x + 2*y
        % E.g: (x*y)*2 -> 2*x*y
        % E.g: (2*x)*2 -> 4*x
        obj = timesEqAndNum(obj,another);
    else
        % Check for eq*(eq)^-1 -> 1, eq^2*eq^1 -> eq^3
        [ret,obj] = equalToThePower(obj,another);  
        if ~ret
            % E.g: (2*x * y) * (x * -1*y) -> -2*x^2*y^2
            % E.g: 2*x * 3*x -> 6*x^2
            % E.g: (2 + x) * (2 + x) -> 4 + 4*x + x^2
            obj = timesEqAndEq(obj,another);
        end
    end
        
end

%==========================================================================
function obj = timesEqAndBase(obj,another)

    if strcmp(obj.operator,'+') 
        % E.g: (2*x + y) * x -> 2*x^2 + x*y
        obj = multiplyIntoPar(obj,another);
    elseif strcmp(obj.operator,'*') 
        % E.g: (2*x * y) * x -> 2*x^2*y
        obj = timesEqualTerms(obj,another);
    elseif strcmp(obj.operator,'^')
        terms = obj.terms;
        if obj.numberOfTerms == 2 && terms(1) == another
            % E.g: (x^2) * x -> x^3
            % E.g: (x^y) * x -> x^(y+1)
            terms(2) = callPlusOnSub(terms(2),nb_num(1));
            if obj.terms(2) == 0
                obj = nb_num(1);
            else
                obj = nb_equation('^',terms);
            end
        else
            obj = nb_equation('*',[obj,another]);
        end
    else
        obj = timesEqualTerms(obj,another);
    end
        
end

%==========================================================================
function obj = timesEqAndNum(obj,another)

    if strcmp(obj.operator,'+')
        % E.g: (2 + x) * 2 -> 4 + 2*x
        obj = multiplyIntoPar(obj,another);
    elseif strcmp(obj.operator,'*')
        % E.g: (2 * x) * 2 -> 4*x
        % E.g: (2 * x) * x -> 2*x^2
        obj = timesEqualTerms(obj,another);
    elseif strcmp(obj.operator,'^')
        terms = obj.terms;
        if obj.numberOfTerms == 2 && terms(1) == another
            % E.g: (2^x) * 2 -> 2^(x+1)
            terms(2)  = callPlusOnSub(terms(2),nb_num(1));
            obj.terms = terms;
        else
            obj = nb_equation('*',[another,obj]);
        end
    else
        obj = timesEqualTerms(obj,another);
    end

end

%==========================================================================
function obj = timesEqAndEq(obj,another)

    if strcmp(obj.operator,'+') 
        if strcmp(another.operator,'+')
            % E.g: (2 + x) * (2 + x) -> 4 + 4*x + x^2
            obj = obj(ones(another.numberOfTerms,1));
            for ii = 1:another.numberOfTerms
                obj(ii) = multiplyIntoPar(obj(ii),another.terms(ii));
            end
            obj = plus(obj);
        else
            % E.g: (2 + x) * 2*x -> 4*x + 2*x^2
            obj = multiplyIntoPar(obj,another);
        end
    elseif strcmp(obj.operator,'*') 
        if strcmp(another.operator,'+')
            % E.g: (2*x * y) * (x + y) -> 2*x^2 * y + 2*x * y^2
            obj = multiplyIntoPar(another,obj);
        else
            % E.g: (2*x * y) * (x * y) -> 2*x^2*y^2
            obj = timesEqualTerms(obj,another);
        end 
    elseif strcmp(obj.operator,'^')
        terms = obj.terms;
        if obj.numberOfTerms == 2 && terms(1) == another
            % E.g: ((2 + x)^x) * (2 + x) -> (2 + x)^(x+1)
            terms(2)  = callPlusOnSub(terms(2),nb_num(1));
            obj.terms = terms;
        else
            obj = timesEqualTerms(obj,another);
        end   
    else
        obj = timesEqualTerms(obj,another);
    end
        
end

%==========================================================================
function obj = multiplyIntoPar(obj,another)

    terms = obj.terms;
    for ii = 1:obj.numberOfTerms
        terms(ii) = callTimesOnSub(terms(ii),another);
    end
    obj.terms = terms;

end

%==========================================================================
function obj = timesEqualTerms(obj,another)

    [num,eqs]   = seperateTerms(obj,'*');
    [numA,eqsA] = seperateTerms(another,'*');
    eqsCell     = cellstr(eqs);
    eqsACell    = cellstr(eqsA);
    [ind,loc]   = ismember(eqsACell,eqsCell);
    loc         = loc(ind);
    locA        = find(ind);
    newTerms    = eqs;
    kk          = 1;
    for ii = 1:size(eqs,1)
        if any(ii == loc) 
            newNum = num(ii) + numA(locA(kk));
            kk     = kk + 1;
        else
            newNum = num(ii);
        end
        newTerms(ii) = power(eqs(ii),newNum);
    end
    if any(~ind)
        eqsARest = eqsA(~ind);
        numARest = numA(~ind);
        for ii = 1:size(eqsARest,1)
            eqsARest(ii) = power(eqsARest(ii),numARest(ii));
        end
        newTerms = [newTerms;eqsARest];
    end
    obj.operator = '*'; 
    obj.terms    = newTerms; % Will be sorted in set.terms
    
end

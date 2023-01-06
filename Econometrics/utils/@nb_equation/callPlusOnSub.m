function obj = callPlusOnSub(obj,another)
% Syntax:
%
% obj = callPlusOnSub(obj,another)
%
% See also:
% nb_term.plus
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isa(obj,'nb_equation')
        temp    = obj;
        obj     = another;
        another = temp;
    end
    if isnumeric(another)
        another = nb_num(another);
    end

    if isa(obj,'nb_equation') && isa(another,'nb_base')
        obj = plusEqAndBase(obj,another);
    elseif isa(obj,'nb_equation') && isa(another,'nb_num')
        obj = plusEqAndNum(obj,another);
    else
        % E.g: (2*x + y) + (x + -1*y) -> 3*x
        % E.g: 2*x + 3*x -> 5*x
        obj = plusEqualTerms(obj,another);
    end
        
end

%==========================================================================
function obj = plusEqAndBase(obj,another)

    if strcmp(obj.operator,'+') 
        % (2*x + y) + x -> 3*x + y
        obj = plusEqualTerms(obj,another);
    elseif strcmp(obj.operator,'*') 

        terms = obj.terms;
        if obj.numberOfTerms == 2 && isa(terms(1),'nb_num') && terms(2) == another % nb_num is allways ordered first!
            % 2*x + x -> 3*x
            obj.terms(1) = callPlusOnSub(terms(1),nb_num(1));
            if obj.terms(1) == 0
                obj = nb_num(0);
            end
        else
            obj = nb_equation('+',[obj;another]);
        end

    else
        obj = plusEqualTerms(obj,another);
    end
        
end

%==========================================================================
function obj = plusEqAndNum(obj,another)

    if strcmp(obj.operator,'+') 
        if isa(obj.terms(1),'nb_num')
            % 1 + expr + 2 -> 3 + expr
            obj.terms(1) = callPlusOnSub(obj.terms(1),another);
        else
            obj = nb_equation('+',[obj,another]);
        end
    else
        obj = plusEqualTerms(obj,another);
    end

end

%==========================================================================
function obj = plusEqualTerms(obj,another)

    [num,eqs]   = seperateTerms(obj,'+');
    [numA,eqsA] = seperateTerms(another,'+');
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
        newTerms(ii) = times(eqs(ii),newNum);
    end
    if any(~ind)
        eqsARest = eqsA(~ind);
        numARest = numA(~ind);
        for ii = 1:size(eqsARest,1)
            eqsARest(ii) = times(numARest(ii),eqsARest(ii));
        end
        newTerms = [newTerms;eqsARest];
    end
    obj.operator = '+'; 
    obj.terms    = newTerms; % Will be sorted in set.terms
    
end

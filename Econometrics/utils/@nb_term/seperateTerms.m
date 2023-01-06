function [num,eqs] = seperateTerms(obj,op)
% Syntax:
%
% [num,eqs] = seperateTerms(obj,op)
%
% Description:
%
% Separate out the nb_num part of a nb_term object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(obj,'nb_base')
        num = nb_num(1); 
        eqs = obj;
        return
    elseif isa(obj,'nb_num')
        if strcmp(op,'+')
            num = obj;
            eqs = nb_num(1);
        else
            num = nb_num(1);
            eqs = obj;
        end
        return
    end

    if strcmp(op,'+')
    
        if strcmp(obj.operator,'+')
            numTerms        = obj.numberOfTerms;
            num(numTerms,1) = nb_num;
            eqs             = obj.terms;
            for ii = 1:numTerms
                [num(ii),eqs(ii)] = doOneTerm(eqs(ii));
            end
        else
            if isa(obj.terms(1),'nb_num') && strcmp(obj.operator,'*') % nb_num is allways ordered first!
                % num*eq
                num = obj.terms(1);
                if obj.numberOfTerms == 2
                    eqs = obj.terms(2);
                else
                    eqs = nb_equation('*',obj.terms(2:end));
                end
            else
                num = nb_num(1); 
                eqs = obj;
            end
        end
        
    else % op == '*'
        
        if strcmp(obj.operator,'*')
            numTerms        = obj.numberOfTerms;
            num(numTerms,1) = nb_num;
            eqs             = obj.terms;
            for ii = 1:numTerms
                [num(ii),eqs(ii)] = doOneMultTerm(obj.terms(ii));
            end
        else
            if obj.numberOfTerms == 2 && strcmp(obj.operator,'^')
                % eq^num or eq^(expr)
                num = obj.terms(end);
                eqs = obj.terms(1);
            else
                num = nb_num(1); 
                eqs = obj;
            end
        end
        
    end
    
end

%==========================================================================
function [num,eq] = doOneTerm(obj)

    if isempty(obj.terms)
        num = nb_num(1); 
        eq  = obj;
        return
    end

    if any(strcmp(obj.operator,{'+','*'}))
        if isa(obj.terms(1),'nb_num')
            num = obj.terms(1);
            s   = 2;
        else
            num = nb_num(1); 
            s   = 1;
        end
        if obj.numberOfTerms == s
            % 2*x -> 2 and x
            eq = obj.terms(s:end);
        else
            eq = obj;
            if s == 2
                % 2*expr -> 2 and expr
                eq.terms = eq.terms(2:end);
            end
        end
    else
        num = nb_num(1); 
        eq  = obj;
    end
        
end

%==========================================================================
function [num,eq] = doOneMultTerm(obj)

    if isempty(obj.terms)
        num = nb_num(1); 
        eq  = obj;
        return
    end

    if strcmp(obj.operator,'^')
        num = obj.terms(end);
        if obj.numberOfTerms == 2
            eq  = obj.terms(1);
        else
            eq       = obj;
            eq.terms = eq.terms(1:end-1);
        end
    else
        num = nb_num(1); 
        eq  = obj;
    end
        
end

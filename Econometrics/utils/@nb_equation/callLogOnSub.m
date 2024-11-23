function obj = callLogOnSub(obj)
% Syntax:
%
% obj = callLogOnSub(obj)
%
% See also:
% nb_term.log
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    switch obj.operator 
        case '*'
            
            % log(x*y) -> log(x) + log(y)
            terms = obj.terms;
            for ii = 1:obj.numberOfTerms
                terms(ii) = callLogOnSub(terms(ii));
            end
            obj.terms    = terms;
            obj.operator = '+';
            
        case '^'
            
            % log(x^y) -> y*log(x)
            term1 = obj.terms(1);
            term1 = callLogOnSub(term1);
            term2 = obj.terms(2:end);
            if size(term2,1) > 1
                term2 = nb_equation('^',term2);
            end
            obj.terms    = [term2;term1];
            obj.operator = '*';    
            
        case 'exp'
            
            % log(exp(x)) -> x
            obj = obj.terms;
            
        otherwise
            
            % log(expr) -> log(expr)
            obj = nb_equation('log',obj);
            
    end
    
    
end

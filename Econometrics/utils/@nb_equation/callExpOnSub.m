function obj = callExpOnSub(obj)
% Syntax:
%
% obj = callExpOnSub(obj)
%
% See also:
% nb_term.log
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch obj.operator 
        case '+'
            
            % exp(x+y) -> exp(x) * exp(y)
            terms = obj.terms;
            for ii = 1:obj.numberOfTerms
                terms(ii) = callExpOnSub(terms(ii));
            end
            obj.terms    = terms;
            obj.operator = '*';
            
        case '*'
            
            % exp(x*expr) -> exp(x) ^ expr
            term1 = obj.terms(1);
            term1 = callExpOnSub(term1);
            term2 = obj.terms(2:end);
            if size(term2,1) > 1
                term2 = nb_equation('*',term2);
            end
            obj.terms    = [term2;term1];
            obj.operator = '^';    
                 
        case 'log'
            
            % exp(log(x)) -> x
            obj = obj.terms;
            
        otherwise
            
            % exp(expr) -> exp(expr)
            obj = nb_equation('exp',obj);
            
    end
    
    
end

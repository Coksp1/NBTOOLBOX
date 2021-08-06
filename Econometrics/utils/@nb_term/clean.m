function obj = clean(obj)
% Syntax:
%
% obj = clean(obj)
%
% Description:
%
% Clean up nb_term object after operations.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(obj,'nb_equation')

        terms = obj.terms;
        for ii = 1:obj.numberOfTerms
            terms(ii) = clean(terms(ii));
        end
        obj.terms = terms;
        if obj.numberOfTerms == 1 && any(strcmp(obj.operator,{'+','*','^'}))
            % Equation in the operators '+','*' and '^' with only one term
            % is converted to the term itself
            obj = obj.terms;
        end
        
    end

end

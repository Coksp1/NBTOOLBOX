function sorted = sort(obj)
% Syntax:
%
% sorted = sort(obj)
%
% Description:
% 
% Sort terms in an equation.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isscalar(obj.terms)
        sorted = obj.terms;
        return
    end

    if any(strcmp(obj.operator,{'+','*'}))

        % We seperate out numbers 
        indN = arrayfun(@(x)isa(x,'nb_num'),obj.terms);
        numT = obj.terms(indN);
        if ~isempty(numT)
            if strcmp(obj.operator,'+')
                % Remove 0 terms
                numT(numT==0) = [];
            else
                if any(numT==0)
                    % If any number is zero the expression is zero.
                    sorted = nb_num(0);
                    return
                else
                    % Remove 1 terms
                    numT(numT==1) = [];
                end
            end
        end
        
        % Sort the rest of the terms
        sorted  = obj.terms(~indN);  
        termsC  = cellstr(sorted);
        [~,ind] = sort(termsC);
        sorted  = sorted(ind);
    
        if ~isempty(numT)
            % Move numbers first
            if size(numT,1) > 1
                switch obj.operator
                    case '+'
                        numT = plus(numT);
                    case '*'
                        numT = times(numT);
                end
            end
            sorted = [numT;sorted];
        end
    elseif strcmp(obj.operator,'^')
        if isa(obj.terms(end),'nb_num')
            if obj.terms(end) == 0
                sorted = nb_num(1);
                return
            elseif obj.terms(end) == 1
                if obj.numberOfTerms == 2
                    sorted = obj.terms(1);
                else
                    sorted = obj.terms(1:end-1);
                end
                return
            end
        end
        sorted = obj.terms;
    else
        sorted = obj.terms;
    end
    
    if size(sorted,1) == 0
        switch obj.operator
            case '+'
                sorted = nb_num(0);
            case '*'
                sorted = nb_num(1);
            case '^'
                error([mfilename ':: Fatal error.'])
        end
    end
    
end

function c = toString(obj)
% Syntax:
%
% c = toString(obj)
%
% Description:
%
% Convert nb_num object to string or cellstr.
%
% Inputs:
%
% - obj : A nb_num object. May also be a matrix.
%
% Output:
%
% - c   : If obj is scalar the output will be a one line char, 
%         otherwise it will be a cellstr with same size as obj.  
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isscalar(obj)
        switch obj.operator
            case '+'
                c = toStringPlus(obj);
            case '*'
                c = toStringMult(obj);
            case '^'
                c = toStringPower(obj);
            case {'log','exp'}
                term = toString(obj.terms);
                term = nb_term.removePar(term);
                c    = [obj.operator, '(' term ')'];
            otherwise
                terms = cell(obj.numberOfTerms,1);
                for ii = 1:obj.numberOfTerms
                    terms{ii} = toString(obj.terms(ii));
                    terms{ii} = nb_term.removePar(terms{ii});
                end
                terms = strcat(terms,',')';
                terms = horzcat(terms{:});
                c     = [obj.operator, '(' terms(1:end-1) ')'];
        end
    else
        c = nb_callMethod(obj,@toString,'cell');
    end

end

%==========================================================================
function expr = toStringMult(obj)

    expr    = cell(1,length(obj.terms));
    iter    = 0;
    maxIter = length(obj.terms);
    for ii = 1:maxIter
        
        if isa(obj.terms(ii),'nb_equation') && obj.terms(ii).numberOfTerms == 2
            subTerm = obj.terms(ii);
            if isa(subTerm.terms(end),'nb_num')
                if subTerm.terms(2) == -1
                    term = toString(subTerm.terms(1));
                    if any(strcmp(subTerm.terms(1).operator,{'+','*'}))
                        term = ['(',term,')']; %#ok<AGROW>
                    end
                    expr{ii} = ['/',term];
                    iter     = iter + 1;
                    continue
                end
            end
        end
        
        term = toString(obj.terms(ii));
        if strcmp(obj.terms(ii).operator,'+')
            term = ['(',term,')']; %#ok<AGROW>
        end
        expr{ii} = ['*',term];
        
    end
    
    cont = true;
    if iter == maxIter
        expr = strrep(expr,'/','*');
    else
    
        while cont 
            if strncmp(expr{1},'/',1)
                expr = [expr(2:end),expr(1)];
            else
                cont = false;
            end
        end
        
    end
    expr = [expr{:}];
    expr = expr(2:end);
    expr = regexprep(expr,'(?<!\^)-1\*','-');
    if iter == maxIter
        expr = ['1/(' expr ')'];
    end
    
end

%==========================================================================
function expr = toStringPlus(obj)

    expr = cell(1,length(obj.terms));
    neg  = false(1,length(obj.terms));
    for ii = 1:length(obj.terms)
        term = toString(obj.terms(ii));
        if strncmp(term,'-',1)
            expr{ii} = term;
            neg(ii)  = true;
        else
            expr{ii} = ['+',term];
        end
    end
    expr = [expr(~neg),expr(neg)];
    expr = [expr{:}];
    if strncmp(expr,'+',1)
        expr = expr(2:end);
    end
    
end

%==========================================================================
function expr = toStringPower(obj)

    expr = cell(1,length(obj.terms));
    for ii = 1:length(obj.terms)
        if any(strcmp(obj.terms(ii).operator,{'+','*'}))
            term = ['(',toString(obj.terms(ii)),')'];
        else
            term = toString(obj.terms(ii));
        end
        expr{ii} = ['^',term];
    end
    expr = [expr{:}];
    expr = expr(2:end);
    
end

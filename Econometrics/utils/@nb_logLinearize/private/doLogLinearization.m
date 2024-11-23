function obj = doLogLinearization(obj)
% Syntax:
%
% obj = doLogLinearization(obj)
%
% Description:
%
% Summarize log linearization.
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nEqs         = length(obj.equations);
    obj.logLinEq = cell(nEqs,1);
    for ii = 1:nEqs
        if isa(obj.deriv(ii),'nb_param')
            obj.logLinEq{ii} = '0';
            continue
        end
        fod      = obj.deriv(ii).derivatives;
        fod      = nb_mySD.addPar(fod,true);
        fod      = removeLeadLag(fod);
        bases    = obj.deriv(ii).bases;
        gapBases = regexprep(regexprep(bases,['^' obj.ssIdentifier{1}],''),[obj.ssIdentifier{2} '$'],'');
        gaps     = strcat(obj.gapIdentifier{1},gapBases,obj.gapIdentifier{2});
        nBases   = size(bases,2);
        bases    = removeLeadLag(bases);
        mult     = repmat({'*'},[1,nBases]);
        plus     = repmat({'+'},[1,nBases]);
        div      = repmat({'/'},[1,nBases]);
        eqInSS   = nb_mySD.addPar(obj.ssEq(ii),true);
        eqInSS   = removeLeadLag(eqInSS);
        eqInSS   = eqInSS(1,ones(1,nBases));
        termTab  = [fod;mult;bases;div;eqInSS];
        nTerms   = size(fod,2);
        terms    = cell(1,nTerms);
        for tt = 1:nTerms
            % Get the terms we are going to multiply the gaps with
            terms{tt} = [termTab{:,tt}];
        end
        if obj.doSimplify
            terms = nb_term.simplify(terms)';
        end
        terms = nb_mySD.addPar(terms,true);
        ind   = strcmp(terms,'1');
        if any(ind)
            % Remove 1*
            terms(ind) = {''};
            mult(ind)  = {''};
        end
        ind   = strcmp(terms,'(-1)');
        if any(ind)
            % Remove (-1)*
            loc = find(ind) - 1;
            if any(loc==0)
                terms{1}    = '-';
                loc(loc==0) = [];
            end
            terms(loc+1) = {''};
            plus(loc)    = {'-'};
            mult(ind)    = {''};
        end
        table            = [terms;mult;gaps;plus];
        obj.logLinEq{ii} = [table{:}];
        obj.logLinEq{ii} = obj.logLinEq{ii}(1:end-1);
        if ~obj.eqFound(ii)
            % Add equation evaluated at steady-state
            obj.logLinEq{ii} = [eqInSS{1},'(1+',obj.logLinEq{ii} ')'];
        end
    end

end

%==========================================================================
function expr = removeLeadLag(expr)
    expr = strrep(expr,'_lead','');
    expr = strrep(expr,'_lag','');
end

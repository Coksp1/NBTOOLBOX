function [test,pval,results] = grangerCausalityTest(obj,precision)
% Syntax:
%
% [test,pval,results] = grangerCausalityTest(obj,precision)
%
% Description:
%
% Test for granger causality between variables using a joint F-test that
% all the parameters of the lags of a variable y is zero in the equation
% where x is the dependent variable. If the hypothesis can be rejected we
% say that y granger cause x.
%
% Caution: If recursive estimation is done it will anyway only do the test 
%          using the parameters estimated over the full sample.
% 
% Input:
% 
% - obj       : A 1 x 1 nb_var object
% 
% - precision : The precision of the printed result. As a string. Default
%               is '%8.6f'.
%
% Output:
% 
% - test      : The test statistics. As a nDep x nDep double. The diagonal 
%               will return nan.
%
% - pval      : The p-value of the test statistics.  As a nDep x nDep 
%               double. The diagonal will return nan.
%
% - results : A string with the printed results of the test.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin<2
        precision = '';
    end

    if numel(obj)>1
        error([mfilename ':: Can only do the Granger causality test on a 1 x 1 nb_var object'])
    end
    
    if obj.options.recursive_estim
        error([mfilename ':: This test is not supported when recursive estimation is done'])
    end
    
    % Do the F-test
    res      = obj.results;
    beta     = res.beta(:,:,end);
    u        = res.residual(:,:,end);
    T        = size(u,1);
    numCoeff = size(beta,1);
    nDep     = size(beta,2);
    X        = res.regressors(1:T,1:numCoeff);
    start    = obj.estOptions.constant + obj.estOptions.time_trend;
    nLags    = (numCoeff - start)/nDep;
    Atemp    = zeros(nLags,numCoeff);
    b        = zeros(nLags,1);
    testM    = nan(nDep,nDep);
    pvalM    = nan(nDep,nDep);
    for ii = 1:nDep
    
        for jj = 1:nDep
        
            if ii ~= jj
                A                           = Atemp;
                A(:,start+jj:nDep:end)      = eye(nLags);
                [testM(jj,ii),pvalM(jj,ii)] = nb_restrictedFTest(A,b,X,beta(:,ii),u(:,ii));
            end
            
        end
        
    end
    
    % Report the result as nb_cs objects
    dep = [obj.dependent.name, obj.block_exogenous.name];
    test = nb_cs(testM,'',dep,dep);
    pval = nb_cs(pvalM,'',dep,dep);
    
    % Printout of reults
    if nargout > 2
        
        if isempty(precision)
            precision = '%8.6f';
        else
            if ~ischar(precision)
                error([mfilename ':: The precision input must be of the type %8.6f.'])
            end
            precision(isspace(precision)) = '';
            if ~strncmp(precision(1),'%',1)||~all(isstrprop(precision([2,4]),'digit'))||...
               ~isstrprop(precision(end),'alpha')
                error([mfilename ':: The precision input must be of the type %8.6f.'])
            end
        end
        
        % Print results
        results = sprintf('Test: %s','Granger Causality Test');
        results = char(results,sprintf('Null hypothesis: %s','The variables does not Granger cause the dependent variable'));
        results = char(results,sprintf('%s',nb_clock('gui')));
        results = char(results,'');
        
        table                = repmat({' '},[nDep*2 + 1,nDep + 1]);
        table{1,1}           = 'Variable \ Dependent';
        table(1,2:end)       = dep;
        table(2:2:end,2:end) = nb_double2cell(testM,precision);
        table(3:2:end,2:end) = nb_double2cell(pvalM,precision);
        table(2:2:end,1)     = dep;
        table(3:2:end,1)     = repmat({'(P-Value)'},[nDep,1]);
        tableAsChar          = cell2charTable(table);
        results              = char(results,tableAsChar);
        results              = char(results,'');
        
    end

end

function res = print(obj,precision)
% Syntax:
%
% res = print(obj)
%
% Description:
%
% Print test results.
% 
% Input:
% 
% - obj : An object of class nb_fTestStatistics.
% 
% Output:
% 
% - res : A string with the test results.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin<2
        precision = '';
    end

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

    if isempty(fieldnames(obj.results))
        obj = doTest(obj);
    end

    % Print results
    %--------------------------------------------------------------
    res = sprintf('Test: %s','F-Test');
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,['Equation: ' obj.options.dependent]);
    res = char(res,'');

    % Print the tested restriction
    if isa(obj.model,'nb_model_generic')
        mResults  = obj.model.results;
        mOpt      = obj.model.estOptions;
    end

    if strcmpi(mOpt.estimator,'nb_tslsEstimator')
        mResults = mResults.mainEq;
        mOpt     = mOpt.mainEq;
    end

    ind      = strcmpi(obj.options.dependent,mOpt.dependent);
    beta     = mResults.beta;
    beta     = beta(:,ind);
    A        = obj.options.A;
    c        = obj.options.c;
    numBeta  = size(beta,1);
    numRestr = size(A,1);

    % Fill table
    table                                    = repmat({' '},[numBeta,numBeta + 4]);
    table(1:numRestr,1:numBeta)              = nb_double2cell(A,precision);
    table{round(numRestr/2),numBeta + 1}     = ' * ';
    table(1:numBeta,numBeta + 2:numBeta + 2) = nb_double2cell(beta,precision);
    table(1:numRestr,numBeta + 4:end)        = nb_double2cell(c,precision);
    table{round(numRestr/2),numBeta + 3}     = ' = ';
    tableAsChar = cell2charTable(table);
    res         = char(res,tableAsChar);
    res         = char(res,'');

    % Get the results
    fTest = obj.results.fTest;
    fProb = obj.results.fProb;

    % Print the F-test results
    table       = repmat({' '},[2,2]);
    table{1,1}  = 'Test statistics';
    table{1,2}  = 'P-value';
    table(2,1)  = nb_double2cell(fTest,precision);
    table(2,2)  = nb_double2cell(fProb,precision);
    tableAsChar = cell2charTable(table);
    res         = char(res,tableAsChar);
    
end

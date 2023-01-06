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
% - obj : An object of class nb_durbinWuHausmanStatistic.
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
    mOpt = obj.model.estOptions;
    if strcmpi(mOpt.estimator,'nb_tslsEstimator')
        endo = obj.model.endogenous.name;
    else
        endo = obj.options.endogenous;
    end
    
    res = sprintf('Test: %s','Durbin-Wu-Hausman Test');
    if length(endo) > 1 
        res = char(res,sprintf('Null hypothesis: %s',['The regressors ' nb_cellstr2String(endo,', ',' and ') ' are exogenous']));
    else
        res = char(res,sprintf('Null hypothesis: %s',['The regressor ' endo{1} ' is exogenous']));
    end
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,'');

    % Get the results
    test    = obj.results.test;
    prob    = obj.results.prob;
    numTest = size(test,2);
    
    % Print the test results
    table          = repmat({' '},[1 + numTest,3]);
    table{1,2}     = 'Test statistics';
    table{1,3}     = 'P-value';
    table(2:end,2) = nb_double2cell(test,precision);
    table(2:end,3) = nb_double2cell(prob,precision);
    table(2:end,1) = obj.results.dependent';
    tableAsChar    = cell2charTable(table);
    res            = char(res,tableAsChar);
    
end

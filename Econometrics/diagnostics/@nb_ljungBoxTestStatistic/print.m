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
% - obj : An object of class nb_ljungBoxTestStatistic.
% 
% Output:
% 
% - res : A string with the test results.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin<2
        precision = '';
    end
    
    if isempty(precision)
        precision = '%8.6f';
    else
        if ~ischar(precision)
            error('The precision input must be of the type %8.6f.')
        end
        precision(isspace(precision)) = '';
        if ~strncmp(precision(1),'%',1)||~all(isstrprop(precision([2,4]),'digit'))||...
           ~isstrprop(precision(end),'alpha')
            error('The precision input must be of the type %8.6f.')
        end
    end

    if isempty(fieldnames(obj.results))
        obj = doTest(obj);
    end
    
    % Print results
    %--------------------------------------------------------------
    if strcmpi(obj.options.type,'univariate')
        type = 'Univariate';
    else
        type = 'Multivariate';
    end
    res = sprintf('Test: %s',[type, ' Ljung-Box Test']);
    res = char(res,sprintf('Null hypothesis: %s','There are no autocorrelation in the residuals'));
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,'');
    
    % Get the results
    ljungBoxTest = obj.results.ljungBoxTest;
    ljungBoxProb = obj.results.ljungBoxProb;
    
    % Print the F-test results
    if strcmpi(obj.options.type,'univariate')
        numTest        = size(ljungBoxTest,1);
        table          = repmat({' '},[1 + numTest,3]);
        table{1,2}     = 'Test statistics';
        table{1,3}     = 'P-value';
        table(2:end,2) = nb_double2cell(ljungBoxTest,precision);
        table(2:end,3) = nb_double2cell(ljungBoxProb,precision);
        table(2:end,1) = obj.results.dependent';
    else
        table       = repmat({' '},[2,2]);
        table{1,1}  = 'Test statistics';
        table{1,2}  = 'P-value';
        table(2,1)  = nb_double2cell(ljungBoxTest,precision);
        table(2,2)  = nb_double2cell(ljungBoxProb,precision);
    end
    tableAsChar = cell2charTable(table);
    res         = char(res,tableAsChar);
    
end

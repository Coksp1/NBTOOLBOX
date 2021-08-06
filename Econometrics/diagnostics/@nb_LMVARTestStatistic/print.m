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
% - obj : An object of class nb_LMVARTestStatistic.
% 
% Output:
% 
% - res : A string with the test results.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
    res = sprintf('Test: %s','LM (VAR) Test');
    res = char(res,sprintf('Null hypothesis: %s','There are no autocorrelation in the residuals'));
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,'');
    
    % Get the results
    LMVARTest = obj.results.LMVARTest;
    LMVARProb = obj.results.LMVARProb;
    
    % Print the F-test results
    table       = repmat({' '},[2,2]);
    table{1,1}  = 'Test statistics';
    table{1,2}  = 'P-value';
    table(2,1)  = nb_double2cell(LMVARTest,precision);
    table(2,2)  = nb_double2cell(LMVARProb,precision);
    tableAsChar = cell2charTable(table);
    res         = char(res,tableAsChar);
    
end

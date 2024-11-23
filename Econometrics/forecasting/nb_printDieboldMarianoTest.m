function res = nb_printDieboldMarianoTest(test,pval,allVars,precision)
% Syntax:
%
% res = nb_printDieboldMarianoTest(test,pval,allVars,precision)
%
% Description:
%
% Print Diebold-Mariano test results. 
% 
% Input:
% 
% - test      : Same as the test output from the nb_dieboldMarianoTest
%               function.
%
% - pval      : Same as the pval output from the nb_dieboldMarianoTest 
%               function.
%
% - allVars   : Actual data. A double with size nobs x nvar.
% 
% - precision : The precision of the printed result. As a string. 
%               Default is '%8.6f'. See doc on the precision input to the 
%               nb_double2cell function. 
%
% Output:
% 
% - res : A char with the printout of the test.
%
% See also:
% nb_dieboldMarianoTest, nb_double2cell
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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
    nAllVars = length(allVars);
    horizon  = size(test,1);

    % Print results
    res                  = sprintf('Test: %s','Diebold-Mariano Test');
    res                  = char(res,sprintf('Null hypothesis: %s','The forecasts from the two models are equally good'));
    res                  = char(res,sprintf('%s',nb_clock('gui')));
    res                  = char(res,'');
    allHor               = 1:horizon;
    allHor               = cellstr(int2str(allHor'));  
    table                = repmat({' '},[1 + horizon*2,1 + nAllVars]);
    table(1,1)           = {'Horizon'};
    table(1,2:end)       = allVars;
    table(2:2:end,2:end) = nb_double2cell(test,precision);
    table(3:2:end,2:end) = nb_double2cell(pval,precision);
    table(2:2:end,1)     = allHor;
    table(3:2:end,1)     = repmat({'(P-Value)'},[horizon,1]);
    tableAsChar          = cell2charTable(table);
    res                  = char(res,tableAsChar);
    res                  = char(res,'');

end

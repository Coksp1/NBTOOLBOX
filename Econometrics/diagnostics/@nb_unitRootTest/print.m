function printed = print(obj,precision)
% Syntax:
%
% res = print(obj,precision)
%
% Description:
%
% Get the test results as a char.
% 
% Input:
% 
% - obj : An nb_unitRootTest object.
% 
% Output:
% 
% - results : A char with the test results.
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

    res = obj.results;
    est = obj.estimationEq;

    if isempty(est)
        printed = 'No results';
        return
    end

    vars = obj.data.variables;

    switch lower(obj.type)

        case 'adf'

            printed = '';
            for ii = 1:size(est,2)

                % Print the test result
                %--------------------------------------------------
                printed = char(printed,['Null Hypothesis: ' vars{ii} ' has a unit root.']);
                printed = char(printed,sprintf('%s',nb_clock('gui')));
                if res(ii).lagLength ~= -1
                    printed     = char(printed,['Lag length: ' int2str(res(ii).lagLength + 1) '']);
                end
                if ~isempty(res(ii).lagLengthCrit)
                    printed     = char(printed,['Lag length criterion: ' res(ii).lagLengthCrit '']);
                end
                printed     = char(printed,'');
                table       = repmat({''},5,4);
                table{1,3}  = 't-Statistic';
                table{2,1}  = 'ADF test statistic';
                table{2,3}  = num2str(res(ii).rhoTTest,precision);
                if ~isnan(res(ii).rhoPValue)
                    table{1,4}  = 'Prob.*';
                    table{3,1}  = 'Critical values';
                    table{3,2}  = '1% level';
                    table{4,2}  = '5% level';
                    table{5,2}  = '10% level';
                    table{2,4}  = num2str(res(ii).rhoPValue,precision);
                    table{3,3}  = num2str(res(ii).rhoCritValue(3),precision);
                    table{4,3}  = num2str(res(ii).rhoCritValue(2),precision);
                    table{5,3}  = num2str(res(ii).rhoCritValue(1),precision);
                else
                    table{3,1}  = 'Critical values:';
                    table{3,3}  = 'MacKinnon (1996)';
                end 
                tableAsChar = cell2charTable(table);
                printed     = char(printed,tableAsChar);
                if ~isnan(res(ii).rhoPValue)
                    if exist('nb_getUnitRootPValue.m','file')
                        printed = char(printed,'*MacKinnon (1996) one-sided p-values.');
                    else
                        printed = char(printed,'*Monte carlo simulated one-sided p-values.');
                    end
                    printed = char(printed,'');
                end
                
                % Print the estimation result of the test 
                % equation
                %--------------------------------------------------
                printed = char(printed,nb_olsEstimator.print(est(ii).results,est(ii).options,precision));
                printed = char(printed,'');
                
            end

        case 'pp'

            printed = '';
            for ii = 1:size(est,2)

                % Print the test result
                %--------------------------------------------------
                printed     = char(printed,['Null Hypothesis: ' vars{ii} ' has a unit toot.']);
                printed     = char(printed,['Band width: ' int2str(res(ii).bandWidth) '']);
                if ~isempty(res(ii).bandWidthCrit)
                    
                    switch lower(res(ii).bandWidthCrit)
                        case 'nw'    
                            crit = 'Newey-West';
                        case 'a'
                            crit = 'Andrews';
                    end
                    printed = char(printed,['Band width criterion: ' crit '']);
                    
                end
                printed     = char(printed,['Kernel: ' res(ii).kernel '']);
                printed     = char(printed,'');
                
                table       = repmat({''},5,4);
                table{1,3}  = 't-Statistic';
                table{2,1}  = 'Phillips-Perron test statistic';
                table{2,3}  = num2str(res(ii).Zt,precision);
                if ~isnan(res(ii).ZtPValue)
                    table{1,4}  = 'Prob.*';
                    table{3,1}  = 'Critical values';
                    table{3,2}  = '1% level';
                    table{4,2}  = '5% level';
                    table{5,2}  = '10% level';
                    table{2,4}  = num2str(res(ii).ZtPValue,precision);
                    table{3,3}  = num2str(res(ii).ZtCritValue(3),precision);
                    table{4,3}  = num2str(res(ii).ZtCritValue(2),precision);
                    table{5,3}  = num2str(res(ii).ZtCritValue(1),precision);
                else
                    table{3,1}  = 'Critical values:';
                    table{3,3}  = 'MacKinnon (1996)';
                end
                tableAsChar = cell2charTable(table);
                printed     = char(printed,tableAsChar);
                if ~isnan(res(ii).ZtPValue)
                    printed = char(printed,'*MacKinnon (1996) one-sided p-values.');
                    printed = char(printed,'');
                end
                
                table       = repmat({''},2,2);
                table{1,1}  = 'Residual variance:';
                table{2,1}  = 'HAC corrected variance:';
                table{1,2}  = num2str(res(ii).residualVariance,precision);
                table{2,2}  = num2str(res(ii).HAC,precision);
                tableAsChar = cell2charTable(table);
                printed     = char(printed,tableAsChar);
                printed     = char(printed,'');
                
                % Print the estimation result of the test 
                % equation
                %--------------------------------------------------
                printed = char(printed,nb_olsEstimator.print(est(ii).results,est(ii).options,precision));
                printed = char(printed,'');
                
            end

        case 'kpss'


        otherwise

            error([mfilename ':: Unsupported test type ' type])

    end

end

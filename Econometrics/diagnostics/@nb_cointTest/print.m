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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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

    %vars = obj.data.variables;

    switch lower(obj.type)

        case 'eg'

            printed = '';
            
            % Print the test result
            %--------------------------------------------------
            printed = char(printed,'Null Hypothesis: Series are not cointegrated.');
            printed = char(printed,sprintf('%s',nb_clock('gui')));
            if res.lagLength ~= -1
                printed     = char(printed,['Lag length: ' int2str(res.lagLength + 1) '']);
            end
            if ~isempty(res.lagLengthCrit)
                printed     = char(printed,['Lag length criterion: ' res.lagLengthCrit '']);
            end
            
            printed     = char(printed,'');
            table       = repmat({''},5,4);
            table{1,3}  = 't-Statistic';
            table{2,1}  = 'ADF test statistic';
            table{2,3}  = num2str(res.rhoTTest,precision);
            if ~isnan(res.rhoPValue)
                table{1,4}  = 'Prob.*';
                table{3,1}  = 'Critical values';
                table{3,2}  = '1% level';
                table{4,2}  = '5% level';
                table{5,2}  = '10% level';
                table{2,4}  = num2str(res.rhoPValue,precision);
                table{3,3}  = num2str(res.rhoCritValue(3),precision);
                table{4,3}  = num2str(res.rhoCritValue(2),precision);
                table{5,3}  = num2str(res.rhoCritValue(1),precision);
            else
                table{3,1}  = 'Critical values:';
                table{3,3}  = 'MacKinnon (1996)';
            end 
            tableAsChar = cell2charTable(table);
            printed     = char(printed,tableAsChar);
            if ~isnan(res.rhoPValue)
                printed = char(printed,'*MacKinnon (1996) one-sided p-values.');
                printed = char(printed,'');
            end

            % Print the estimation result of the test 
            % equation
            %--------------------------------------------------
            printed = char(printed,nb_olsEstimator.print(est(1).results,est(1).options,precision));
            printed = char(printed,'');
            printed = char(printed,nb_olsEstimator.print(est(2).results,est(2).options,precision));
            printed = char(printed,'');              

        case 'jo'

            printed = '';
            
            % Print the test result
            %--------------------------------------------------
            printed = char(printed,sprintf('%s',nb_clock('gui')));
            if res.lagLength ~= -1
                printed     = char(printed,['Lag length: ' int2str(res.lagLength) '']);
            end
            if ~isempty(res.lagLengthCrit)
                printed     = char(printed,['Lag length criterion: ' res.lagLengthCrit '']);
            end
            
            switch lower(res.model)
        
                case 'h2'
                    str = 'No intercept in CI. No trend in data.';
                case 'h1*'
                    str = 'Intercept in CI. No trend in data.';
                case 'h1'
                    str = 'Intercept in CI. Trend in data.';
                case 'h*'
                    str = 'Intercept and linear trend in CI. Trend in data.';
                case 'h'
                    str = 'Intercept and linear trend in CI. Trend and quadratic trend in data.';
                otherwise
                    error([mfilename ':: The model ' opt.model ' is not supported.'])
            end
            printed     = char(printed,['Trend assumption: ' str]);
            printed     = char(printed,['Test: ' res.hypo]);
            
            testStat = res.testStat;
            num      = size(testStat,2);
            
            % First column
            printed = char(printed,'');
            if isnan(res.pValue)
                table = repmat({''},2+num,5);
            else
                table = repmat({''},2+num,3);
            end
            table{1,1}  = 'Hypothesized';
            table{2,1}  = 'No. CI eq(s)';
            table{3,1}  = 'None';
            for kk = 1:num-1
                table{kk + 3,1}  = ['At most ' int2str(kk)];
            end
            
            % Eigenvalues
            table{2,2}     = 'Eigenvalue';
            table(3:end,2) = nb_double2cell(res.lambda,precision)';
            
            % Test statistic
            table{2,3}     = 'Test statistics';
            table(3:end,3) = nb_double2cell(testStat,precision)';
            
            if ~isnan(res.pValue)
                
                % Critical value
                table{2,4}     = 'Critical value (0.05)';
                table(3:end,4) = nb_double2cell(res.critValue(2),precision)';

                % P-value
                table{2,5}     = 'Prob.*';
                table(3:end,5) = nb_double2cell(res.pValue,precision)';
                
            end
            
            tableAsChar = cell2charTable(table);
            printed     = char(printed,tableAsChar);
            if isnan(res.pValue)
                printed = char(printed,'*Critical values: See MacKinnon et. al (1999).');
            else
                printed = char(printed,'*MacKinnon et. al (1999) p-values.');
            end
            printed = char(printed,'');
            printed = char(printed,'');
            
            % Print the estimation result of the test 
            % equation
            %--------------------------------------------------
            printed = char(printed,nb_olsEstimator.print(est(1).results,est(1).options,precision));
            printed = char(printed,'');
            printed = char(printed,'');
            printed = char(printed,nb_olsEstimator.print(est(2).results,est(2).options,precision));
            printed = char(printed,'');      

        otherwise

            error([mfilename ':: Unsupported test type ' type])

    end

end

function res = printOSR(results,options,precision)
% Syntax:
%
% res = nb_dsge.printOSR(results,options,precision)
%
% Description:
%
% Get the results od the optimization of the simple rules as a char.
% 
% Input:
% 
% - results   : A struct with the results from the optimization of the 
%               simple rules.
%
% - options   : The options property of the nb_dsge object.
%
% - precision : The precision of the printed result.
% 
% Output:
% 
% - results : A char with the estimation results.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin<3
        precision = '';
    end
    
    precision = nb_estimator.interpretPrecision(precision);
    res       = normalPrint(results,options,precision);
         
end

%==================================================================
% SUB
%==================================================================
function res = normalPrint(results,options,precision)

    % Information on estimated equation
    res = ['Optimal simple rules: ' options.osr_type];
    res = char(res,['Method: ',options.optimizer]);
    res = char(res,'Toolbox: NB');
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));
    res = char(res,'');
    
    if ~isnan(results.includedObservations)
        dataStart = options.dataStartDate;
        dataStart = nb_date.date2freq(dataStart);
        start     = dataStart + options.estim_start_ind;
        finish    = dataStart + options.estim_end_ind;
        res       = char(res,sprintf('Sample: %s : %s',toString(start),toString(finish)));
        res       = char(res,sprintf('Included observations: %s\n',int2str(results.includedObservations)));
    end
    
    % Fill table
    numPar           = sum(results.isEstimated);
    table            = repmat({''},[numPar*2 + 1,3]);
    table{1,1}       = 'Parameters';
    table{1,2}       = 'Optimized';
    table{1,3}       = 'Inital';
    table(2:2:end,1) = options.parser.parameters(results.estimationIndex);
    table(3:2:end,1) = repmat({'(Std. Error)'},numPar,1);
    table(2:2:end,2) = nb_double2cell(results.beta(results.estimationIndex,:),precision);
    table(3:2:end,2) = nb_double2cell(results.stdBeta,precision);
    table(2:2:end,3) = nb_double2cell(results.initBeta,precision);

    % Report the likelihood as well
    lossTable          = cell(2,3);
    lossTable(:,:)     = {''};
    loss               = [results.loss];
    lossTable(2,1)     = {'Loss:'}; 
    lossTable(2,2)     = nb_double2cell(loss,precision);
    
    % Merge the tables and convert to char
    table       = [table;lossTable];
    tableAsChar = cell2charTable(table);
    res         = char(res,tableAsChar);
    
end

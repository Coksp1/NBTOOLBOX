function table = printWithBenchmark(estimated,benchmark,precision)
% Syntax:
%
% table = printWithBenchmark(estimated,benchmark,precision)
%
% Description:
%
% Create table with a comparison of estimated parameters and benchmark
% model.
% 
% Input:
% 
% - estimated : An object of class nb_dsge
%
% - benchmark : An object of class nb_dsge
%
% - precision : The precision of the printed result. See the nb_double2cell
%               function
% 
% Output:
% 
% - table : A nParam*2 + 1 x 5 cell array.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        precision = '';
    end
    precision = nb_estimator.interpretPrecision(precision);

    % Get benchmark model values
    estParam    = estimated.parameters.name(estimated.results.estimationIndex);
    [indB,locB] = ismember(estParam,benchmark.parameters.name);
    if any(~indB)
        error(['The benchmark model does not make use of the parameters ',...
            toString(estParam(~indB))])
    end
    benchBeta = benchmark.parameters.value(locB);
    
    % Equation estimation results
    beta    = estimated.results.beta(estimated.results.estimationIndex,:);
    stdBeta = estimated.results.stdBeta;
    if estimated.parser.nBreaks > 0
        error('Model with break-points is not yet supported.')
    else
        isNotBreakD = true(size(beta,1),1);
    end
    numPar = size(beta,1);
    table  = cell(numPar*2 + 1,5);
   
    % Find distribution names
    distrName = estimated.options.prior(isNotBreakD,3);
    distrName = cellfun(@func2str,distrName,'uniformOutput',false);
    distrName = strrep(distrName,'nb_distribution.','');
    distrName = strrep(distrName,'_pdf','');
    for ii = 1:length(distrName)
        if strcmpi(distrName{ii},'truncated') 
            priorInp = estimated.options.prior{ii,4};
            lb       = priorInp{3};
            ub       = priorInp{4};
            if isempty(ub)
                ub = 'inf';
            else
                ub = nb_num2str(ub);
            end
            if isempty(lb)
                lb = '-inf';
            else
                lb = nb_num2str(lb);
            end
            distrName{ii} = [priorInp{1}, '[', lb, ',', ub,']'];
        end
    end
    
    % Fill table
    table{1,1}       = 'Estimated parameters';
    table{1,2}       = 'Estimated mode';
    table{1,3}       = 'Banchmark values';
    table{1,4}       = 'Inital values';
    table{1,5}       = 'Prior distribution';
    table(2:2:end,1) = estimated.options.prior(isNotBreakD,1);
    table(3:2:end,1) = repmat({'(Std. Error)'},numPar,1);
    table(2:2:end,2) = nb_double2cell(beta,precision);
    table(3:2:end,2) = nb_double2cell(stdBeta,precision);
    table(2:2:end,3) = nb_double2cell(benchBeta,precision);
    table(3:2:end,3) = {''};
    table(2:2:end,4) = nb_double2cell(vertcat(estimated.options.prior{isNotBreakD,2}),precision);
    table(3:2:end,4) = {''};
    table(2:2:end,5) = distrName;
    table(3:2:end,5) = {''};
    


end

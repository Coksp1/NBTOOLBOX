function obj = getCalcFromResults(obj,res,estOpt,context)
% Syntax:
%
% obj = getCalcFromResults(obj,res,estOpt,context)
%
% Description:
%
% Get calculated form results structure.
% 
% See also:
% nb_calculate_vintages.calculate, 
% nb_calculate_vintages.updateAtEachContext
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Assign results and options to the nb_calculate_generic object, to 
    % be able to fetch the results of the calculations.
    model          = obj.options.model;
    model          = setResults(model,res);
    model          = setEstOptions(model,estOpt);
    calc           = getCalculated(model);
    calc.dataNames = {context};
    
    % Do reporting
    if ~isempty(obj.reporting)
        hist = nb_ts(estOpt.data,'',estOpt.dataStartDate,estOpt.dataVariables);
        hist = window(hist,calc.startDate,calc.endDate);
        hist = deleteVariables(hist,calc.variables);
        all  = merge(calc,hist);
        expr = [obj.reporting(:,1:2),cell(size(obj.reporting,1),2)];
        calc = doTransformations(all,expr,0,'warning',true);
        calc = keepVariables(calc,obj.options.varOfInterest);
    end
    
    % Assign the calculations to results.
    obj.results.data = addPages(obj.results.data,calc);
    
end

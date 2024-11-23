function calc = getCalculated(obj)

    if numel(obj) > 1
        error([mfilename ':: Input must be a scalar.'])
    end
    
    factorData  = obj.results.smoothed.variables.data(:,1:obj.options.nFactors);
    start       = obj.results.smoothed.variables.startDate;
    factorNames = nb_appendIndexes('Factor',1:obj.options.nFactors)';
    calc        = nb_ts(factorData,'',start,factorNames);
    calc        = nb_calculate_generic.rename(calc,obj.options.renameVariables);
    
end

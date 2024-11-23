function calc = getCalculated(obj)

    if numel(obj) > 1
        error([mfilename ':: Input must be a scalar.'])
    end
    
    data  = obj.results.smoothed.variables.data;
    start = obj.results.smoothed.variables.startDate;
    names = obj.results.smoothed.variables.variables;
    calc  = nb_ts(data,'',start,names);
    calc  = nb_calculate_generic.rename(calc,obj.options.renameVariables);
    
end

function calc = getCalculated(obj)

    if numel(obj) > 1
        error([mfilename ':: Input must be a scalar.'])
    end
    
    data  = obj.results.data;
    start = obj.results.startDate;
    names = obj.results.variables;
    calc  = nb_ts(data,'',start,names);
    calc  = nb_calculate_generic.rename(calc,obj.options.renameVariables);
    
end

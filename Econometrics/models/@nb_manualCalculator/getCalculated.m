function calc = getCalculated(obj)

    if numel(obj) > 1
        error([mfilename ':: Input must be a scalar.'])
    end
    
    calc = nb_manualCalcEstimator.getCalculated(obj.results,obj.estOptions(end));
    calc = nb_calculate_generic.rename(calc,obj.estOptions(end).renameVariables);
    
end

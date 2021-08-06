function calc = getCalculated(obj)

    if numel(obj) > 1
        error([mfilename ':: Input must be a scalar.'])
    end
    
    calc = nb_shorteningEstimator.getData(obj.results,obj.estOptions(end));
    
end

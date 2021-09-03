function calc = getCalculated(obj)

    if numel(obj) > 1
        error([mfilename ':: Input must be a scalar.'])
    end
    
    calc = nb_seasonalEstimator.getSeasonallyAdjusted(obj.results,obj.estOptions(end));
    
end
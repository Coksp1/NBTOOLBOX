function calc = getCalculated(obj)

    if numel(obj) > 1
        error([mfilename ':: Input must be a scalar.'])
    end
    
    calc = nb_pcaEstimator.getFactors(obj.results,obj.estOptions(end));
    
end

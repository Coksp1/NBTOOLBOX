function scoreContexts = getScoreContexts(obj)

    if numel(obj) > 1
        error([mfilename ':: The obj input must be a scalar nb_scorer object.'])
    end
    if isempty(obj.scores)
        scoreContexts = [];
        return
    end
    if strcmpi(obj.scoreType,'equal')
        scoreContexts = [];
    else
        scoreContexts(1,obj.nModels) = nb_scoreContexts();
        for ii = 1:obj.nModels
            if obj.sub
                if obj.model.models(ii).valid
                    scoreContexts(ii) = nb_scoreContextsDefault(obj.scoreType,obj.model.models(ii),obj.recursiveIndex{ii},obj.recursiveCalendar);
                end
            else
                if obj.model(ii).valid
                    scoreContexts(ii) = nb_scoreContextsDefault(obj.scoreType,obj.model(ii),obj.recursiveIndex{ii},obj.recursiveCalendar);
                end
            end
        end
    end
    
end

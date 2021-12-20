function put(obj,data)

    if obj.first
        
        doAtFirstTime(obj,data);
        variableNames = getNames(obj);
        for ii = 1:data.numberOfVariables
            dataOneVar = data(:,ii,:);
            dataOneVar = rename(dataOneVar,'variable',dataOneVar.variables{1},variableNames{ii});
            saveDataBase(permute(dataOneVar),'ext','mat','saveName',[obj.path,filesep,variableNames{ii}]); %#ok<LTARG>
        end
        obj.runDates = data.dataNames;
        obj.first    = false;
        
    else
        
        data          = checkInputs(obj,data);
        variableNames = getNames(obj);
        for ii = 1:data.numberOfVariables
            dataT             = data(:,ii,:);
            dataT             = rename(dataT,'variable',data.variables{ii},variableNames{ii});
            dataOld           = nb_ts([obj.path,filesep,variableNames{ii}]);
            ind               = ~ismember(dataT.dataNames,dataOld.dataNames);
            dataT             = keepPages(dataT,find(ind));
            dataOld.dataNames = dataT.variables;
            dataNew           = merge(dataOld,permute(dataT)); %#ok<LTARG>
            saveDataBase(dataNew,'ext','mat','saveName',[obj.path,filesep,variableNames{ii}]); 
        end
        obj.runDates = unique([obj.runDates,data.dataNames]);
        
    end
    
end

function write(obj,fcst,start)

    checkInputs(obj,fcst,start);
    varName = fcst.dataNames{1};
    varName = strrep(varName,'.','_');
    first   = false;
    try
        fcstOld = nb_data([obj.path,filesep,varName]);
    catch
        first = true;
    end
    if first
        
        fcst.userData = start;
        saveDataBase(fcst,'ext','mat','saveName',[obj.path,filesep,varName]);
        obj.runDates = fcst.variables;
        
    else
        
        ind = ~ismember(fcst.variables,fcstOld.variables);
        if any(ind)
            fcst             = keepPages(fcst,find(ind));
            fcstNew          = merge(fcstOld,fcst);
            startOld         = fcstOld.userData;
            startNew         = [startOld,start(ind)]; 
            fcstNew.userData = startNew;
            saveDataBase(fcstNew,'ext','mat','saveName',[obj.path,filesep,varName]); 
        end
        obj.runDates = unique([obj.runDates, fcst.variables]);
       
    end
    
end

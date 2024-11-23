function [obj,another] = secureSameSpan(obj,another)

    if ~isa(another,class(obj))% DOC inherited from nb_dataSource!
        error('The two input objects must be of same class')
    end
    dat    = obj.data;
    datA   = another.data;
    startD = obj.startObs;
    endD   = obj.endObs;
    if obj.startObs < another.startObs
        per  = another.startObs - obj.startObs;
        datA = [nan(per,size(datA,2),size(datA,3));datA];
    elseif obj.startObs > another.startObs
        per    = obj.startObs - another.startObs;
        dat    = [nan(per,size(dat,2),size(dat,3));dat];
        startD = another.startObs;
    end
    if obj.endObs > another.endObs
        per  = obj.endObs - another.endObs;
        datA = [datA;nan(per,size(datA,2),size(datA,3))];
    elseif obj.endObs < another.endObs
        per  = another.endObs - obj.endObs;
        dat  = [dat;nan(per,size(dat,2),size(dat,3))];
        endD = another.endObs;
    end
    obj.startObs     = startD;
    obj.endObs       = endD;
    obj.data         = dat;
    another.startObs = startD;
    another.endObs   = endD;
    another.data     = datA;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@secureSameSpan,{another});
        
    end
    
end

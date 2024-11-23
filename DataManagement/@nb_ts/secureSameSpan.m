function [obj,another] = secureSameSpan(obj,another)

    if ~isa(another,class(obj))% DOC inherited from nb_dataSource!
        error('The two input objects must be of same class')
    end
    dat    = obj.data;
    datA   = another.data;
    startD = obj.startDate;
    endD   = obj.endDate;
    if obj.startDate < another.startDate
        per  = another.startDate - obj.startDate;
        datA = [nan(per,size(datA,2),size(datA,3));datA];
    elseif obj.startDate > another.startDate
        per    = obj.startDate - another.startDate;
        dat    = [nan(per,size(dat,2),size(dat,3));dat];
        startD = another.startDate;
    end
    if obj.endDate > another.endDate
        per  = obj.endDate - another.endDate;
        datA = [datA;nan(per,size(datA,2),size(datA,3))];
    elseif obj.endDate < another.endDate
        per  = another.endDate - obj.endDate;
        dat  = [dat;nan(per,size(dat,2),size(dat,3))];
        endD = another.endDate;
    end
    obj.startDate     = startD;
    obj.endDate       = endD;
    obj.data          = dat;
    another.startDate = startD;
    another.endDate   = endD;
    another.data      = datA;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@secureSameSpan,{another});
        
    end
    
end

function obj = rdivide(obj,another)
% Syntax:
%
% obj = rdivide(obj,another)
%
% Description:
%
% Right division operator (./).
% 
% Input:
% 
% - another : A scalar number, nb_bgrowth object or string.
% 
% Output:
% 
% - obj     : An object of class nb_bgrowth.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    type = loopObjects(obj,another);
    if type > 0
        obj = runLoopExpand(obj,another,type,@rdivide);
        return
    end

    [objStr,anotherStr,objConst,anotherConst] = getAsString(obj,another,mfilename);
    if ~isa(obj,'nb_bgrowth')
        obj = another;
    end
    
    if objConst && anotherConst
        
        if isempty(regexp(anotherStr,'[\+\-\*\^\/]','once'))
            if isempty(regexp(objStr,'[\+\-\*\^\/]','once'))   
                obj.equation = [objStr,'/',anotherStr];
            else
                obj.equation = ['(',objStr ')/',anotherStr,];
            end
        else
            if isempty(regexp(objStr,'[\+\-\*\^\/]','once'))   
                obj.equation = [objStr,'/(',anotherStr,')'];
            else
                obj.equation = ['(',objStr,')/(',anotherStr,')'];
            end
        end
        
    elseif ~objConst && ~anotherConst
        
        if obj.final 
            return
        elseif another.final
            obj = another;
            return
        end
    
        [objStr,objSum]         = splitSum(obj,objStr);
        [anotherStr,anotherSum] = splitSum(another,anotherStr);
        if strcmpi(objStr,'0') && strcmpi(anotherStr,'0')
            obj = [anotherSum;obj];
        else
            if strcmpi(objStr,'0')
                obj.equation = anotherStr;
            elseif strcmpi(anotherStr,'0')
                obj.equation = objStr;
            else
                anotherStr   = nb_mySD.addPar(anotherStr,true);
                obj.equation = [objStr,'+(-1)*',anotherStr];
            end
            if ~isempty(anotherSum)
                obj = [anotherSum;obj];
            end
            if ~isempty(objSum)
                obj = [objSum;obj];
            end
        end
      
    elseif objConst
        
        if another.final
            obj = another;
            return
        end
        
        [anotherStr,anotherSum] = splitSum(another,anotherStr);
        anotherStr              = nb_mySD.addPar(anotherStr,true);
        if strcmpi(anotherStr,'0')
            obj = another;
        else
            another.equation = ['(-1)*',anotherStr];
            another.constant = false;
            if ~isempty(anotherSum)
                obj = [anotherSum;another];
            else
                obj = another;
            end
        end
        
    else
        
        if obj.final
            return
        end
        
        [objStr,objSum] = splitSum(obj,objStr);
        if ~strcmpi(objStr,'0')
            obj.equation = objStr;
            if ~isempty(objSum)
                obj = [objSum;obj];
            end
        end
        
    end
    
    for ii = 1:numel(obj)
        obj(ii).uniaryMinus = false;
    end

end

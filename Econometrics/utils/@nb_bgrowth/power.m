function obj = power(obj,another)
% Syntax:
%
% obj = power(obj,another)
%
% Description:
%
% Power operator (.^).
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
        obj = runLoopExpand(obj,another,type,@power);
        return
    end
    
    if isa(another,'nb_bgrowth') && ~another.constant
        error([mfilename ':: Cannot raise a nb_bgrowth object with another nb_bgrowth object that is not stationary.'])
    end
    [objStr,anotherStr,objConst] = getAsString(obj,another,mfilename);
     
    if objConst

        if isempty(regexp(anotherStr,'[\+\-\*\^\/]','once'))
            if isempty(regexp(objStr,'[\+\-\*\^\/]','once'))   
                obj.equation = [objStr,'^',anotherStr];
            else
                obj.equation = ['(',objStr ')^',anotherStr,];
            end
        else
            if isempty(regexp(objStr,'[\+\-\*\^\/]','once'))   
                obj.equation = [objStr,'^(',anotherStr,')'];
            else
                obj.equation = ['(',objStr,')^(',anotherStr,')'];
            end
        end

    else

        if obj.final
            return
        end

        [objStr,objSum] = splitSum(obj,objStr);
        if ~strcmpi(objStr,'0') 
            if isempty(regexp(anotherStr,'[\+\-\*\^\/]','once'))
                if isempty(regexp(objStr,'[\+\-\*\^\/]','once')) 
                    obj.equation = [anotherStr,'*',objStr];
                else
                    obj.equation = [anotherStr,'*(',objStr,')'];
                end
            else
                if isempty(regexp(objStr,'[\+\-\*\^\/]','once'))  
                    obj.equation = ['(',anotherStr,')*',objStr];
                else
                    obj.equation = ['(',anotherStr,')*(',objStr,')'];
                end
            end
            if ~isempty(objSum)
                obj = [objSum;obj];
            end
            
        end
        
    end
    
    for ii = 1:numel(obj)
        obj(ii).uniaryMinus = false;
    end

end

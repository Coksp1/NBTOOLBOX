function obj = minus(obj,another)
% Syntax:
%
% obj = minus(obj,another)
%
% Description:
%
% Minus operator (+).
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    type = loopObjects(obj,another);
    if type > 0
        obj = runLoopExpand(obj,another,type,@minus);
        return
    end

    [objStr,anotherStr,objConst,anotherConst] = getAsString(obj,another,mfilename);
    if ~isa(obj,'nb_bgrowth')
        obj = another;
    end
    
    if objConst && anotherConst
        
        % Add it as a uniary minus, so to distinguish between constant
        % variables and not later
        if isempty(regexp(anotherStr,'[\+\-\*\^\/]','once'))
            obj.equation = [objStr,'+(-',anotherStr,')']; 
        else
            obj.equation = [objStr,'+(-(',anotherStr,'))'];
        end
        
    elseif ~objConst && ~anotherConst
    
        if obj.final 
            return
        elseif another.final
            obj = another;
            return
        end
        
        objSplit     = regexp(objStr,'(?<!\()[\-]','split'); % Don't match uniary minus!
        anotherSplit = regexp(anotherStr,'(?<!\()[\-]','split'); % Don't match uniary minus!
        if length(objSplit) == 1 && length(anotherSplit) == 1
            if isempty(regexp(anotherStr,'[\+]','once'))
                obj.equation = [objStr,'-',anotherStr]; % The growth rates must be equal!
            else
                obj.equation = [objStr,'-(',anotherStr,')']; % The growth rates must be equal!
            end
        else
            allSplit      = [objSplit,anotherSplit];
            nEqs          = length(allSplit);
            obj(nEqs-1,1) = nb_bgrowth();
            for ii = 1:nEqs-1
                if isempty(regexp(allSplit{ii+1},'[\+]','once'))
                    obj(ii).equation = [allSplit{1},'-',allSplit{ii+1}]; % The growth rates must be equal!
                else
                    obj(ii).equation = [allSplit{1},'-(',allSplit{ii+1},')']; % The growth rates must be equal!
                end
            end
            obj = removeDuplicates(obj);
            for ii = 1:size(obj,1)-1
                obj(ii).final = true;
            end
        end

    elseif objConst
        
        if another.final
            obj = another;
            return
        end
        if nb_contains(anotherStr,'-0')
            obj.equation = anotherStr;
        else
            obj.equation = [anotherStr '-0']; % The growth rate must be equal to 0!
        end
        obj.constant = false;

    else
        
        if obj.final
            return
        end
        if nb_contains(objStr,'-0')
            obj.equation = objStr;
        else
            obj.equation = [objStr '-0']; % The growth rate must be equal to 0!
        end
        
    end 
    
    for ii = 1:numel(obj)
        obj(ii).uniaryMinus = false;
    end

end

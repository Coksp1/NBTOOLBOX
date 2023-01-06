function obj = uminus(obj)
% Syntax:
%
% obj = uminus(obj)
%
% Description:
%
% Uniary minus.
% 
% Input:
% 
% - obj : An object of class nb_bgrowth.
% 
% Output:
% 
% - obj : An object of class nb_bgrowth.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        obj = nb_callMethod(obj,@uminus,@nb_bgrowth);
        return
    end
    
    if obj.constant
        if isempty(regexp(obj.equation,'[\+\-\*\^\/]','once'))
            obj.equation = ['(-',obj.equation,')'];
        else
            obj.equation = ['(-(',obj.equation,'))'];
        end
    else
        [objStr,objSum] = splitSum(obj,obj.equation);
        if ~isempty(objSum)
            obj.equation = objStr;
            obj          = [objSum;obj];
        end
        for ii = 1:numel(obj)-1
            obj(ii).uniaryMinus = false;
        end
        obj(end).uniaryMinus = true;
    end
         
end

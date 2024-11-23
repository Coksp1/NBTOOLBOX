function obj = sqrt(obj)
% Syntax:
%
% obj = sqrt(obj)
%
% Description:
%
% Square root.
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        obj  = obj(:);
        nobj = size(obj,1);
        out  = cell(nobj,1);
        for ii = 1:nobj
            out{ii} = exp(obj(ii));
        end
        obj = vertcat(out{ii});
        return
    end

    if obj.final
        return
    end
    
    [objStr,objSum] = splitSum(obj,obj.equation);
    if obj.constant
           
        if strcmp(objStr(1),'(') && strcmp(objStr(end),')')
            obj.equation = ['sqrt' objStr ];
        else
            obj.equation = ['sqrt(' objStr ')'];
        end
        if ~isempty(objSum)
            obj = [objSum;obj];
        end
        
    else
        
        if obj.final
            return
        end

        if ~strcmpi(objStr,'0') 
            if isempty(regexp(objStr,'[\+\-\*\^\/]','once')) 
                obj.equation = ['0.5*',objStr];
            else
                obj.equation = ['0.5*(',objStr,')'];
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

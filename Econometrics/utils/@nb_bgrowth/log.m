function obj = log(obj)
% Syntax:
%
% obj = log(obj)
%
% Description:
%
% Log function (natural logarithm).
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
        obj  = obj(:);
        nobj = size(obj,1);
        out  = cell(nobj,1);
        for ii = 1:nobj
            out{ii} = log(obj(ii));
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
            obj.equation = ['log' objStr ];
        else
            obj.equation = ['log(' objStr ')'];
        end
        if ~isempty(objSum)
            obj = [objSum;obj];
        end
        
    else
        
        if ~strcmpi(objStr,'0')
            obj.equation = [objStr '-0']; % The growth rate must be equal to 0!
            if ~isempty(objSum)
                obj = [objSum;obj];
            end 
        end
        
    end
    
    for ii = 1:numel(obj)
        obj(ii).uniaryMinus = false;
    end
    
end

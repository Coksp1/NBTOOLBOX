function obj = exp(obj)
% Syntax:
%
% obj = exp(obj)
%
% Description:
%
% Exponential function.
% 
% Input:
% 
% - obj : An object of class nb_bgrowth.
% 
% Output:
% 
% - obj : An object of class nb_bgrowth.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

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
            obj.equation = ['exp' objStr ];
        else
            obj.equation = ['exp(' objStr ')'];
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

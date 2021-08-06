function obj = normpdf(obj)
% Syntax:
%
% obj = normcdf(obj)
%
% Description:
%
% PDF of the normal distribution.
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        obj  = obj(:);
        nobj = size(obj,1);
        out  = cell(nobj,1);
        for ii = 1:nobj
            out{ii} = normpdf(obj(ii));
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
            obj.equation = ['normpdf' objStr ];
        else
            obj.equation = ['normpdf(' objStr ')'];
        end
        if ~isempty(objSum)
            obj = [objSum;obj];
        end
        
    else
        
        obj.equation = [objStr '-0']; % The growth rate must be equal to 0!
        if ~isempty(objSum)
            obj = [objSum;obj];
        end 
        
    end
    
    for ii = 1:numel(obj)
        obj(ii).uniaryMinus = false;
    end
    
end

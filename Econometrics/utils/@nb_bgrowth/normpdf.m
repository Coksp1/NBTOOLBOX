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
% - m   : The mean of the distribution. Either as a scalar double, a 
%         one line char representing a number or a nb_bgrowth object.
%
% - k   : The std of the distribution. Either as a scalar double, a one 
%         line char representing a number or a nb_bgrowth object.
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
            out{ii} = normpdf(obj(ii));
        end
        obj = vertcat(out{ii});
        return
    end

    [objStr,objSum] = splitSum(obj,obj.equation);
    if obj.constant
           
        if nargin < 3
            kStr = '1';
        else
            [kStr,kConst] = nb_bgrowth.getOneAsString(k,mfilename);
            if ~kConst
                error([mfilename ':: The k input to the ' mfilename ' method is not stationary.'])
            end
        end
        if nargin < 2
            mStr = '1';
        else
            [mStr,mConst] = nb_bgrowth.getOneAsString(m,mfilename);
            if ~mConst
                error([mfilename ':: The m input to the ' mfilename ' method is not stationary.'])
            end
        end
        
        if strcmp(objStr(1),'(') && strcmp(objStr(end),')')
            obj.equation = ['normpdf' objStr(1:end-1) ',' mStr ',' kStr ')'];
        else
            obj.equation = ['normpdf(' objStr ',' mStr ',' kStr ')'];
        end
        if ~isempty(objSum)
            obj = [objSum;obj];
        end
        
    else
        
        if obj.final
            return
        end
        
        obj.equation = [objStr '-0']; % The growth rate must be equal to 0!
        if ~isempty(objSum)
            obj = [objSum;obj];
        end 
        
    end
    
    for ii = 1:numel(obj)
        obj(ii).uniaryMinus = false;
    end
    
end

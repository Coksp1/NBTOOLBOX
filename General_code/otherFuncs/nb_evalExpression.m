function [out,str] = nb_evalExpression(out,type,nInp)
% Syntax:
%
% [out,str] = nb_evalExpression(out,type,nInp)
%
% Description:
%
% Evaluate an expression interpreted by the shunting yard algorithm.
% 
% Input:
% 
% - out        : A cell with the out output from nb_shuntingYardAlgorithm
%                interpreted by either nb_getTypes or nb_getTypesC.
%
% - type       : A double vector. See the type output from nb_getTypes or
%                nb_getTypesC.
%
% - nInp       : A double vector. See the nInp output from the 
%                nb_shuntingYardAlgorithm function.
% 
% Output:
% 
% - out        : The evaluated output. Can be of any class (it depend
%                on the out input)
%
% - str        : If a non-empty char is returned, the expression cannot
%                be interpreted by the shunting yard algorithm.
%
% See also:
% nb_shuntingYardAlgorithm, nb_getTypes, nb_getTypesC
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if length(out) == 1
        out = out{1}; % Final output
        str = '';
        return
    end
    
    mFunc  = {'rdivide','times','power','minus','plus','or','and','nb_macro','in','colon','lt','gt','le','ge','eq','ne'};
    ind    = find(type == 0,1);
    if isempty(ind)
        str = 'Expression could not be evaluated';
        return
    end
    string = out{ind};
    func   = str2func(string);
    try 
        test = out{ind-2};
    catch
        test = '';
    end
    if any(strcmpi(string,mFunc)) && ~strcmpi(test,',')
       
        input1 = out{ind-1};
        nInpT  = nInp(ind);
        if nInpT == 1 % Uniary minus and plus
            try
                temp = func(0,input1);
            catch
                str = ['The function ' string '(' class(input1) ') is not defined.'];
                return
            end    
            out       = [out(1:ind-2),{temp},out(ind+1:end)];
            nInp      = [nInp(1:ind-2),0,nInp(ind+1:end)];
            type      = [type(1:ind-2),1,type(ind+1:end)];
            [out,str] = nb_evalExpression(out,type,nInp);
        else % math operators taking two inputs
            input2 = out{ind-2};
            try
                temp = func(input2,input1);
            catch
                if isa(input2,'nb_macro') 
                    cName2 = ['nb_macro(' input2.type() ')']; 
                else
                    cName2 = class(input2);
                end
                if isa(input1,'nb_macro') && isscalar(input1)
                    cName1 = ['nb_macro(' input1.type() ')']; 
                else
                    cName1 = class(input1);
                end
                str = ['The function ' string '(' cName2 ',' cName1 ') is not defined.'];
                return
            end
            out       = [out(1:ind-3),{temp},out(ind+1:end)];
            nInp      = [nInp(1:ind-3),0,nInp(ind+1:end)];
            type      = [type(1:ind-3),1,type(ind+1:end)];
            [out,str] = nb_evalExpression(out,type,nInp); 
        end
        
    else % Function that does not necessary takes 2 inputs
        
        indC  = [find(type(1:ind) == 4),ind];
        nInpT = nInp(ind);
        indC  = indC(end-nInpT+1:end);
        inp   = cell(1,nInpT);
        for ii = 1:nInpT
            inp{ii} = out{indC(ii) - 1};
        end
        
        % As matlab catche errors when evaluating function
        lastwarn('')
        try
            temp = func(inp{:});
            warn = lastwarn;
            if ~isempty(warn)
                str = ['The inputs to the function ' string ' is not correct. MATLAB error:: ' warn];
                return
            end       
        catch Err
            report = Err.getReport();
            ind1   = strfind(report,'Error in');
            ind2   = strfind(report,'nb_evalExpression');
            if isempty(ind2)
                str    = ['Error for the function ' string '. MATLAB error:: ', Err.message];
            else
                ind3   = find(ind1 < ind2(1),1,'last');
                report = report(1:ind1(ind3)-1);
                str    = ['The inputs to the function ' string ' is not correct. MATLAB error:: ' nb_newLine(1), report];
            end
            return
        end
        
        out       = [out(1:indC(1)-2),{temp},out(ind+1:end)];
        type      = [type(1:indC(1)-2),1,type(ind+1:end)];
        nInp      = [nInp(1:indC(1)-2),0,nInp(ind+1:end)];
        [out,str] = nb_evalExpression(out,type,nInp);
        
    end

end

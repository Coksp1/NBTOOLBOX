function [out,type] = nb_getTypesC(out,variables,data)
% Syntax:
%
% [out,type] = nb_getTypesC(out,variables,data)
%
% Description:
%
% Fill in data to variables in the output from nb_shuntingYardAlgorithm
% function. 
% 
% Input:
% 
% - out       : A cell with the out output from nb_shuntingYardAlgorithm
%               function.
% 
% - variables : Same as the variables input to the nb_shuntingYardAlgorithm
%               function.
%
% - data      : The values of the variables. A cell vector with same 
%               length as variables.
%           
% Output:
% 
% - out       : A cell with same length as the out input, where the
%               the names of the variables has been changed with the data
%               of those variables.
%
% - type      : A vector needed to evaluate the expression using
%               nb_evalExpression.
%
% See also:
% nb_shuntingYardAlgorithm, nb_getTypes, nb_evalExpression
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Replace math operators with matching function 
    mOper = {'./','/','.*','*','.^','^','-','+'};
    mFunc = {'rdivide','rdivide','times','times','power','power','minus','plus'};
    N     = length(mOper);
    for ii = 1:N
        out = strrep(out,mOper{ii},mFunc{ii});
    end

    % Check the type of each element of the interpreted expression
    N    = length(out);
    type = zeros(1,N);
    for ii = 1:N
        element = out{ii}; 
        ind     = strcmp(element,variables);
        if any(ind)
            type(ii) = 1;
            out{ii}  = data{ind}; % Get the data of the given variable
        else
            num = str2double(element);
            if ~isnan(num)
                out{ii}  = num;
                type(ii) = 3;
            else
                if strcmp(element,',')
                    type(ii) = 4;
                else
                    indI = strfind(element,'"');
                    if ~isempty(indI)
                        type(ii) = 2;
                        if size(indI,2) == 2
                            out{ii} = element(2:end-1);
                        else
                            out{ii} = element(2:end);
                        end
                    end
                end
            end
        end
        
    end

end

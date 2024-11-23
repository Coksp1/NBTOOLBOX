function obj = max(obj,another,flip)
% Syntax:
%
% obj = max(obj,another,flip)
%
% Description:
%
% Max operator.
% 
% Input:
% 
% - obj     : A scalar number, nb_param object, nb_mySD object or string.
%
% - another : A scalar number, nb_param object, nb_mySD object or string.
% 
% - flip    : Flip the obj and another order.
%
% Output:
% 
% - obj     : An object of class nb_mySD.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        flip = false;
    end
    if flip
        objT    = obj;
        obj     = another;
        another = objT;
    end

    if isa(another,'nb_mySD') && isa(obj,'nb_mySD')
        
        bases1    = obj.bases;
        bases2    = another.bases;
        basesNew  = unique([bases1,bases2]);
        nNew      = size(basesNew,2);
        indB1     = ismember(basesNew,bases1);
        indB2     = ismember(basesNew,bases2);
        newDerivs = cell(1,nNew); 
        iter1     = 1;
        iter2     = 1;
        for ii = 1:nNew
            
            if indB1(ii) && indB2(ii)

                test1 = str2double(obj.derivatives{iter1});
                test2 = str2double(another.derivatives{iter2});
                if test1 == test2 && ~isnan(test1)
                    % Both derivative are numerical and equal
                    newDerivs{ii} = nb_num2str(test1,obj.precision);
                elseif strcmp(obj.derivatives{iter1},another.derivatives{iter2})  
                    % The derivatives are symbolically equal
                    newDerivs{ii} = obj.derivatives{iter1};
                else
                    % The derivative depends on the state, so add a "if"
                    % block with the use of nb_conditional
                    newDerivs{ii} = strcat('nb_maxDeriv(', obj.values, ',', another.values, ',', obj.derivatives{iter1},',', another.derivatives{iter2}, ')');
                end
                iter1 = iter1 + 1;
                iter2 = iter2 + 1;
                
            elseif indB1(ii)
                test1 = str2double(obj.derivatives{iter1});
                if test1 == 0
                    % Both inputs to the max operator has a 0 derivative
                    newDerivs{ii} = '0';
                else
                    newDerivs{ii} = strcat('nb_maxDeriv(', obj.values, ',', another.values, ',', obj.derivatives{iter1},',0)');
                end
                iter1 = iter1 + 1;  
            elseif indB2(ii)
                test2 = str2double(another.derivatives{iter2});
                if test2 == 0
                    % Both inputs to the max operator has a 0 derivative
                    newDerivs{ii} = '0';
                else
                    newDerivs{ii} = strcat('nb_maxDeriv(', obj.values, ',', another.values, ',0,', another.derivatives{iter2}, ')');
                end
                iter2 = iter2 + 1;              
            end
            
        end
        obj.derivatives = newDerivs;
        obj.bases       = basesNew;
        obj.values      = ['max(' obj.values ',' another.values ')'];
        
    elseif isa(obj,'nb_mySD') && (nb_isScalarNumber(another) || nb_isOneLineChar(another) || isa(another,'nb_param'))
        
        if ischar(another)
            anotherStr = another;
        elseif isa(another,'nb_param')
            anotherStr = char(another);    
        else
            anotherStr = nb_num2str(another,obj.precision);
        end
        for ii = 1:length(obj.derivatives)
            test = str2double(obj.derivatives{ii});
            if test == 0
                % Both inputs to the max operator has a 0 derivative
                obj.derivatives = '0';
            else
                obj.derivatives{ii} = strcat('nb_maxDeriv(', obj.values, ',', anotherStr, ',', obj.derivatives{ii},',0)');
            end
        end
        obj.values = ['max(' obj.values ',' anotherStr ')'];
        
    elseif isa(another,'nb_mySD') && (nb_isScalarNumber(obj) || nb_isOneLineChar(obj) || isa(obj,'nb_param'))
            
        if ischar(obj)
            objStr = obj;
        elseif isa(obj,'nb_param')
            objStr = char(obj);       
        else
            objStr = nb_num2str(obj,another.precision);
        end
        for ii = 1:length(another.derivatives)
            test = str2double(another.derivatives{ii});
            if test == 0
                % Both inputs to the max operator has a 0 derivative
                another.derivatives = '0';
            else
                another.derivatives{ii} = strcat('nb_maxDeriv(', objStr, ',', another.values, ',0,', another.derivatives{ii}, ')');
            end
        end
        another.values = ['max(' another.values ',' objStr ')'];
        obj            = another;
    else
        error([mfilename ':: Unsupported method ' mfilename ' for inputs of ' class(obj) ' and ' class(another) ' (May also be unssuported dimension of inputs, e.g. matrices etc).'])
    end

end

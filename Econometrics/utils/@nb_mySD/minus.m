function obj = minus(obj,another,flip)
% Syntax:
%
% obj = minus(obj,another,flip)
%
% Description:
%
% Minus operator (-).
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
                if isnan(test1) || isnan(test2)
                    newDerivs{ii} = strcat(obj.derivatives{iter1},'-', nb_mySD.addPar(another.derivatives{iter2},true));
                else
                    newDerivs{ii} = nb_num2str(test1 - test2,obj.precision);
                end
                iter1 = iter1 + 1;
                iter2 = iter2 + 1;
                
            elseif indB1(ii)
                newDerivs{ii} = obj.derivatives{iter1};
                iter1         = iter1 + 1;  
            elseif indB2(ii)
                newDerivs{ii} = ['-', nb_mySD.addPar(another.derivatives{iter2},true)];
                iter2         = iter2 + 1;              
            end
            
        end
        obj.derivatives = newDerivs;
        obj.bases       = basesNew;
        obj.values      = [obj.values '-' nb_mySD.addPar(another.values,true)];
        
    elseif isa(obj,'nb_mySD') && (nb_isScalarNumber(another) || nb_isOneLineChar(another) || isa(another,'nb_param'))
        
        if ischar(another)
            anotherStr = another;
        elseif isa(another,'nb_param')
            anotherStr = nb_mySD.addPar(char(another),true);
        else
            anotherStr = nb_num2str(another,obj.precision);
        end
        obj.values = [obj.values '-' anotherStr];
        
    elseif isa(another,'nb_mySD') && (nb_isScalarNumber(obj) || nb_isOneLineChar(obj) || isa(obj,'nb_param'))
            
        if ischar(obj)
            objStr = obj;
        elseif isa(obj,'nb_param')
            objStr = nb_mySD.addPar(char(obj),true);    
        else  
            objStr = nb_num2str(obj,another.precision);
        end
        obj             = another;
        obj.derivatives = strcat('-', nb_mySD.addPar(another.derivatives,true));
        obj.values      = [objStr '-' nb_mySD.addPar(another.values,true)];
        
        if ischar(obj.derivatives)
            obj.derivatives = cellstr(obj.derivatives);
        end
        
    else
        error([mfilename ':: Unsupported method ' mfilename ' for inputs of ' class(obj) ' and ' class(another) ' (May also be unssuported dimension of inputs, e.g. matrices etc).'])
    end

end

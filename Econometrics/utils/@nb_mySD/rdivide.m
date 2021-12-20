function obj = rdivide(obj,another,flip)
% Syntax:
%
% obj = rdivide(obj,another,flip)
%
% Description:
%
% Right division operator (./).
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
        
        bases1     = obj.bases;
        bases2     = another.bases;
        basesNew   = unique([bases1,bases2]);
        nNew       = size(basesNew,2);
        indB1      = ismember(basesNew,bases1);
        indB2      = ismember(basesNew,bases2);
        newDerivs  = cell(1,nNew); 
        iter1      = 1;
        iter2      = 1;
        objStr     = nb_mySD.addPar(obj.values,true);
        anotherStr = nb_mySD.addPar(another.values,true);
        for ii = 1:nNew

            if indB1(ii) && indB2(ii)

                objDeriv     = nb_mySD.addPar(obj.derivatives{iter1},true);               
                anotherDeriv = nb_mySD.addPar(another.derivatives{iter2},true);  
                if strcmp(objDeriv,'1') && strcmp(anotherDeriv,'1')
                    newDerivs{ii} = strcat('(',anotherStr,'-',objStr,')./(',anotherStr,'.^2)');
                elseif strcmp(objDeriv,'1')
                    newDerivs{ii} = strcat('(',anotherStr,'-',anotherDeriv,'.*', objStr,')./(',anotherStr,'.^2)');
                elseif strcmp(anotherDeriv,'1')
                    newDerivs{ii} = strcat('(',objDeriv,'.*',anotherStr,'-', objStr,')./(',anotherStr,'.^2)');
                else
                    newDerivs{ii} = strcat('(',objDeriv,'.*',anotherStr,'-',anotherDeriv,'.*', objStr,')./(',anotherStr,'.^2)');
                end
                iter1 = iter1 + 1;
                iter2 = iter2 + 1;
                
            elseif indB1(ii)
                
                objDeriv = nb_mySD.addPar(obj.derivatives{iter1},true);
                if strcmp(anotherStr,'1')
                    newDerivs{ii} = objDeriv;  
                else
                    newDerivs{ii} = strcat(objDeriv,'./',anotherStr);
                end
                iter1 = iter1 + 1;
                
            elseif indB2(ii)
                
                anotherDeriv = nb_mySD.addPar(another.derivatives{iter2},true);
                if strcmp(anotherDeriv,'1')
                    newDerivs{ii} = strcat('-(',objStr,'./',anotherStr,'.^2)');
                else
                    newDerivs{ii} = strcat('-',objStr,'.*(',anotherDeriv,'./',anotherStr,'.^2)');
                end
                iter2 = iter2 + 1;
                
            end
            
        end
        obj.derivatives = newDerivs;
        obj.bases       = basesNew;
        obj.values      = [ objStr './' anotherStr];
        
    elseif isa(obj,'nb_mySD') && (nb_isScalarNumber(another) || nb_isOneLineChar(another) || isa(another,'nb_param'))
        
        if ischar(another)
            anotherStr = another;
        elseif isa(another,'nb_param')
            anotherStr = nb_mySD.addPar(char(another),true);    
        else
            anotherStr = nb_num2str(another,obj.precision);
        end
        
        if strcmp(anotherStr,'1')
            return
        end
        
        objDeriv        = nb_mySD.addPar(obj.derivatives,true);
        objStr          = nb_mySD.addPar(obj.values,true);
        obj.derivatives = strcat(objDeriv,'./',anotherStr);
        obj.values      = [objStr './' anotherStr];
        
    elseif isa(another,'nb_mySD') && (nb_isScalarNumber(obj) || nb_isOneLineChar(obj) || isa(obj,'nb_param'))
            
        if ischar(obj)
            objStr = obj;
        elseif isa(obj,'nb_param')
            objStr = nb_mySD.addPar(char(obj),true);    
        else
            objStr = nb_num2str(obj,another.precision);
        end
        
        anotherDeriv = nb_mySD.addPar(another.derivatives,true);
        anotherStr   = nb_mySD.addPar(another.values,true);
        obj          = another;
        if strcmp(objStr,'1')
            obj.derivatives = strcat('-(',anotherDeriv ,'./',anotherStr,'.^2)');
        else
            for ii = 1:length(anotherDeriv)
                if strcmp(anotherDeriv{ii} ,'1')
                    obj.derivatives{ii}  = strcat('-(',objStr,'./',anotherStr,'.^2)');
                else
                    obj.derivatives{ii}  = strcat('-',objStr,'.*(',anotherDeriv{ii} ,'./',anotherStr,'.^2)');
                end
            end
        end
        obj.values = [objStr './' anotherStr];
        
    else
        error([mfilename ':: Unsupported method ' mfilename ' for inputs of ' class(obj) ' and ' class(another) ' (May also be unssuported dimension of inputs, e.g. matrices etc).'])
    end
    
    if ischar(obj.derivatives)
        obj.derivatives = cellstr(obj.derivatives);
    end

end

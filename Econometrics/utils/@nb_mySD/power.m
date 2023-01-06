function obj = power(obj,another,flip)
% Syntax:
%
% obj = power(obj,another,flip)
%
% Description:
%
% Power operator (.^).
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        flip = false;
    end
    if flip
        objT    = obj;
        obj     = another;
        another = objT;
    end

    if isa(another,'nb_mySD') && isa(obj,'nb_mySD')
        
        bases1       = obj.bases;
        bases2       = another.bases;
        basesNew     = unique([bases1,bases2]);
        nNew         = size(basesNew,2);
        indB1        = ismember(basesNew,bases1);
        indB2        = ismember(basesNew,bases2);
        newDerivs    = cell(1,nNew); 
        iter1        = 1;
        iter2        = 1;
        objStr       = nb_mySD.addPar(obj.values,true);
        objStrInFunc = nb_mySD.addPar(obj.values,false);
        anotherStr   = nb_mySD.addPar(another.values,true);
        for ii = 1:nNew
            
            
            if indB1(ii) && indB2(ii)

                objDeriv     = nb_mySD.addPar(obj.derivatives{iter1},true);               
                anotherDeriv = nb_mySD.addPar(another.derivatives{iter2},true);      
                if strcmp(objDeriv,'1')
                    newDerivs{ii} = strcat(objStr, '.^', anotherStr ,'.*', anotherDeriv, '.*log', objStrInFunc, '+',...
                                           objStr, '.^(', anotherStr ,'-1).*',anotherStr);
                elseif strcmp(anotherDeriv,'1')
                    newDerivs{ii} = strcat(objStr, '.^', anotherStr ,'.*log', objStrInFunc, '+',...
                                           objStr, '.^(', anotherStr ,'-1).*',anotherStr,'.*',objDeriv);
                elseif strcmp(objDeriv,'1') && strcmp(anotherDeriv,'1')
                    if strcmpi(objDeriv,anotherDeriv)
                        newDerivs{ii} = strcat(objStr, '.^', objStr ,'.*(log', objStrInFunc, '+1)');
                    else
                        newDerivs{ii} = strcat(objStr, '.^', anotherStr ,'.*log', objStrInFunc, '+',...
                                               objStr, '.^(', anotherStr ,'-1).*',anotherStr);
                    end
                else
                    if strcmpi(objDeriv,anotherDeriv)
                        newDerivs{ii} = strcat(objStr, '.^', objStr ,'.*(', anotherDeriv, '.*log', objStrInFunc, '+',...
                                               objDeriv,')');
                    else
                        newDerivs{ii} = strcat(objStr, '.^', anotherStr ,'.*', anotherDeriv, '.*log', objStrInFunc, '+',...
                                               objStr, '.^(', anotherStr ,'-1).*',anotherStr,'.*',objDeriv);
                    end
                end
                iter1 = iter1 + 1;
                iter2 = iter2 + 1;
                
            elseif indB1(ii)
                
                objDeriv = nb_mySD.addPar(obj.derivatives{iter1},true);
                if strcmp(objDeriv,'1')
                    newDerivs{ii} = strcat(anotherStr, '.*', objStr, '.^(', another.values , '-1)');
                else
                    newDerivs{ii} = strcat(anotherStr, '.*', objStr, '.^(', another.values , '-1).*', objDeriv);
                end
                iter1 = iter1 + 1;
                
            elseif indB2(ii)
                
                anotherDeriv = nb_mySD.addPar(another.derivatives{iter2},true);
                if strcmp(anotherDeriv,'1')
                    newDerivs{ii} = strcat(objStr, '.^', anotherStr, '.*log', objStrInFunc); 
                else
                    newDerivs{ii} = strcat(objStr, '.^', anotherStr ,'.*', anotherDeriv, '.*log', objStrInFunc);
                end
                iter2 = iter2 + 1;
                
            end
            
        end
        obj.derivatives = newDerivs;
        obj.bases       = basesNew;
        obj.values      = [objStr '.^' anotherStr];
        
    elseif isa(obj,'nb_mySD') && (nb_isScalarNumber(another) || nb_isOneLineChar(another) || isa(another,'nb_param'))
        
        if ischar(another)
            anotherStr   = nb_mySD.addPar(another,true);
            anotherStr_1 = ['(' another, '-1)'];
        elseif isa(another,'nb_param')
            anotherC     = char(another);   
            anotherStr   = nb_mySD.addPar(anotherC,true);
            anotherStr_1 = ['(' anotherC, '-1)'];
        else
            anotherStr   = nb_num2str(another,obj.precision);
            anotherStr_1 = nb_num2str(another-1,obj.precision);
        end
        
        if strcmp(anotherStr,'1')
            return
        end
        
        objStr   = nb_mySD.addPar(obj.values,true);
        objDeriv = nb_mySD.addPar(obj.derivatives,true);
        for ii = 1:length(objDeriv)
            if strcmp(objDeriv{ii},'1')
                obj.derivatives{ii} = strcat(anotherStr, '.*', objStr, '.^', anotherStr_1);
            else
                obj.derivatives{ii} = strcat(anotherStr, '.*', objStr, '.^', anotherStr_1 , '.*', objDeriv{ii});
            end
        end
        obj.values = [objStr '.^' anotherStr];
        
    elseif isa(another,'nb_mySD') && (nb_isScalarNumber(obj) || nb_isOneLineChar(obj) || isa(obj,'nb_param'))
            
        if ischar(obj)
            objStr       = nb_mySD.addPar(obj,true);
            objStrInFunc = nb_mySD.addPar(obj,false);
        elseif isa(obj,'nb_param')
            objC         = char(obj);     
            objStr       = nb_mySD.addPar(objC,true);
            objStrInFunc = nb_mySD.addPar(objC,false);
        else
            objStr       = nb_num2str(obj,another.precision);
            objStrInFunc = ['(' objStr ')'];
        end
        
        obj        = another;
        anotherStr = nb_mySD.addPar(another.values,true);
        if strcmp(objStr,'1')
            obj.derivatives{:} = '0'; 
        else
            anotherDeriv = nb_mySD.addPar(another.derivatives,true);
            for ii = 1:length(anotherDeriv)
                if strcmp(anotherDeriv{ii},'1')
                    obj.derivatives{ii} = strcat(objStr, '.^', anotherStr, '.*log', objStrInFunc); 
                else
                    obj.derivatives{ii} = strcat(objStr, '.^', anotherStr ,'.*', anotherDeriv{ii}, '.*log', objStrInFunc);
                end
            end
        end
        obj.values = [objStr '.^' anotherStr];
        
    else
        error([mfilename ':: Unsupported method ' mfilename ' for inputs of ' class(obj) ' and ' class(another) ' (May also be unssuported dimension of inputs, e.g. matrices etc).'])
    end
    
    if ischar(obj.derivatives)
        obj.derivatives = cellstr(obj.derivatives);
    end
    
end

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
% - obj     : An object of class nb_eq2Latex, scalar double or string.
%
% - another : An object of class nb_eq2Latex, scalar double or string.
%  
% - flip    : Flip the obj and another order.
%
% Output:
% 
% - obj     : An object of class nb_eq2Latex.
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

    if isa(another,'nb_eq2Latex') && isa(obj,'nb_eq2Latex')
        
        obj.latex  = ['\frac{' obj.latex '}{' another.latex '}'];
        objStr     = nb_mySD.addPar(obj.values,true);
        anotherStr = nb_mySD.addPar(another.values,true);
        obj.values = [ objStr './' anotherStr];
        
    elseif isa(obj,'nb_eq2Latex') && (nb_isScalarNumber(another) || nb_isOneLineChar(another))
        
        if ischar(another)
            anotherStr = another;   
        else
            anotherStr = nb_num2str(another,obj.precision);
        end
        if strcmp(anotherStr,'1')
            return
        end
        objStr     = nb_mySD.addPar(obj.values,true);
        obj.values = [objStr './' anotherStr];
        obj.latex  = ['\frac{' obj.latex '}{' anotherStr '}'];
        
    elseif isa(another,'nb_eq2Latex') && (nb_isScalarNumber(obj) || nb_isOneLineChar(obj))
            
        if ischar(obj)
            objStr = obj;   
        else
            objStr = nb_num2str(obj,another.precision);
        end
        anotherStr = nb_mySD.addPar(another.values,true);
        obj        = another;
        obj.values = [objStr './' anotherStr];
        obj.latex  = ['\frac{' objStr '}{' another.latex '}'];
        
    else
        error([mfilename ':: Unsupported method ' mfilename ' for inputs of ' class(obj) ' and ' class(another) ' (May also be unssuported dimension of inputs, e.g. matrices etc).'])
    end

end

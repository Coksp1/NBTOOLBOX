function obj = plus(obj,another,flip)
% Syntax:
%
% obj = plus(obj,another,flip)
%
% Description:
%
% Plus operator (+).
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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if nargin < 3
        flip = false;
    end
    if flip
        objT    = obj;
        obj     = another;
        another = objT;
    end

    if isa(another,'nb_eq2Latex') && isa(obj,'nb_eq2Latex')
        
        obj.latex  = [obj.latex '+' another.latex];
        obj.values = [obj.values '+' another.values];
        
    elseif isa(obj,'nb_eq2Latex') && (nb_isScalarNumber(another) || nb_isOneLineChar(another))
        
        if ischar(another)
            anotherStr = another;   
        else
            anotherStr = nb_num2str(another,obj.precision);
        end
        obj.latex  = [obj.latex '+' anotherStr];
        obj.values = [obj.values '+' anotherStr];
        
    elseif isa(another,'nb_eq2Latex') && (nb_isScalarNumber(obj) || nb_isOneLineChar(obj))
            
        if ischar(obj)
            objStr = obj;       
        else
            objStr = nb_num2str(obj,another.precision);
        end
        obj        = another;
        obj.latex  = [objStr '+' another.latex];
        obj.values = [objStr '+' another.values];
        
    else
        error([mfilename ':: Unsupported method ' mfilename ' for inputs of ' class(obj) ' and ' class(another) ' (May also be unssuported dimension of inputs, e.g. matrices etc).'])
    end

end

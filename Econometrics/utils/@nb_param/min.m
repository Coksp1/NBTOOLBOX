function obj = min(obj,another)
% Syntax:
%
% obj = min(obj,another)
%
% Description:
%
% Min operator.
% 
% Input:
% 
% - obj     : A scalar number, nb_param object or string.
%
% - another : A scalar number, nb_param object, nb_mySD object or string.
% 
% Output:
% 
% - obj     : An object of class nb_mySD.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(another,'nb_mySD')
        
        obj = min(another,obj,true);

    else
        
        if ischar(obj)
            objStr = obj;
            obj    = another;
        elseif isa(obj,'nb_param')
            objStr = char(obj);
        elseif nb_isScalarNumber(obj)
            objStr = nb_num2str(obj,another.precision);
            obj    = another;
        else
            error([mfilename ':: Unsupported method ' mfilename ' for inputs of ' class(obj) ' and ' class(another) ' (May also be unssuported dimension of inputs, e.g. matrices etc).'])
        end
        
        if ischar(another)
            anotherStr = another;
        elseif isa(another,'nb_param')
            anotherStr = char(another);
        elseif nb_isScalarNumber(another)
            anotherStr = nb_num2str(another,obj.precision);
        else
            error([mfilename ':: Unsupported method ' mfilename ' for inputs of ' class(obj) ' and ' class(another) ' (May also be unssuported dimension of inputs, e.g. matrices etc).'])
        end
        obj.parameter = ['min(',objStr ',' anotherStr,')'];
        
    end

end

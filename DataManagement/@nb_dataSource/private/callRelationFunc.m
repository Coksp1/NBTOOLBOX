function a = callRelationFunc(a,b,func)
% Syntax:
%
% a = callRelationFunc(a,b,func)
%
% Description:
%
% Call one of the relation operators on an object of class
% nb_dataSource.
%
% Input:
% 
% - a : An object of class nb_dataSource or double.
% 
% - b : An object of class nb_dataSource, but must be of same
%       subclass as a, or double.
% 
% Output:
% 
% - a : An object of class nb_dataSource. Where the and operator 
%       has evaluated all the data elements of the object.
%       The data will be a logical matrix 
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(a,class(b))

        [isOk,err] = checkConformity(a,b);
        if isOk
            a.data = func(a.data,b.data);
        else
            errFunc = str2func([class(b),'.errorConformity']);
            errFunc(err);
        end

    elseif nb_isScalarNumber(a) || nb_isScalarNumber(b)
        
        if isnumeric(a)
            b.data = func(a,b.data);
            a      = b;
        else
            a.data = func(a.data,b);
        end
        
    else
        error([mfilename ':: Undefined function ''' func2str(func) ''' for input arguments ',...
                         'of type ''' class(a) ''' and ''' class(b) '''. Inputs must also be scalar objects!']) 
    end
    
    if a.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        a = a.addOperation(@callRelationFunc,{b,func});
    end
    
end

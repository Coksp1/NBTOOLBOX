function obj = mrdivide(a,b)
% Syntax:
%
% obj = mrdivide(a,b)
%
% Description:
%
% Matrix right division (/). See examples.
% 
% Input:
% 
% - a   : An object of class nb_cs, a scalar number or a string 
%         representing a variable name or type name.
% 
% - b   : An object of class nb_cs, a scalar or a string 
%         representing a variable name or type name.
% 
% Output:
% 
% - obj : An nb_cs object.  
% 
% Examples:
%
% obj  = nb_cs.rand(10,3)
% obj1 = obj/1
% obj2 = obj/'Var1'
% obj3 = obj/'Type1'
% obj4 = 1/obj
% obj5 = 'Var1'/obj
% obj6 = 'Type1'/obj
% 
% See also:
% nb_cs.ldivide, nb_cs.mldivide, nb_cs.rdivide
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isa(a,'nb_cs')
        obj = mldivide(b,a);
        return
    end
    
    if isa(a,'nb_cs') && isa(b,'double')

        if isscalar(b)
            obj      = a;
            obj.data = obj.data/b;
        else
            error([mfilename ':: Undefined function ''mrdivide'' for input arguments of type ''' class(a) '''  and ''' class(b) ' vector''. '...
                             '(Remeber that the / operator is the matrix division and not elementwise division (./))'])
        end
        
    elseif isa(a,'nb_cs') && ischar(b) 
        
        if size(b,1) == 1
            
            obj    = a;
            indVar = find(strcmp(b,a.variables),1);
            if ~isempty(indVar)
                num      = repmat(a.data(:,indVar,:),[1,a.numberOfVariables,1]);
                obj.data = a.data./num;
            else
                
                indT = find(strcmp(b,a.types),1);
                if ~isempty(indT)
                    num      = repmat(a.data(indT,:,:),[a.numberOfTypes,1,1]);
                    obj.data = a.data./num;
                else
                    error([mfilename ':: The string provided (''' b ''') is neither a type or a variable of the object'])
                end
                
            end
            
        else
            error([mfilename ':: Undefined function ''mrdivide'' for input arguments of type ''' class(a) '''  and multi-row ''' class(b) '''.'])
        end
           
    else
        error([mfilename ':: Undefined function ''mrdivide'' for input arguments of type ''' class(a) ''' and ''' class(b) '''. '...
                             '(Remeber that the / operator is the matrix division and not elementwise division (./))'])
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@mrdivide,{b});
        
    end

end

function obj = mpower(a,b)
% Syntax:
%
% obj = mpower(a,b)
%
% Description:
%
% Matrix power (^). Defined when raised by a scalar, a string 
% which either represent a variable or type.
% 
% Input:
% 
% - a   : An object of class nb_data
% 
% - b   : A scalar or a string.
% 
% Output:
% 
% - obj : An nb_data object.  
% 
% Examples:
%
% obj  = nb_cs.rand(10,2)
% obj1 = obj^'Type1'
% obj2 = obj^'Var1'
% obj3 = obj^1
%
% See also:
% nb_cs.power
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if (isa(a,'nb_cs') && isa(b,'double')) 

        if isscalar(b)
            obj      = a;
            obj.data = obj.data.^b;
        else
            error([mfilename ':: Undefined function ''mpower'' for input arguments of type ''' class(a) '''  and ''' class(b) ' vector''.'])
        end
        
    elseif isa(a,'nb_cs') && ischar(b) 
        
        if size(b,1) == 1
            
            obj    = a;
            indVar = find(strcmp(b,a.variables),1);
            if ~isempty(indVar)
                num      = repmat(a.data(:,indVar,:),[1,a.numberOfVariables,1]);
                obj.data = a.data.^num;
            else
                
                indT = find(strcmp(b,a.types),1);
                if ~isempty(indT)
                    num      = repmat(a.data(indT,:,:),[a.numberOfTypes,1,1]);
                    obj.data = a.data.^num;
                else
                    error([mfilename ':: The string provided (''' b ''') is neither a type or a variable of the object'])
                end
                
            end
            
        else
            error([mfilename ':: Undefined function ''mpower'' for input arguments of type ''' class(a) '''  and multi-row ''' class(b) '''.'])
        end 
        
    else
        error([mfilename ':: Undefined function ''mpower'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@mpower,{b});
        
    end

end

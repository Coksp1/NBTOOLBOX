function obj = mldivide(a,b)
% Syntax:
%
% obj = mldivide(a,b)
%
% Description:
%
% Matrix left division (\). See examples.
% 
% Input:
% 
% - a   : An object of class nb_cs.
% 
% - b   : A scalar or a string representing a variable name or type
%         name.
% 
% Output:
% 
% - obj : An nb_cs object.  
% 
% Examples:
%
% obj = nb_cs.rand(10,3)
% obj = obj\1       % 1/obj
% obj = obj\'Type1' % 'Type1'/obj
% obj = obj\'Var1'  % 'Var1'/obj
%
% See also:
% nb_cs.ldivide, nb_cs.mrdivide, nb_cs.rdivide
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(a,'nb_cs') && isnumeric(b)

        if isscalar(b)
            obj      = a;
            obj.data = b./obj.data;
        else
            error([mfilename ':: Undefined function ''mldivide'' for input arguments of type ''' class(a) '''  and ''' class(b) ' vector''.'])
        end
        
    elseif isa(a,'nb_cs') && ischar(b) 
        
        if size(b,1) == 1
            
            obj    = a;
            indVar = find(strcmp(b,a.variables),1);
            if ~isempty(indVar)               
                num      = repmat(a.data(:,indVar,:),[1,a.numberOfVariables,1]);
                obj.data = num./a.data;
            else
                
                indT = find(strcmp(b,a.types),1);
                if ~isempty(indT) 
                    num      = repmat(a.data(indT,:,:),[a.numberOfTypes,1,1]);
                    obj.data = num./a.data;
                else
                    error([mfilename ':: The string provided (''' b ''') is neither a type or a variable of the object'])
                end
                
            end
            
        else
            error([mfilename ':: Undefined function ''mldivide'' for input arguments of type ''' class(a) '''  and multi-row ''' class(b) '''.'])
        end   

    else
        error([mfilename ':: Undefined function ''mldivide'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@mldivide,{b});
        
    end

end

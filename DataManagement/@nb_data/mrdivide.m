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
% - a   : An object of class nb_data, a scalar number or a string 
%         representing a variable name or the observation number.
% 
% - b   : An object of class nb_data, a scalar number or a string 
%         representing a variable name or the observation number.
% 
% Output:
% 
% - obj : An nb_data object.   
% 
% Examples:
%
% obj  = nb_data.rand(1,10,3)
% obj1 = obj/1
% obj2 = obj/'1'
% obj3 = obj/'Var1'
% obj4 = 1/obj
% obj5 = '1'/obj
% obj6 = 'Var1'/obj
% 
% See also:
% nb_data.mldivide, nb_data.rdivide
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isa(a,'nb_data')
        obj = mldivide(b,a);
        return
    end

    if isa(a,'nb_data') && isa(b,'double')

        if isscalar(b)
            obj      = a;
            obj.data = obj.data/b;
        else
            error([mfilename ':: Undefined function ''mrdivide'' for input arguments of type ''' class(a) '''  and ''' class(b) ' vector''. '...
                             '(Remeber that the / operator is the matrix division and not elementwise division (./))'])
        end
        
    elseif isa(a,'nb_data') && ischar(b) 
        
        if size(b,1) == 1
            
            obj    = a;
            indVar = find(strcmp(b,a.variables),1);
            if ~isempty(indVar)
                
                num      = repmat(a.data(:,indVar,:),[1,a.numberOfVariables,1]);
                obj.data = a.data./num;
                
            else
                
                obss = observations(obj,'cellstr');
                indD = find(strcmp(b,obss),1);
                if ~isempty(indD)
                   
                    num      = repmat(a.data(indD,:,:),[a.numberOfObservations,1,1]);
                    obj.data = a.data./num;
                    
                else
                    error([mfilename ':: The string provided (''' b ''') is neither a obs or a variable of the object'])
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

function obj = sort(obj,mode,dim,variable)
% Syntax:
%
% obj = sort(obj,mode,dim,variable)
%
% Description:
%
% Sort the wanted dimension (observations) of the data in the order given
% by the order input.
% 
% Caution : Sorting does not reorder the dataNames, variables or dates!
% 
% Input:
% 
% - obj       : An object of class nb_data
% 
% - mode      : 'descend' (default)
%               'ascend'
%
% - dim       : The dimension to sort. Either 1, 2 or 3. Default is 3.
%  
% - variable  : Give a string with the variable to sort. The rest of the
%               variables will then be reordered accordingly.
%
%               If empty (default), all variables are sorted.
%
%               Caution: Only an option for dim == 1
%
% Output: 
% 
% - obj       : An object of class nb_ts
% 
% Examples:
%
% in  = nb_ts(rand(10,2,10),'',1,{'Var1','Var2'});
% out = sort(in);
% out = sort(in,'descend')
% 
% Written by Kenneth S. Paulsen  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        variable = '';
        if nargin < 3
            dim = 3;
            if nargin < 2
                mode = '';
            end
        end
    end

    if isempty(mode)
        mode = 'ascend';
    end
    
    % sort all variables
    switch dim
        
        case 1
            
            if isempty(variable)
                obj.data = sort(obj.data,dim,mode);
            else
                ind                = strcmpi(variable,obj.variables);
                dat                = obj.data(:,ind,:);
                [dat,re]           = sort(dat,1,mode);
                obj.data(:,ind,:)  = dat;
                obj.data(:,~ind,:) = obj.data(re,~ind,:);
            end
            
        case {2,3}
            
            obj.data = sort(obj.data,dim,mode);
            
        otherwise
            
            error([mfilname ':: It is not possible to sort over the dimension ' int2str(dim)])
            
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@sort,{mode,dim,variable});
        
    end
    
end

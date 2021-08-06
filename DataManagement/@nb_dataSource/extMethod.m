function obj = extMethod(obj,method,variables,postfix,varargin)
% Syntax:
%
% obj = extMethod(obj,method,variables,postfix,varargin)
%
% Description:
%
% This method can call a nb_dataSource method on a selected variables, and 
% merge the result with the old object by adding a postfix to the new 
% variables.
%
% This method is the same as calling:
%
% obj1   = window(obj,'','',variables);
% method = str2func(method);
% obj    = method(obj,varargin{:});
% obj1   = addPostfix(obj1,method);
% obj    = merge(obj,obj1); 
%
% But without replicating the links property unnecessary many times!
%
% Caution : If the object is not updateable this will result in the same as
%           the code above!
%
% Input:
% 
% - obj       : An object of class nb_ts, nb_data or nb_cs
%
% - method    : A str with the method to call. Must be a method of the
%               nb_ts, nb_data or nb_cs class that does not change other 
%               dimensions then the second dimension!
%
% - variables : A cellstr with the variables of the object to call the
%               method on. Must be included in the object.
%
% - postfix   : A string with the postfix. If empty, the old variables will
%               be replaced by the new ones.
%
% Optional inputs:
%
% These will be the inputs casted to the method except the object itself.
%
% Extra for nb_ts and nb_data:
%
% - '<start>' : The start date/obs of the function evaluation. Given as the
%               second input to the window method call.
% 
% - '<end>'   : The end date/obs of the function evaluation. Given as the
%               third input to the window method call.
%
% Output:
% 
% - obj : A nb_ts, nb_data or nb_cs object
%
% Examples:
%
% obj = nb_ts.rand(1,10,3);
% obj = extMethod(obj,'lag',{'Var1'},'lag1',1)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~ischar(postfix) 
        error([mfilename ':: The postfix input must be a string'])
    elseif isempty(postfix)
        % Warning?
    end
    
    ind = ismember(variables,obj.variables);
    if any(~ind)
        error([mfilename ':: The variables ' toString(variables(~ind)) ' is not part of the object!'])
    end
    
    % This is the trick. As we here need to remove the adding of the 
    % methods called to the links input, so we in the end only add the 
    % extMethod method instead!
    old = obj.updateable;
    obj.updateable = 0;
    
    inputs = varargin;
    if isa(obj,'nb_cs')
        obj1 = window(obj,{},variables);
    else
        
        start  = '';
        finish = '';

        ind = find(strcmpi('<start>',inputs));
        if ~isempty(ind)
            try
                start = inputs{ind+1};
            catch
                error([mfilename ':: The ''<start>'' must be followed by a input.'])
            end
            inputs = [inputs(1:ind-1),inputs(ind+2:end)];
        end
        
        ind = find(strcmpi('<end>',inputs));
        if ~isempty(ind)
            try
                finish = inputs{ind+1};
            catch
                error([mfilename ':: The ''<end>'' must be followed by a input.'])
            end
            inputs = [inputs(1:ind-1),inputs(ind+2:end)];
        end
        
        if isa(obj,'nb_ts')
            if isempty(start)
                start = '';
            else
                start = interpretDateInput(obj,start);
            end
            if isempty(finish)
                finish = '';
            else
                finish = interpretDateInput(obj,finish);
            end
        end
        obj1 = window(obj,start,finish,variables);
        
    end
    func = str2func(method);
    obj1 = func(obj1,inputs{:});
    obj1 = addPostfix(obj1,postfix);
    if isempty(postfix)
        % If postfix is empty, old variables are replaced
        obj = deleteVariables(obj,variables); 
    end
    obj = merge(obj,obj1); 
    
    % Then we reset the updateable property so we add the extMethod if
    % needed
    obj.updateable = old;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@extMethod,[{method,variables,postfix},varargin]);
        
    end

end

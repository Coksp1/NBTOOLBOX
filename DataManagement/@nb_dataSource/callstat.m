function obj = callstat(obj,func,varargin)
% Syntax:
%
% obj = callstat(obj,func)
% obj = callstat(obj,func,varargin)
%
% Description:
%
% Call a in-built or user defined function on the data of the 
% nb_dataSource object(s) that goes from the data of the object have
% more than one variable to only having one. E.g. when taking the mean
% over a set of variables.
% 
% Input:
% 
% - obj      : An object of class nb_dataSource.
%
% - func     : A function handle (or one line char) that maps a 
%              nObs x nVar x nPage double to nObs x 1 x nPage double,
%              or that maps a nObs x nVar x nPage double to 
%              nObs x nVar x 1 double.
%
% Optional input:
%
% - 'name'   : Set the name of the new variable, as a one line char.
%              Default is to use the str2func on the provided function
%              handle.
%
% - varargin : Optional inputs given as extra inputs to the function
%              func. May be of any class.
%
% Output:
% 
% - obj      :  An object of class nb_dataSource with only one variable.
%
% Examples:
%
% d  = nb_ts.rand('2012Q1',10,3);
% d1 = callstat(d,@(x)mean(x,2),'name','mean')
%
% See also:
% nb_dataSource.mean, nb_dataSource.std, nb_dataSource.var
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ischar(func)
        strFunc = func;
        func    = str2func(func);
    else
        strFunc = func2str(func);
    end
    [name,varargin] = nb_parseOneOptional('name',strFunc,varargin{:});
    
    try
        temp = func(obj.data,varargin{:});
    catch Err
        nb_error([mfilename ':: Calling the function ' strFunc ' on the data of the ' class(obj) ' object failed.'],Err);
    end
    
    if size(obj.data,1) ~= size(temp,1)
        error([mfilename ':: Calling the function ' strFunc ' on the data of the ' class(obj)...
            ' object failed: The size in the first dimension changed.'])
    end
    
    if size(obj.data,3) ~= size(temp,3)
        if size(temp,3) ~= 1
            error([mfilename ':: Calling the function ' strFunc ' on the data of the ' class(obj)...
                ' object failed: The size in the third dimension is not 1.'])
        end
        obj.dataNames = {name};
    else
        if size(temp,2) ~= 1
            error([mfilename ':: Calling the function ' strFunc ' on the data of the ' class(obj)...
                ' object failed: The size in the second dimension is not 1.'])
        end
        obj.variables = {name};
    end
    
    obj.data = temp;
    
    if obj.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@callstat,[{func,'name',name}, varargin]);
    end
    
end

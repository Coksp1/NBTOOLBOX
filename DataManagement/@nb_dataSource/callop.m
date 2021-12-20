function obj = callop(obj,another,func,type)
% Syntax:
%
% obj = callop(obj,another,func)
% obj = callop(obj,another,func,type)
%
% Description:
%
% Call mathematical operator on the data of the object. In contrast to  
% calling the operator itself on the object, this method does not try to  
% match the same variables from the two inputs, but instead operate in the    
% same way as mathematical operators do on double matrices (bsxfun).   
% The time domain is matched though!
%
% Caution: The following operators are supported:
%          > @plus or 'plus'
%          > @minus or 'minus'
%          > @times or 'times'
%          > @rdivide or 'rdivide'
%          > @power or 'power'
% 
% Input:
% 
% - obj      : An object of class nb_dataSource.
%
% - another  : An object of class nb_dataSource.
%
% - func     : One of the above listed functions.
%
% - type     : Either: 
%
%              > 'keep'   : Keep the variable names of the object with 
%                           most variables. If they have the same number 
%                           of variables, they are taken from the first 
%                           object.
%              > 'rename' : The new variable names represent the operation
%                           that has been done to the separate series. So
%                           if you divide an object with one series named
%                           'Var1' with another object with one series
%                           named 'Var2', the new name will be
%                           'Var1./Var2'. (Default)
%
% Output:
% 
% - varargout : All output from the provided function which results in
%               either a double, logical or nb_distribution with the
%               same size as obj input will be converted to a 
%               nb_dataSource method. The rest will be given as return
%               by the func function when applied to the data of the 
%               object.
%
% Examples:
%
% d1 = nb_ts(rand(10,1),'','2012Q1',{'Var1'});
% d2 = nb_ts(rand(10,1),'','2011Q1',{'Var2'});
% d3 = callop(d1,d2,@minus); 
%
% d1 = nb_ts(rand(10,1),'','2012Q1',{'Var1'});
% d2 = nb_ts(rand(10,2),'','2011Q1',{'Var2','Var3'});
% d3 = callop(d1,d2,@minus); 
%
% See also:
% nb_dataSource.getClassOfData
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        type = 'rename';
    end

    supported = {'plus','minus','rdivide','times','power'};
    if ischar(func)
        strFunc = lower(func);
        func    = str2func(func);
    else
        strFunc = func2str(func);
    end
    if ~any(strcmp(strFunc,supported))
        error([mfilename ':: Cannot call the function ' strFunc ' using this method.'])
    end
    if not(isa(obj,'nb_dataSource') && isa(another,'nb_dataSource')) || ~isa(obj,class(another))
        error([mfilename ':: Unsupported method callop(obj,another,' strFunc ') for objects of class ' class(obj)...
                         ' and ' class(another) '.'])
    elseif isDistribution(obj) || isDistribution(another)
        error([mfilename ':: Unsupported method callop(obj,another,' strFunc ') for objects of class ' class(obj)...
                         ' and ' class(another) ' when one of or both of them has data as nb_distribution objects.'])
    end
    
    % Secure same time span
    dat    = obj.data;
    datA   = another.data;
    startD = obj.startDate;
    endD   = obj.endDate;
    if obj.startDate < another.startDate
        per  = another.startDate - obj.startDate;
        datA = [nan(per,size(datA,2),size(datA,3));datA];
    elseif obj.startDate > another.startDate
        per    = obj.startDate - another.startDate;
        dat    = [nan(per,size(dat,2),size(dat,3));dat];
        startD = another.startDate;
    end
    if obj.endDate > another.endDate
        per  = obj.endDate - another.endDate;
        datA = [datA;nan(per,size(datA,2),size(datA,3))];
    elseif obj.endDate < another.endDate
        per  = another.endDate - obj.endDate;
        dat  = [dat;nan(per,size(dat,2),size(dat,3))];
        endD = another.endDate;
    end
    
    obj.data      = bsxfun(func,dat,datA);
    obj.startDate = startD;
    obj.endDate   = endD;
    
    if ~strcmpi(type,'keep')
        vars          = nb_symMatrix(nb_term.split(obj.variables));
        varsA         = nb_symMatrix(nb_term.split(another.variables));
        obj.variables = cellstr(func(vars,varsA));
    end
    
    if obj.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@callop,{another,func,type});
    end
    
end

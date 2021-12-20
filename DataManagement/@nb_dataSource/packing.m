function obj = packing(obj,packages,varargin)
% Syntax:
%
% obj = packing(obj,packages,varargin)
%
% Description:
%
% Package variables by applying the wanted function. Default is summin 
% (sum).
% 
% Input:
%
% - obj      : An object of class nb_ts.
%
% - packages : A 2 x N cell matrix with groups of variables and the names
%              of the groups. If you have not listed a variable it will     
%              be grouped in a group called 'Rest' (as long as 
%              'includeRest' is not set to false).
%         
%              Must be given in the following format:
%         
%              {'group_name_1',...,'group_name_N';
%               name_1        ,...,name_N}
%        
%              Where name_x must be a string with a name of the variable
%              or a cellstr array with the variable names. E.g 'Var1'
%              or {'Var1','Var2'}.
% 
% Optional inputs:
%
% - 'includeRest' : Give false to not include the 'Rest' variable, which
%                   will represent all the variable that has not been
%                   packed.
%
% - 'func'        : Either a function_handle or a one line char with the
%                   name of the function to use. The first input to this
%                   function is a nObs x nVar double, the second is the
%                   dimension (which is always 2). Examples; 'sum', 'prod',
%                   @sum or @prod.
% 
% Output:
% 
% - obj : A object of class nb_ts.
%
% Examples:
%
% data     = nb_ts.rand('2012Q1',10,4);
% packages = {'group1','group2';
%             {'Var1','Var2'},{'Var3'}};
%         
% dataP1 = packing(data,packages)     
% dataP2 = packing(data,packages,'includeRest',false) 
% dataP3 = packing(data,packages,'func',@prod) 
%
% See also:
% nb_ts.createVariable, nb_data.createVariable, nb_cs.createVariable
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    inputs               = varargin; 
    [includeRest,inputs] = nb_parseOneOptional('includeRest',true,inputs{:});
    [func,~]             = nb_parseOneOptional('func',@sum,inputs{:});

    if nb_isOneLineChar(func)
        func = str2func(func);
    elseif ~isa(func,'function_handle')
        error([mfilename ':: The func input must be a function handle or a one line char.'])
    end
    
    nGroups = size(packages,2);
    if includeRest
        nGroupsEnd = nGroups + 1;
    else
        nGroupsEnd = nGroups;
    end
    
    values = zeros(obj.numberOfObservations,nGroupsEnd,obj.numberOfDatasets);
    for ii = 1:nGroups

        if ischar(packages{2,ii})
            packages{2,ii} = cellstr(packages{2,ii});
        elseif ~iscellstr(packages{2,ii})
            error([mfilename ':: The second row element ' int2str(ii) ' must be of type char or cellstr.'])
        end
        packages{2,ii} = nb_rowVector(packages{2,ii});
        group          = packages{2,ii};
        [t,locG]       = ismember(group,obj.variables);
        if any(~t)
            error([mfilename ':: The following variables are not found to be in the object; ' toString(group(~t))])
        end
        values(:,ii,:) = func(obj.data(:,locG,:),2);
        
    end
    
    groupNames = packages(1,:);
    if ~iscellstr(groupNames)
        error([mfilename ':: The first row of the packages input must be a cellstr array.'])
    end
    if includeRest
        allVars         = [packages{2,:}];
        found           = ismember(obj.variables,allVars);
        values(:,end,:) = sum(obj.data(:,~found,:),2);
        groupNames      = [groupNames,'Rest'];
    end
    obj.data      = values;
    obj.variables = groupNames;
  
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@packing,[{packages},varargin]);
        
    end

end

function out = callrtfun(obj,varargin)
% Syntax:
%
% out = callrtfun(obj,another,'func',func)
% out = callrtfun(obj,varargin,'func',func)
%
% Description:
%
% Call a in-built or user defined function on the data of the 
% nb_ts object(s) representing real-time data. The data of the object is
% normally of class double, but may also be of class logical or 
% nb_distribution. Use nb_dataSource.getClassOfData to find the class of  
% the data of the object.
% 
% Caution: For the nb_ts object ot be taken as a real-time datasets it must  
% have the context dates stored in the dataNames property on the format 
% 'yyyymmdd' and only represent one variable.
%
% Input:
% 
% - obj      : An object of class nb_ts.
%
% Optional input:
%
% - 'func'   : Either a function handle or a one line char with the name 
%              of a function (may be user defined in both cases). If not
%              provided the function @(x)x will be used.
%
% - 'name'   : Name of the new variable. Default is 'new'.
% 
% - varargin : Optional inputs given as extra inputs to the function
%              func. May be of any class. nb_ts objects are
%              converted to a matrix with elements of class double, 
%              logical or nb_distribution.
%
% Output:
% 
% - out : An object of class nb_ts.
%
% See also:
% nb_dataSource.getClassOfData
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [func,varargin] = nb_parseOneOptional('func',@(x)x,varargin{:});
    [name,varargin] = nb_parseOneOptional('name','new',varargin{:});

    varargin = [{obj},varargin];
    nobj     = length(varargin);
    if nobj < 2
        error([mfilename ':: At least one extra nb_ts objects must be provided to this function.'])
    end
    if ~all(cellfun(@(x)isa(x,'nb_ts'),varargin))
        error([mfilename ':: All inputs must be nb_ts objects.'])
    end
    
    numVars = cellfun(@(x)x.numberOfVariables,varargin);
    if any(numVars > 1)
        error([mfilename ':: All nb_ts objects can only store real-time data on one variable.'])
    end
    
    vars  = cellfun(@(x)x.variables{1},varargin,'UniformOutput',false);
    uVars = unique(vars);
    if length(uVars) ~= length(vars)
        error([mfilename ':: The nb_ts objects to merge must contain unique variables'])
    end
    
    freqs = cellfun(@(x)x.frequency,varargin);
    if freqs(1) ~= freqs(2:end)
        error([mfilename ':: All nb_ts objects can only store real-time data on one variable.'])
    end
    
    % Find matching contexts
    contextsForEach = cell(1,nobj);
    for ii = 1:nobj
        try
            contextsForEach{ii} = nb_convertContexts(varargin{ii}.dataNames);
        catch
            error([mfilename ':: All elements of the dataNames property of the nb_ts object nr. ' int2str(ii),...
                             ' must have the format ''yyyymmdd''.'])
        end
    end
    contextsForEachShrunk = shrink2Matching(contextsForEach);
    allContexts           = unique(vertcat(contextsForEachShrunk{:}));
    nCont                 = length(allContexts);
    
    % Get window of new series
    startAll  = obj.startDate(1,ones(1,nobj));
    finishAll = startAll;
    for ii = 1:nobj
        startAll(ii)  = varargin{ii}.startDate;
        finishAll(ii) = varargin{ii}.endDate;
    end
    start   = max(startAll);
    finish  = min(finishAll);
    periods = (finish - start) + 1;
    s       = nan(1,nobj);
    e       = nan(1,nobj);
    for jj = 1:nobj
        s(jj) = (start - startAll(jj)) + 1;
    end
    for jj = 1:nobj
        e(jj) = (finish - startAll(jj)) + 1;
    end
    
    % Calling the operator
    out    = nb_ts.nan(start,periods,1,nCont);
    inputs = cell(1,nobj);
    for ii = 1:nCont
        for jj = 1:nobj
            current    = find(allContexts(ii) >= contextsForEach{jj},1,'last');
            inputs{jj} = varargin{jj}.data(s:e,:,current);
        end
        out.data(:,:,ii) = func(inputs{:});
    end
    out.variables = {name};
    out.dataNames = cellstr(num2str(allContexts))';
    
    if obj.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        out.links      = obj.links;
        out.updateable = 1;
        out            = out.addOperation(@callrtfun,[varargin(2:end),{'func',func,'name',name}]);
    end
    
end

%==========================================================================
function contextsD  = shrink2Matching(contextsD)
    
    nobj        = length(contextsD);    
    lowContexts = nan(1,nobj);
    for ii = 1:nobj
        lowContexts(ii) = contextsD{ii}(1);
    end
    latestContext = max(lowContexts);
    for ii = 1:nobj
        ind           = contextsD{ii} >= latestContext;
        contextsD{ii} = contextsD{ii}(ind);
    end
    
end

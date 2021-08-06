function obj = ecdf(obj,varargin)
% Syntax:
%
% obj = ecdf(obj,varargin)
%
% Description:
%
% A method for creating an nb_data object with the Empirical 
% (Kaplan-Meier) cumulative distribution function. It utilizes the inbuilt
% ecdf function to estimate the distribution. See ecdf for more information
% on the optional inputs for the function.
%
% Input:
% 
% - obj : An nb_data object with the data.
%
%
% Optional input:
%
% - 'recursive' : True or false. If true, the CDF will be estimated
%                 recursively. Default is false.
%
% - 'recStart'  : Sets the start obs for the recursive estimation. Default
%                 is the start obs of the obj + 9 observations. As a
%                 scalar integer.
%
% - 'recEnd'    : Sets the end obs for the recursive estimation. Default
%                 is the end obs of the object. As a scalar integer.
%                 
% 
% - 'estStart'  : Sets the start of the estimation sample. As a scalar 
%                 integer.
%
% Output:
% 
% - obj : A numIter x numVar nb_data object where each observation point 
%         contains a nb_distribution object with the estimated parameters
%         of the distribution.
%
% Examples:
%
% f   = nb_data(randn(100,1),'',1,{'v1'});
% obj = f.ecdf('recStart',80,'recEnd',100, 'recursive',1);
%
% See also:
% nb_data.ksdensity
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if obj.numberOfDatasets > 1
        error([mfilename ':: This method does not handle a multi-paged nb_data object.'])
    end
    [recursive,inputs] = nb_parseOneOptional('recursive',false,varargin{:});
    [estStart, inputs] = nb_parseOneOptional('estStart','',inputs{:});
    [recStart, inputs] = nb_parseOneOptional('recStart','',inputs{:});
    [recEnd,   inputs] = nb_parseOneOptional('recEnd','',inputs{:});
    
    if any(isnan(obj.data(:)))
        error([mfilename ':: The data cannot have missing observation in the selected sample.'])
    end
    
    if recursive
        
        obj = window(obj,estStart,recEnd);
        if isempty(recStart)
            recStart = obj.startObs + 9;
        end
        if isempty(recEnd)
            recEnd = obj.endObs;
        end
        T         = recEnd - obj.startObs + 1;
        N         = obj.numberOfVariables;
        V         = T - estStart + 1;
        dist(V,N) = nb_distribution;
        indS      = recStart - obj.startObs + 1;
        if indS < 10
            error([mfilename ':: The recStart input implies a too short estimation period. Must at least be 10 periods (' toString(obj.startObs+10) ').'])
        end
        data = obj.data;
        for jj = 1:N
            for tt = indS:T
                [F,x]              = ecdf(data(1:tt,jj),inputs{:});
                dist(tt-indS+1,jj) = nb_distribution('type','empirical','parameters',{x(2:end),F(2:end)},'name',[obj.variables{jj} '_' toString(obj.startObs + (tt - 1))]);
            end
        end
        
        % Update properties object
        obj.data     = dist;
        obj.startObs = recStart;
        obj.endObs   = recEnd;
        
    else
        
        N         = obj.numberOfVariables;
        dist(1,N) = nb_distribution;
        for jj = 1:N
            [F,x]      = ecdf(obj.data(:,jj),inputs{:});
            dist(1,jj) = nb_distribution('type','empirical','parameters',{x(2:end),F(2:end)},'name',[obj.variables{jj} '_' toString(obj.endObs)]);
        end
        
        % Update properties object
        obj.data     = dist;
        obj.startObs = obj.endObs;
        obj.endObs   = obj.endObs;
        
    end
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object
        % is updated the operation will be done on the updated
        % object
        obj = obj.addOperation(@ecdf,varargin);
        
    end
end

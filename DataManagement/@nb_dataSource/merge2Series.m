function obj = merge2Series(obj,var1,var2,new,method,varargin)
% Syntax:
%
% obj = merge2Series(obj,var1,var2,new,method,varargin)
%
% Description:
%
% Merge 2 series. The var2 series is appended to the var1 series from 
% where it is ending. 
% 
% Input:
% 
% - obj    : An object of class nb_dataSource.
%
% - var1   : A one line char with the name of the base series.
%
% - var2   : A one line char with the name of the appended series.
%
% - new    : Name of the new variable. If given as empty there will not be
%            created a new series, but instead the var1 variable will be 
%            set to the new merged series. Default is empty.
%
% - method : Either 'level', 'diff', 'growth', 'leveldiff' or 
%            'levelgrowth'. Default is 'level'. For the cases 'level', 
%            'diff' or 'growth' it is assumed the both series are in 
%            levels. 'leveldiff' assumes the first series is in level
%            and the second in nLags-difference. 'levelgrowth' assumes the 
%            first series is in level and the second in growth rates over
%            nLags periods, i.e. (x(t) - x(t-nLags))/x(t-nLags). 
%
% Optional input:
%
% - 'nLags' : The number of lages used for the methods 'diff' and 'growth'.
%             Default is 1.
%
% - 'date'  : The date from where to use the second variable. Either a date
%             as string or a nb_date object. If empty the merge will take
%             place where the first variable end + 1 period.
%
% Output:
% 
% - obj  : An object of class nb_dataSource.
%
% Examples:
%
% obj                = nb_ts.rand('2012Q1',10,2,3);
% obj(end-1:end,1,:) = nan;
%
% obj1 = merge2Series(obj,'Var1','Var2','Var3')
% obj2 = merge2Series(obj,'Var1','Var2')
% obj3 = merge2Series(obj,'Var1','Var2','','diff','nLags',1)
% obj4 = merge2Series(obj,'Var1','Var2','','diff','nLags',4)
% obj5 = merge2Series(obj,'Var1','Var2','','level','date','2014Q1')
%
% See also:
% nb_ts.merge, nb_data.merge, nb_cs.merge
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        method = 'level';
        if nargin < 4
            new = '';  
        end
    end

    if ~nb_isOneLineChar(var1)
        error([mfilename ':: The var1 input must be a one line char with the name of a variable.'])
    end
    
    if ~nb_isOneLineChar(var2)
        error([mfilename ':: The var2 input must be a one line char with the name of a variable.'])
    end
    
    if isempty(new)
        set2Var1 = true;
    else
        set2Var1 = false;
        if ~nb_isOneLineChar(new)
            error([mfilename ':: The new input must be a one line char with the name of a variable.'])
        end
        if any(strcmp(new,obj.variables))
            error([mfilename ':: The name of the created series is already a variable.'])
        end
    end
    
    [nLags,varargin] = nb_parseOneOptional('nLags',1,varargin{:});
    if ~nb_isScalarInteger(nLags)
        error([mfilename ':: The ''nLags'' input must be set to a scalar integer.'])
    end
    date = nb_parseOneOptional('date',[],varargin{:});
    if isempty(date)
        findEndPoint = true;
    else
        findEndPoint = false;
        if ischar(date)
            date = nb_date.toDate(date,obj.frequency);
        end
        ind = (date - obj.startDate) + 1;
    end
    
    % Locate the two series
    indV1   = strcmp(var1,obj.variables);
    series1 = obj.data(:,indV1,:);
    if isempty(series1)
        error([mfilename ':: Cannot locate the variable given by the var1 input.'])
    end
    
    indV2   = strcmp(var2,obj.variables);
    series2 = obj.data(:,indV2,:);
    if isempty(series2)
        error([mfilename ':: Cannot locate the variable given by the var2 input.'])
    end
    
    % Do the merging
    newSeries = series1;
    switch lower(method)
        case 'level'
            for pp = 1:obj.numberOfDatasets
                if findEndPoint
                    ind = find(~isnan(series1(:,:,pp)),1,'last') + 1;
                end
                newSeries(ind:end,:,pp) = series2(ind:end,:,pp);
            end
            
        case 'diff'
            
            for pp = 1:obj.numberOfDatasets
                if findEndPoint
                    ind = find(~isnan(series1(:,:,pp)),1,'last');
                end
                if isa(obj,'nb_ts') || isa(obj,'nb_data')
                    per = obj.numberOfObservations - ind;
                else
                    per = obj.numberOfTypes - ind;
                end
                for i = 1:per
                    newSeries(ind + i,:,pp) = newSeries(ind + i - nLags,:,pp) + series2(ind + i,:,pp) - series2(ind + i - nLags,:,pp);
                end   
            end
            
        case 'leveldiff'
            
            for pp = 1:obj.numberOfDatasets
                if findEndPoint
                    ind = find(~isnan(series1(:,:,pp)),1,'last');
                end
                if isa(obj,'nb_ts') || isa(obj,'nb_data')
                    per = obj.numberOfObservations - ind;
                else
                    per = obj.numberOfTypes - ind;
                end
                for i = 1:per
                    newSeries(ind + i,:,pp) = newSeries(ind + i - nLags,:,pp) + series2(ind + i,:,pp);
                end   
            end        
            
        case 'growth'
            
            for pp = 1:obj.numberOfDatasets
                if findEndPoint
                    ind = find(~isnan(series1(:,:,pp)),1,'last');
                end
                if isa(obj,'nb_ts') || isa(obj,'nb_data')
                    per = obj.numberOfObservations - ind;
                else
                    per = obj.numberOfTypes - ind;
                end
                for i = 1:per
                    newSeries(ind + i,:,pp) = newSeries(ind + i - nLags,:,pp)*series2(ind + i,:,pp)/series2(ind + i - nLags,:,pp);
                end   
            end
            
        case 'levelgrowth'
            
            for pp = 1:obj.numberOfDatasets
                if findEndPoint
                    ind = find(~isnan(series1(:,:,pp)),1,'last');
                end
                if isa(obj,'nb_ts') || isa(obj,'nb_data')
                    per = obj.numberOfObservations - ind;
                else
                    per = obj.numberOfTypes - ind;
                end
                for i = 1:per
                    newSeries(ind + i,:,pp) = newSeries(ind + i - nLags,:,pp)*(1 + series2(ind + i,:,pp));
                end   
            end    
            
        otherwise
            error([mfilename ':: Unsupported method ' method '.'])
    end
    
    % Add the new variable
    if set2Var1
        obj.data(:,indV1,:) = newSeries;   
    else
        if obj.sorted
            obj.variables = sort([obj.variables, new]);
            varInd        = find(strcmp(new,obj.variables));
            obj.data      = [obj.data(:,1:varInd-1,:), newSeries, obj.data(:,varInd:end,:)];
        else
            obj.variables = [obj.variables, new];
            obj.data      = [obj.data,newSeries];
        end
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@merge2Series,[{var1,var2,new,method}, varargin]);
        
    end

end

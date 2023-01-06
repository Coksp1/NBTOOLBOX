function obj = merge2Series(obj,other,method,varargin)
% Syntax:
%
% obj = merge2Series(obj,other,method,varargin)
%
% Description:
%
% Merge 2 series. The var2 series is appended to the var1 series from 
% where it is ending. 
% 
% Input:
% 
% - obj    : An object of class nb_math_ts.
%
% - other  : An object of class nb_math_ts.
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
% - obj  : An object of class nb_math_ts.
%
% Examples:
%
% obj   = nb_math_ts.rand('2012Q1',8,1,3);
% other = nb_math_ts.rand('2012Q1',10,1,3);
%
% obj1  = merge2Series(obj,other)
% obj3  = merge2Series(obj,other,'diff','nLags',1)
% obj4  = merge2Series(obj,other,'diff','nLags',4)
% obj5  = merge2Series(obj,other,'level','date','2014Q1')
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        method = 'level';
    end
    
    if size(obj,2) > 1 
        error('The first input must be a nb_math_ts object with one variable.')
    end
    if size(other,2) > 1 
        error('The second input must be a nb_math_ts object with one variable.')
    end
    
    [nLags,varargin] = nb_parseOneOptional('nLags',1,varargin{:});
    if ~nb_isScalarInteger(nLags)
        error([mfilename ':: The ''nLags'' input must be set to a scalar integer.'])
    end
    
    % Get both series with same time-span
    both    = [obj, other];
    series1 = both.data(:,1,:);
    series2 = both.data(:,2,:);
    dim1    = size(both,1);
    
    % Is the date input used
    date = nb_parseOneOptional('date',[],varargin{:});
    if isempty(date)
        findEndPoint = true;
    else
        findEndPoint = false;
        if ischar(date)
            date = nb_date.toDate(date,obj.startDate.frequency);
        end
        ind = (date - both.startDate) + 1;
    end
    
    % Do the merging
    newSeries = series1;
    switch lower(method)
        case 'level'
            for pp = 1:obj.dim3
                if findEndPoint
                    ind = find(~isnan(series1(:,:,pp)),1,'last') + 1;
                end
                newSeries(ind:end,:,pp) = series2(ind:end,:,pp);
            end
            
        case 'diff'
            
            for pp = 1:obj.dim3
                if findEndPoint
                    ind = find(~isnan(series1(:,:,pp)),1,'last');
                end
                per = dim1 - ind;
                for i = 1:per
                    newSeries(ind + i,:,pp) = newSeries(ind + i - nLags,:,pp) + series2(ind + i,:,pp) - series2(ind + i - nLags,:,pp);
                end   
            end
            
        case 'leveldiff'
            
            for pp = 1:obj.dim3
                if findEndPoint
                    ind = find(~isnan(series1(:,:,pp)),1,'last');
                end
                per = dim1 - ind;
                for i = 1:per
                    newSeries(ind + i,:,pp) = newSeries(ind + i - nLags,:,pp) + series2(ind + i,:,pp);
                end   
            end        
            
        case 'growth'
            
            for pp = 1:obj.dim3
                if findEndPoint
                    ind = find(~isnan(series1(:,:,pp)),1,'last');
                end
                per = dim1 - ind;
                for i = 1:per
                    newSeries(ind + i,:,pp) = newSeries(ind + i - nLags,:,pp)*series2(ind + i,:,pp)/series2(ind + i - nLags,:,pp);
                end   
            end
            
        case 'levelgrowth'
            
            for pp = 1:obj.dim3
                if findEndPoint
                    ind = find(~isnan(series1(:,:,pp)),1,'last');
                end
                per = dim1 - ind;
                for i = 1:per
                    newSeries(ind + i,:,pp) = newSeries(ind + i - nLags,:,pp)*(1 + series2(ind + i,:,pp));
                end   
            end    
            
        otherwise
            error([mfilename ':: Unsupported method ' method '.'])
    end
    
    obj = nb_math_ts(newSeries,both.startDate);

end

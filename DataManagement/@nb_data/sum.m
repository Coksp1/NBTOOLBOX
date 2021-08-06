function obj = sum(obj,dim,output)
% Syntax:
%
% obj = sum(obj,dim)
%
% Description:
%
% Takes the sum of the object series
% 
% Caution : All sums ignore nan values. If not all values is nan.
%
% Input:
% 
% - obj    : An object of class nb_data
% 
% - dim    : The dimension to sum over, returns:
% 
%       > dim = 1: Either :
%     
%                  > An nb_data object with all the elements of each 
%                    variable set to their sum over the time 
%                    horizon.
%
%                  > An nb_cs with one type representing the sum 
%                    over the obs horizon). The type is named 
%                    'sum'. 
% 
%       > dim = 2: An nb_data object with one variable representing 
%                  the sum (Take the sum over the varibales)
%                  (Default)
% 
%       > dim = 3: An nb_data object with only on page, representing 
%                  the sum over all pages.
%
% - output : Either 'nb_data' (default) or 'nb_cs'. Only important
%            when summing over the 1 dimension.
% 
% Output:
% 
% - obj : Either an nb_data object or an nb_cs object representing  
%         the sum.
% 
% Examples:
%
% obj        = nb_data([2,1;3,2;4,3],'','1',{'Var1','var2'})
% obj = 
% 
%     'Time'    'Var1'    'var2'
%     '1'       [   2]    [   1]
%     '2'       [   3]    [   2]
%     '3'       [   4]    [   3]
% 
% s1 = sum(obj,1,'nb_data')
% 
% s1 = 
% 
%     'Time'    'Var1'    'var2'
%     '1'       [   9]    [   6]
%     '2'       [   9]    [   6]
%     '3'       [   9]    [   6]
% 
% s1_cs = sum(obj,1,'nb_cs')
% 
% s1_cs = 
% 
%     'Types'    'Var1'    'var2'
%     'sum'      [   9]    [   6]
% 
% s2 = sum(obj,2)
% 
% s2 = 
% 
%     'Time'    'sum'
%     '1'       [  3]
%     '2'       [  5]
%     '3'       [  7]
% 
% s2 = sum(obj,3)
% 
% s2 = 
% 
%     'Time'    'Var1'    'var2'
%     '1'       [   2]    [   1]
%     '2'       [   3]    [   2]
%     '3'       [   4]    [   3]
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        output = 'nb_data';
        if nargin < 2
            dim = 2;
        end
    end

    dat      = obj.data;
    isNaNAll = isnan(dat);
    isNaN2   = any(isNaNAll);
    isNaN3   = any(squeeze(isNaN2),1);
    foundNaN = any(isNaN3,2);

    switch dim
        case 1
            
            if ~foundNaN
                sumOfData = sum(obj.data,1);
            else
                sumOfData = nan(1,obj.numberOfVariables,obj.numberOfDatasets);
                for ii = 1:obj.numberOfDatasets
                    for jj = 1:obj.numberOfVariables
                        dataTemp           = obj.data(:,jj,ii);
                        isNaNTemp          = isNaNAll(:,jj,ii);
                        dataTemp           = sum(dataTemp(~isNaNTemp),1);
                        sumOfData(1,jj,ii) = dataTemp;
                    end
                end
            end

            if strcmpi('nb_data',output)
                obj.data = repmat(sumOfData,[obj.numberOfObservations,1,1]);
            else
                oldObj             = obj;
                obj                = nb_cs(sumOfData,obj.dataNames,'sum',obj.variables,obj.sorted);
                obj.localVariables = oldObj.localVariables;
            end

        case 2

            if ~foundNaN
                sumOfData = sum(obj.data,2);
            else

                sumOfData = nan(obj.numberOfObservations,1,obj.numberOfDatasets);
                for ii = 1:obj.numberOfDatasets

                    for jj = 1:obj.numberOfObservations

                        dataTemp           = obj.data(jj,:,ii);
                        isNaNTemp          = isNaNAll(jj,:,ii);
                        dataTemp           = sum(dataTemp(~isNaNTemp),2);
                        sumOfData(jj,1,ii) =  dataTemp;

                    end

                end

            end

            obj.data              = sumOfData;
            obj.variables         = {'sum'};

        case 3

            if ~foundNaN
                sumOfData = sum(obj.data,3);
            else
                sumOfData = nan(obj.numberOfObservations,obj.numberOfVariables,1);
                for ii = 1:obj.numberOfObservations
                    for jj = 1:obj.numberOfVariables
                        dataTemp           = obj.data(ii,jj,:);
                        isNaNTemp          = isNaNAll(ii,jj,:);
                        dataTemp           = sum(dataTemp(~isNaNTemp),3);
                        sumOfData(ii,jj,1) =  dataTemp;
                    end
                end
            end

            obj.data             = sumOfData;
            obj.dataNames        = {'sum'};

        otherwise

            error([mfilename ':: It is not possible to take the sum of the ' int2str(dim) ' dimension.'])

    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        if strcmpi(output,'nb_data')
            obj = obj.addOperation(@sum,{dim,output});
        elseif strcmpi(output,'nb_cs')
            oldObj = oldObj.addOperation(@sum,{dim,output});
            linksT = oldObj.links;
            obj    = obj.setLinks(linksT);
        end     
    end
end

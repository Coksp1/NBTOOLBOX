function obj = sum(obj,dim,output)
% Syntax:
%
% obj = sum(obj,dim)
%
% Description:
%
% Takes the sum of the object timeseries
% 
% Caution : All sums ignore nan values no matter what the <ignorenan>
% property is set to (if not all values are nan).
%
% Input:
% 
% - obj    : An object of class nb_bd
% 
% - dim    : The dimension to sum over, returns:
% 
%       > dim = 1: Either :
%     
%                  > An nb_bd object with all the elements of each 
%                    variable set to their sum over the time 
%                    horizon.
%
%                  > An nb_cs with one type representing the sum 
%                    over the time horizon). The type is named 
%                    'sum'. 
% 
%       > dim = 2: An nb_bd object with one variable representing 
%                  the sum (Take the sum over the varibales)
%                  (Default)
% 
%       > dim = 3: An nb_ts object with only on page, representing 
%                  the sum over all pages.
%
% - output : Either 'nb_bd' (default) or 'nb_cs'. This is only important
%            when summing over the 1 dimension.
% 
% Output:
% 
% - obj : Either an nb_bd object or a nb_cs object representing  
%         the sum.
% 
% Examples:
%
% D   = {[1,2;3,4],[5,6;7,8]};
% Z   = cat(3,D{:});
% obj = nb_bd(Z,'','2012',{'Var1','Var2'})  
% obj = 
% 
% (:,:,1) =
%
%     'Time'    'Var1'    'Var2'
%     '2012'    [   1]    [   2]
%     '2013'    [   3]    [   4]
% 
% (:,:,2) =
%
%     'Time'    'Var1'    'Var2'
%     '2012'    [   5]    [   6]
%     '2013'    [   7]    [   8]
%
% s1 = sum(obj,1,'nb_bd')
% 
% s1 = 
% 
% (:,:,1) =
%
%     'Time'    'Var1'    'Var2'
%     '2012'    [   4]    [   6]
%     '2013'    [   4]    [   6]
% 
% (:,:,2) =
%
%     'Time'    'Var1'    'Var2'
%     '2012'    [  12]    [  14]
%     '2013'    [  12]    [  14]
% 
% s1_cs = sum(obj,1,'nb_cs')
% 
% s1_cs = 
%
% (:,:,1) =
% 
%     'Types'    'Var1'    'Var2'
%     'sum'      [   4]    [   6]
% 
% (:,:,1) =
% 
%     'Types'    'Var1'    'Var2'
%     'sum'      [  12]    [  14]
%
% s2 = sum(obj,2)
% 
% s2 = 
%
% (:,:,1) =
%
%     'Time'    'sum'
%     '2012'    [  3]
%     '2013'    [  7]
%
% (:,:,2) =
%
%     'Time'    'sum'
%     '2012'    [ 11]
%     '2013'    [ 15]
% 
% s2 = sum(obj,3)
% 
% s2 = 
% 
%     'Time'    'Var1'    'var2'
%     '2012'    [   6]    [   8]
%     '2013'    [  10]    [  12]
%
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        output = 'nb_bd';
        if nargin < 2
            dim = 2;
        end
    end

    dat      = getFullRep(obj);
    isNaNAll = isnan(dat);
    isNaN2   = any(isNaNAll);
    isNaN3   = any(squeeze(isNaN2),1);
    foundNaN = any(isNaN3,2);

    switch dim

        case 1

            if ~foundNaN
                sumOfData = sum(dat,1);
            else

                sumOfData = nan(1,obj.numberOfVariables,obj.numberOfDatasets);
                for ii = 1:obj.numberOfDatasets

                    for jj = 1:obj.numberOfVariables

                        dataTemp           = dat(:,jj,ii);
                        isNaNTemp          = isNaNAll(:,jj,ii);
                        dataTemp           = sum(dataTemp(~isNaNTemp),1);
                        sumOfData(1,jj,ii) =  dataTemp;

                    end

                end

            end

            if strcmpi('nb_bd',output)
                dataIn = repmat(sumOfData,[obj.numberOfObservations,1,1]);
                obj    = assignProperties(obj,dataIn);
                
            else
                oldObj             = obj;
                obj                = nb_cs(sumOfData,obj.dataNames,'sum',obj.variables,obj.sorted);
                obj.localVariables = oldObj.localVariables;
            end

        case 2

            if ~foundNaN
                sumOfData = sum(dat,2);
            else

                sumOfData = nan(obj.numberOfObservations,1,obj.numberOfDatasets);
                for ii = 1:obj.numberOfDatasets

                    for jj = 1:obj.numberOfObservations

                        dataTemp  = dat(jj,:,ii);
                        isNaNTemp = isNaNAll(jj,:,ii);
                        if ~all(isNaNTemp)
                            dataTemp           = sum(dataTemp(~isNaNTemp),2);
                            sumOfData(jj,1,ii) = dataTemp;
                        end
                        
                    end

                end

            end
            
            obj = assignProperties(obj,sumOfData);
            obj.variables     = {'sum'};

        case 3

            if ~foundNaN
                sumOfData = sum(dat,3);
            else

                sumOfData = nan(obj.numberOfObservations,obj.numberOfVariables,1);
                for ii = 1:obj.numberOfObservations

                    for jj = 1:obj.numberOfVariables

                        dataTemp           = dat(ii,jj,:);
                        isNaNTemp          = isNaNAll(ii,jj,:);
                        dataTemp           = sum(dataTemp(~isNaNTemp),3);
                        sumOfData(ii,jj,1) = dataTemp;

                    end

                end

            end

            obj            = assignProperties(obj,sumOfData);
            obj.dataNames  = {'sum'};

        otherwise

            error([mfilename ':: It is not possible to take the sum of the ' int2str(dim) ' dimension.'])

    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        if strcmpi(output,'nb_bd')
        
            obj = obj.addOperation(@sum,{dim,output});
        
        elseif strcmpi(output,'nb_cs')                  
            
            oldObj = oldObj.addOperation(@sum,{dim,output});
            linksT = oldObj.links;
            obj    = obj.setLinks(linksT);
            
        end
         
    end

end

function obj = assignProperties(obj,data)
    % Given data, find bd properties and set them
    
    [loc,ind,dataOut] = nb_bd.getLocInd(data);
    obj.locations     = loc;
    obj.indicator     = ind;
    obj.data          = dataOut;
end

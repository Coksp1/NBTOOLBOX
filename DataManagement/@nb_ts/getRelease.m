function obj = getRelease(obj,num)
% Syntax:
%
% obj = release(obj,num)
%
% Description:
%
% Get the wanted release from the real-time data of the object.
%
% This method is not restricted to only updatable real-time data as is the
% the case with nb_ts.release. Instead the dataNames property must be given
% with the 'yyyymmdd' format.
% 
% Caution : This method will break the link to the data source of 
%           updateable objects!
%
% Input:
% 
% - obj : An object of class nb_ts. The vintages dates stored in the
%         dataNames property on the format 'yyyymmdd'.
%
%         Caution: The number of variables stored is limited to one!
% 
% - num : The release number. 1 for the first release, and so on. 0 for
%         final vintage.
%
% Output:
% 
% - obj : An object of class nb_ts with only one page.
%
% See also:
% nb_ts.release
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        num = 1;
    end
    
    if ~nb_isScalarInteger(num,-1)
        error([mfilename ':: The num input must be a scalar integer >0.'])
    end
    
    if obj.numberOfVariables > 1
        error([mfilename ':: This method only handle a nb_ts object storing the real-time data of one variable.'])
    end
    obj = breakLink(obj);
    
    if num == 0
    
        % Update new properties
        start = getRealEndDatePages(keepPages(obj,1),'nb_date');
        if isempty(start)
            % Only missing data on first vintage, looking for first valid 
            % vintage
            dates = getRealEndDatePages(obj,'nb_date');
            ind   = arrayfun(@isempty,dates);
            indF  = find(~ind,1);
            if isempty(indF)
                obj = nb_ts.nan(obj.startDate,obj.numberOfObservations,obj.variables);
                return
            else
                start = dates(indF);
            end
        end
        obj           = window(obj,start,'','',obj.numberOfDatasets);
        obj.dataNames = {['Release',int2str(num)]};
        
    else
        
        % Loop each vintage to get release
        dates = getRealEndDatePages(obj,'nb_date');
        ind   = arrayfun(@isempty,dates);
        sVint = find(~ind,1);
        if isempty(sVint)
            obj = nb_ts.nan(obj.startDate,obj.numberOfObservations,obj.variables);
            return
        end
        dates   = dates(~ind);
        nVint   = length(dates);
        uInd    = nan(1,nVint);
        kk      = 1;
        current = dates(1);
        for ii = 2:nVint
            if dates(ii) ~= current
                uInd(kk) = ii-1;
                current  = dates(ii);
                kk       = kk + 1;
            end
        end
        uInd  = [uInd(1:kk-1),nVint];
        obj   = window(obj,'','','',uInd + sVint - 1);
        dates = dates(uInd);
        nVint = length(dates);
        dataR = nan(nVint,1,1);
        for ii = 1:nVint
            obs       = (dates(ii) - obj.startDate) + 2 - num;
            dataR(ii) = obj.data(obs,1,ii);
        end
        per = dates(end) - dates(1) + 1;
        if per > size(dataR,1)
            % There are some gaps to be filled in for
            allDates     = vec(dates(1),dates(end));
            ind          = ismember(allDates,dates);
            dataA        = nan(per,1);
            dataA(ind,:) = dataR;
            loc          = find(~ind);
            for ii = loc
                date  = allDates(ii);
                numT  = num;
                found = false;
                while ~found
                    numT  = numT + 1;
                    date  = date + 1;
                    found = ismember(date,dates);
                end
                ind       = find(ismember(dates,date),1);
                obs       = (dates(ind) - obj.startDate) + 2 - numT;
                dataA(ii) = obj.data(obs,1,ind); 
            end
        else
            dataA = dataR;
        end
        
        % Update new properties
        obj.data      = dataA;
        obj.startDate = dates(1) - (num - 1);
        obj.endDate   = dates(end) - (num - 1);
        obj.dataNames = {['Release',int2str(num)]};
        
    end
    
    

end

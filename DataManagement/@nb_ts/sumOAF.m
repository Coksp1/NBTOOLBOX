function obj = sumOAF(obj,sumFreq) 
% Syntax:
%
% obj = sumOAF(obj,sumFreq)
%
% Description:
%
% Take the sum over a lower frequency.
% 
% I.e. if frequency is quartely, this function can sum over all the
% quarters of a year. And it will return the sum over the year in 
% all quarters of the that year
% 
% Input:
% 
% - obj     : An object of class nb_ts
% 
% - sumFreq : The frequency to sum over
% 
% Output:
% 
% - obj     : An object of class nb_ts where the data is summed 
%             over a lower frequency
% 
% Examples:
% 
% obj = nb_ts.ones('2012Q1',8,1);
% obj = obj.sumOAF(1)
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    freq = obj.frequency;

    if sumFreq < freq

        [~,locations] = obj.startDate.toDates(0:(obj.endDate - obj.startDate),'default',sumFreq,0);

        newData = nan(obj.numberOfObservations,obj.numberOfVariables,obj.numberOfDatasets);
        for mm = 1:length(locations)

            if mm == 1

                for jj = 1:obj.numberOfVariables

                    for zz = 1:obj.numberOfDatasets

                        ind                = 1:locations(mm);           
                        dataTemp           = obj.data(ind,jj,zz);
                        newData(ind,jj,zz) = sum(dataTemp(~isnan(dataTemp)),1);

                    end

                end

            else

                for jj = 1:obj.numberOfVariables

                    for zz = 1:obj.numberOfDatasets

                        ind               = locations(mm-1) + 1:locations(mm);
                        dataTemp          = obj.data(locations(mm-1) + 1:locations(mm),jj,zz);
                        newData(ind,jj,zz) = sum(dataTemp(~isnan(dataTemp)),1);

                    end

                end

            end

        end

        % I need to find out if the first period contains a full
        % period of the sum frequency
        %----------------------------------------------------------
        date = obj.startDate.getDate(sumFreq);
        date = date.getDate(freq);
        if date ~= obj.startDate

            newData(1:locations(1)) = nan;

        end

        obj.data = newData;

    else

        error([mfilename ':: Cannot sum over the same frequency or a higher frequency.'])

    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@sumOAF,{sumFreq});
        
    end

end
            

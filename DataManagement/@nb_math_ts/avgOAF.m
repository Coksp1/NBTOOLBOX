function obj = avgOAF(obj,sumFreq) 
% Syntax:
%
% obj = avgOAF(obj,sumFreq)
%
% Description:
%
% Take the average over a lower frequency. Ignoring nan values!
% 
% I.e. if frequency is quartely, this function can take the average over 
% all the quarters of a year. And it will return the average over the year  
% in all quarters of the that year
% 
% Input:
% 
% - obj     : An object of class nb_math_ts
% 
% - sumFreq : The frequency to average over
% 
% Output:
% 
% - obj     : An object of class nb_math_ts where the data is 
%             averaged over a lower frequency
% 
% Examples:
% 
% obj = nb_math_ts.rand('2012Q1',8);
% obj = obj.avgOAF(1)
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen


    freq = obj.startDate.frequency;

    if sumFreq < freq

        [~,locations] = obj.startDate.toDates(0:(obj.endDate - obj.startDate),'default',sumFreq,0);

        newData   = nan(obj.dim1,obj.dim2,obj.dim3);
        for mm = 1:length(locations)

            if mm == 1

                for jj = 1:obj.dim2

                    for zz = 1:obj.dim3

                        ind      = 1:locations(mm);           
                        dataTemp = obj.data(ind,jj,zz);
                        dataTemp = dataTemp(~isnan(dataTemp));
                        if ~isempty(dataTemp)
                            newData(ind,jj,zz) = mean(dataTemp,1,'omitnan');
                        end
                    end

                end

            else
                for jj = 1:obj.dim2

                    for zz = 1:obj.dim3

                        ind      = locations(mm-1) + 1:locations(mm);
                        dataTemp = obj.data(locations(mm-1) + 1:locations(mm),jj,zz);
                        dataTemp = dataTemp(~isnan(dataTemp));
                        if ~isempty(dataTemp)
                            newData(ind,jj,zz) = mean(dataTemp(~isnan(dataTemp)),1,'omitnan');
                        end
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

end
            

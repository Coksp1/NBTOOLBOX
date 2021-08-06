function obj = sumOAF(obj,sumFreq) % sum over another frequency
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
% - obj     : An object of class nb_math_ts
% 
% - sumFreq : The frequency to sum over
% 
% Output:
% 
% - obj     : An object of class nb_math_ts where the data is 
%             summed over a lower frequency
% 
% Examples:
% 
% obj = 
% 
%     '2012Q1'    [   1]
%     '2012Q2'    [   1]
%     '2012Q3'    [   1]
%     '2012Q4'    [   1]
%     '2013Q1'    [   1]
%     '2013Q2'    [   1]
%     '2013Q3'    [   1]
%     '2013Q4'    [   1]
% 
% obj = obj.sumOAF(1)
% 
% obj = 
% 
%     '2012Q1'    [   4]
%     '2012Q2'    [   4]
%     '2012Q3'    [   4]
%     '2012Q4'    [   4]
%     '2013Q1'    [   4]
%     '2013Q2'    [   4]
%     '2013Q3'    [   4]
%     '2013Q4'    [   4]
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen


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
                            newData(ind,jj,zz) = sum(dataTemp,1);
                        end
                    end

                end

            else
                if mm == length(locations)
                   s = 2; 
                end

                for jj = 1:obj.dim2

                    for zz = 1:obj.dim3

                        ind      = locations(mm-1) + 1:locations(mm);
                        dataTemp = obj.data(locations(mm-1) + 1:locations(mm),jj,zz);
                        dataTemp = dataTemp(~isnan(dataTemp));
                        if ~isempty(dataTemp)
                            newData(ind,jj,zz) = sum(dataTemp(~isnan(dataTemp)),1);
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
            

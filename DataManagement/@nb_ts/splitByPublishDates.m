function out = splitByPublishDates(obj,publishDates,lag,format)
% Syntax:
%
% out = splitByPublishDates(obj,publishDates,lag,format)
%
% Description:
%
% 
% 
% Input:
% 
% - obj          : An object of class nb_ts with only one page!
%
% - publishDates : A cellstr or nb_day vector with the dates that the
%                  series has been published backward in time.
% 
% - lag          : The number of periods the series are when published.
%                  E.g. if the observation for the last month of a  
%                  monthly series is published at the 10th of each month, 
%                  then give 1 (default). Give 2 if it is published with 
%                  lag of two months, and so on. 
%
% - format       : The format of the publishing dates stored in the
%                  dataNames property of the output. See the
%                  nb_date.format2string method. Default is 'yyyymmdd'.
%
% Output:
% 
% - out          : An object of class nb_ts with pages given by the series
%                  up to the given date.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        format = 'yyyymmdd';
        if nargin < 3
            lag = 1;
        end
    end

    publishDates = publishDates(:);
    nDates       = size(publishDates,1);
    if iscellstr(publishDates)
        dates(nDates,1) = nb_day;
        for ii = 1:nDates
           dates(ii) = nb_day(publishDates{ii}); 
        end
        publishDates = dates;
    end
    if ~isa(publishDates,'nb_date')
        error([mfilename ':: The publishDates input must either be a cellstr array or a vector of nb_day objects.'])
    end
    
    out  = nb_ts();
    freq = obj.frequency;
    vint = cell(1,nDates);
    for ii = 1:nDates
        endDate  = convert(publishDates(ii),freq) - lag;
        out      = addPages(out,window(obj,'',endDate));
        vint{ii} = nb_date.format2string(publishDates(ii),format);
    end
    out.dataNames = vint;

end

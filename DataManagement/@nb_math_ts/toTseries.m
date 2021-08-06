function tseries_DB = toTseries(obj)
% Syntax:
%
% tseries_DB = toTseries(obj)
%
% Description:
%
% Transform from an nb_math_ts object to an tseries object (IRIS)
% 
% To use this function you need to add the IRIS package to the 
% MATLAB path.
% 
% Input:
% 
% - obj           : An object of class nb_math_ts 
% 
% Output:
% 
% - tseries_DB    : An object of class tseries 
% 
% Examples:
%
% tseries_DB = obj.toTseries();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    tData  = obj.data;
    Dates  = dates(obj);

    try

        switch obj.startDate.frequency

            case {2,4,12}

                for ii=1:length(Dates)
                    Dates{ii} = str2dat(Dates{ii},'dateformat','YYYYFP','freq',obj.startDate.frequency);
                end

            case {1}

                for ii=1:length(Dates)
                    Dates{ii} = str2dat(Dates{ii},'dateformat','YYYY','freq',1);
                end

            otherwise

                error([mfilename ':: tseries class doesn''t support the frequency ' int2str(obj.startDate.frequency) '.'])

        end

        Dates      = cell2mat(Dates);
        tseries_DB = tseries(Dates,tData);

    catch %#ok
        error([mfilename ':: Could not transform to an tseries object. Have you added the IRIS package?'])
    end

end

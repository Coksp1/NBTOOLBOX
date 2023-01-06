function tseries_DB = toTseries(obj)
% Syntax:
%
% tseries_DB = toTseries(obj)
%
% Description:
%
% Transform from an nb_ts object to an tseries object
% 
% To use this function you need to add the IRIS package to the 
% MATLAB path.
% 
% Input:
% 
% - obj           : An nb_ts object
% 
% Output:
% 
% - tseries_DB    : An tseries object
% 
% Examples:
% 
% tseries_DB = obj.toTseries();
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    tData = obj.data;
    dats  = dates(obj);
    if isempty(dats)
        tseries_DB = tseries;
        return 
    end

    try

        switch obj.frequency

            case {2,4,12}

                for ii=1:length(dats)
                    dats{ii} = str2dat(dats{ii},'dateformat','YYYYFP','freq',obj.frequency);
                end

            case {1}

                for ii=1:length(dats)
                    dats{ii} = str2dat(dats{ii},'dateformat','YYYY','freq',1);
                end

            otherwise

                error([mfilename ':: tseries class doesn''t support the frequency ' int2str(obj.frequency) '.'])

        end

        if isa(dats{1},'DateWrapper')
            dats = [dats{:}];
        else
            dats = cell2mat(dats);
        end
        tseries_DB = tseries(dats,tData);

    catch
        error([mfilename ':: Could not transform to an tseries object. Have you added the IRIS package?'])
    end
end

function cellMatrix = asCell(obj,strip)
% Syntax:
%
% cellMatrix = asCell(obj,strip)
%
% Description:
%
% Return the data of the object as a cell matrix. 
% (In the dyn_ts format, i.e. looks like a excel spreadsheet.)
% 
% Input:
% 
% - obj        : An object of class nb_data
% 
% - strip      : - 'on'  : Strip all observation where all 
%                          the variables has no value. 
% 
%                - 'off' : Does not strip all observation where all
%                          the variables has no value. Default.
%                           
% Output:
% 
% - cellMatrix : The nb_data objects data transformed to a cell. 
% 
% Examples:
% 
% cellMatrix = obj.asCell();
% cellMatrix = obj.asCell('on');
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        strip = 'off';
    end

    corner = {'Obs'};
    corner = corner(:,:,ones(1,obj.numberOfDatasets));
    vars   = obj.variables(:,:,ones(1,obj.numberOfDatasets));
    if strcmpi(strip,'on')
              
        if isa(obj.data,'nb_distribution')
            error([mfilename ':: Cannot set strip to ''on'' if the data is of class nb_distribution.'])
        end
        
        d          = obj.data;
        ind        = all(all(isnan(d),2),3);
        d          = d(~ind,:,:);
        obs        = observations(obj,'cell');
        obs        = obs(~ind,1);
        obs        = obs(:,:,ones(1,obj.numberOfDatasets)); 
        cellMatrix = [corner, vars; obs, num2cell(d)];

    else
        
        if isa(obj.data,'nb_distribution')
            d = reshape({obj.data.name},[obj.numberOfObservations,obj.numberOfVariables,obj.numberOfDatasets]);
        else
            d = num2cell(obj.data);
        end
        obs        = observations(obj,'cell');
        obs        = obs(:,:,ones(1,obj.numberOfDatasets));
        cellMatrix = [corner, vars; obs, d];
        
    end

end

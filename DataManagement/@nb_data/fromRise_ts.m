function data = fromRise_ts(obj)
% Syntax:
%
% data = nb_data.fromRise_ts(obj)
%
% Description:
%
% Transform from an RISE ts object or a struct of RISE ts objects 
% to a nb_data object.
% 
% Input: 
% 
% - obj    : An object of class ts, or a structure of ts 
%            objects.
%   
% Output:
% 
% - data   : An nb_data object. Be aware that the time dimension is
%            stripped when using this transformation.
%               
% Examples:
% 
% data = nb_data.fromRise_ts();
% 
% Written by Kenneth S. Paulsen  

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(obj,'ts')
        
        data = nb_data(double(obj),'',1,obj.varnames);
        
    elseif isstruct(obj)
        
        obj         = orderfields(obj);
        fields      = fieldnames(obj);
        numVar      = length(fields);
        temp_ts     = obj.(fields{1});
        numPages    = temp_ts.NumberOfPages;
        numObs      = temp_ts.NumberOfObservations;
        data        = nan(numObs,numVar,numPages);
        data(:,1,:) = double(temp_ts);
        for ii = 2:numVar
            
            temp_ts = obj.(fields{ii});
            try
                data(:,ii,:) = double(temp_ts);
            catch
                error([mfilename ':: All the ts objects stored in the structure must be of class ts. And all ts object must have the same size.'])
            end
            
        end
        
        data = nb_data(data,'',1,fields);
        
    end
    
end

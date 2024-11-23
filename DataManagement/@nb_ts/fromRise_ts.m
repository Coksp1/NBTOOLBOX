function data_ts = fromRise_ts(obj)
% Syntax:
%
% data_ts = nb_ts.fromRise_ts(obj)
%
% Description:
%
% Transform from an RISE ts object or a struct of rise ts objects 
% to an nb_ts object.
% 
% Input: 
% 
% - obj     : An object of class ts, or a structure of ts 
%             objects.
%   
% Output:
% 
% - data_ts : An nb_ts object.
%               
% Written by Kenneth S. Paulsen  

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(obj,'ts')
        
        data_ts = nb_ts(double(obj),'',obj.start,obj.varnames);
        
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
        data_ts = nb_ts(data,'',temp_ts.start,fields);
        
    end
    
end

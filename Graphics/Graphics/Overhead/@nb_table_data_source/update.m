function obj = update(obj,warningOff,inGUI)
% Syntax:
% 
% obj = update(obj)
% 
% Description:
% 
% Update the data source of the table
% 
% See the update method of the nb_ts, nb_cs and nb_data classes for more  
% on how to make the data of the graph updateable.
%
% Input:
% 
% - obj      : An object of class nb_table_data_source
% 
% Output:
% 
% - obj      : An object of class nb_table_data_source, where the data is 
%              updated.
%     
% Examples:
%
% obj.update();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        inGUI = 'off';
        if nargin < 2
            warningOff = 'on';
        end
    end
    
    if isa(obj.DB,'cell')
        error('The data of the table is not updateable')
    end

    obj.DB = update(obj.DB,warningOff,inGUI);
    
    if isa(obj,'nb_table_ts') || isa(obj,'nb_table_data') 
        
        if ~obj.manuallySetStartTable
            if isa(obj,'nb_table_ts')
                obj.startTable = obj.DB.startDate;
            else
                obj.startTable = obj.DB.startObs;
            end
        end

        if ~obj.manuallySetEndTable
            if isa(obj,'nb_table_ts')
                obj.endTable = obj.DB.endDate;
            else
                obj.endTable = obj.DB.endObs;
            end
        end
        
    end

end

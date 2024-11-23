function mergeDatasetEngine(gui)
% Syntax:
%
% mergeDatasetEngine(gui)
%
% Description:
%
% Part of DAG. Check the data objects to merge
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(gui.data1,'nb_ts') && isa(gui.data2,'nb_ts') 

        if gui.data1.frequency == gui.data2.frequency
            originalTSMerge(gui);
        else 
            differentFreqMerge(gui);   
        end

    elseif isa(gui.data1,'nb_cs') && isa(gui.data2,'nb_cs')

        originalCSMerge(gui);
        
    elseif isa(gui.data1,'nb_data') && isa(gui.data2,'nb_data')
        
        originalDataMerge(gui);
        
    elseif (isa(gui.data1,'nb_data') && isa(gui.data2,'nb_ts')) || (isa(gui.data1,'nb_ts') && isa(gui.data2,'nb_data'))

        nb_errorWindow('Currently it is not possible to merge Time-series with dimensionless data. Please contact the GUI development team if it is needed...')
        
    else % One nb_ts and one nb_cs object

        differentObjectsMerge(gui);

    end

end 

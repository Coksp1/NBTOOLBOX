function mergeDatasetEngine(gui)
% Syntax:
%
% mergeDatasetEngine(gui)
%
% Description:
%
% Part of DAG. Check the data objects to merge.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(gui.data1,'nb_ts') && isa(gui.data2,'nb_ts')

        if gui.data1.frequency == gui.data2.frequency
            originalTSMerge(gui);
        else 
            differentFreqMerge(gui);   
        end
        
    else 
        nb_errorWindow('The selected dataset(s) must be time-series.');
    end

end 

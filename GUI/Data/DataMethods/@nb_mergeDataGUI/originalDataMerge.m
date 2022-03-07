function originalDataMerge(gui)
% Syntax:
%
% originalDataMerge(gui)
%
% Description:
%
% Part of DAG. Open up dialog box for merging two nb_data objects
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    %Check for conflicting variables
    var1  = gui.data1.variables;
    var2  = gui.data2.variables;
    index = find(ismember(var2,var1));

    if isempty(index)

        try
            gui.data = gui.data1.merge(gui.data2);
        catch
            nb_errorWindow('Cannot merge the two datasets.');
            return
        end
        storeToGUI(gui)
        return

    else
        
        try
            gui.data = merge(gui.data1,gui.data2);
            storeToGUI(gui);
            return
        catch %#ok<CTCH>
            % Just continue
        end

        message = ['The following variables are stored in both datasets ' var2{index(1)}];
        for ii = 2:size(index,2)
            message = [message ', ' var2{1,index(ii)}]; %#ok
        end
        message = [message '. From which dataset do you want to keep the variables?'];

        % The merging will depend on how the user respond
        try
            deletedVars   = var2(index);
            data1Temp     = gui.data1.deleteVariables(deletedVars);
            mergedDataYes = data1Temp.merge(gui.data2);
            data2Temp     = gui.data2.deleteVariables(deletedVars);
            mergedDataNo  = gui.data1.merge(data2Temp);
        catch Err
            
            nb_errorWindow('Merging unsuccessfull!', Err)
            return
            
        end

        %Ask for respons
        nb_confirmWindow(message,{@gui.callbackSaveOnResponse,mergedDataNo},...
                                 {@gui.callbackSaveOnResponse,mergedDataYes},...
                                 'Merge Option',...
                                 gui.saveName1,...
                                 gui.saveName2);

    end

end

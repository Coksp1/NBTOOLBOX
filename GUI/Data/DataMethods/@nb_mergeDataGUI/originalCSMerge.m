function originalCSMerge(gui)
% Syntax:
%
% originalCSMerge(gui)
%
% Description:
%
% Part of DAG. Open up dialog box for merging two nb_ts objects  
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Check for conflicting variables
    var1  = gui.data1.variables;
    var2  = gui.data2.variables;
    index = find(ismember(var2,var1));

    % Check for conflicting types
    t1     = gui.data1.types;
    t2     = gui.data2.types;
    indexT = find(ismember(t2,t1));

    if isempty(index) || isempty(indexT)

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
        catch
            % Just continue
        end

        if ~isempty(index) && all(ismember(t2,t1)) && all(ismember(t1,t2))

            message = ['The following variables are stored in both datasets ' var2{index(1)}];
            for ii = 2:size(index,2)
                message = [message ', ' var2{1,index(ii)}]; %#ok
            end
            message = [message '. From which dataset do you want to keep the variables?'];

            % The merging will depend on how the user respond
            deletedVars   = var2(index);
            data1Temp     = gui.data1.deleteVariables(deletedVars);
            mergedDataYes = data1Temp.merge(gui.data2);
            data2Temp     = gui.data2.deleteVariables(deletedVars);
            mergedDataNo  = gui.data1.merge(data2Temp);

        elseif ~isempty(indexT) && all(ismember(var2,var1)) && all(ismember(var2,var1))

            message = ['The following types are stored in both datasets ' t1{indexT(1)}];
            for ii = 2:size(indexT,2)
                message = [message ', ' t1{1,indexT(ii)}]; %#ok
            end
            message = [message '. From which dataset do you want to keep the types?'];    

            % The merging will depend on how the user respond
            deletedTypes  = t1(indexT);
            data1Temp     = gui.data1.deleteTypes(deletedTypes);
            mergedDataYes = data1Temp.merge(gui.data2);
            data2Temp     = gui.data2.deleteTypes(deletedTypes);
            mergedDataNo  = gui.data1.merge(data2Temp);

        else

            message = ['The following types are stored in both datasets ' t1{indexT(1)}];
            for ii = 2:size(indexT,2)
                message = [message ', ' t1{1,indexT(ii)}]; %#ok
            end
            message = [message ' and the following variables are stored in both datasets ' var2{index(1)}];
            for ii = 2:size(index,2)
                message = [message ', ' var2{1,index(ii)}]; %#ok
            end
            message = [message '. This makes it impossible to merge the datasets.'];  
            
        end

    end

    % Ask for respons if variables or types are conflicting
    nb_confirmWindow(message,{@gui.callbackSaveOnResponse,mergedDataNo},...
                             {@gui.callbackSaveOnResponse,mergedDataYes},...
                             'Merge Option',...
                             gui.saveName1,...
                             gui.saveName2);

end

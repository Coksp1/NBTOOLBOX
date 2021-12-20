function obj = deleteTypes(obj,deletedType)
% Syntax:
%
% obj = deleteTypes(obj,deletedType)
%
% Description:
% 
% Delete types from the current nb_cs object (letter size 
% has somthing to say)
%
% If some of the types you specify in deletedType does not  
% exist in the obj, this will not have anything to say for the obj. 
% (The types cannot be deleted, because the types do not 
% exist.)
% 
% Input:
% 
% - obj         : An object of class nb_cs
% 
% - deletedType : Must be a char or a cellstr
% 
%     Delete all the type names, given in the char array 
%     or cellstr array deletedType, of current the nb_cs object.
% 
%     NB! If deletedType is just one string and include a * as the 
%         last letter, this function will delete all the type 
%         names, from the object, that start with the letters which 
%         is in front of the * in the string. 
% 
%         i.e. obj = deleteTypes(obj,'DPQ*');
% 
%         Deletes all the types in the obj which has type names 
%         starting with 'DPQ'.
% 
%         If deletedType is just one string and include a * as the 
%         first letter, this function will delete all the type 
%         names, from the object, that include the letters which 
%         follows in the string.
% 
%         i.e. obj = deleteTypes(obj, '*shift');
% 
%         Deletes all the types in the obj which has type names 
%         which include 'shift'.
% 
% Output: 
%
% - obj : A nb_cs object with the types specified in 
%         deletedType deleted.
% 
% Examples:
%
% obj = nb_cs([2;2],'test',{'First','Second'},{'Var1'});
% obj = deleteTypes(obj, {'First','Second'});
% obj = deleteTypes(obj, char('First','Second'));
% obj = deleteTypes(obj, obj.types);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~ischar(deletedType) && ~iscellstr(deletedType)
        error([mfilename ':: The second argument (including the object itself) should be a char, char array or a cellstr'])
    end

    if isempty(obj.types)
        warning([mfilename,':: The object dosen''t contain any types, no types to be deleted']) 
    end

    if ischar(deletedType) && (size(deletedType, 1) == 1) && ~isempty(strfind(deletedType,'*'))

        if strcmp('*',deletedType(1,1))

            % Delete all types including the string 
            % 'deletedType'
            tIndex = zeros(size(obj.types));
            for j = 1:size(obj.types,2)

                try
                    found = strfind(obj.types{j}, strtrim(deletedType(1,2:end)));

                    if ~isempty(found)
                        tIndex(j) = 1;
                    end
                catch err

                    if strcmp(err.identifier,'MATLAB:index_assign_element_count_mismatch')
                        % Do nothing
                    else
                        rethrow(err)
                    end

                end

            end

        else

            % Delete all types starting with the string 
            % 'deletedType'
            tIndex = zeros(size(obj.types));
            len    = length(deletedType) - 1;
            for j = 1:size(obj.types,2) 
                try 
                    tIndex(j) = strcmp(obj.types{j}(1,1:len), strtrim(deletedType(1,1:end-1)));
                catch err

                    if strcmp(err.identifier,'MATLAB:badsubscript')
                        % Do nothing. (the obj.types{j} 
                        % is to short to possibly be starting 
                        % with the string 'deletedType')
                    else
                        rethrow(err)
                    end

                end
            end

        end

    else
        % Here we delete all types given in the array 
        % 'deletedType' (can be of size 1)

        deletedType = cellstr(deletedType);

        tIndex     = zeros(size(obj.types));
        for j = 1:length(deletedType)

            tIndex = tIndex + strcmp(deletedType{j}, obj.types);

        end

    end

    % Delete the found types in the dataset 
    tlocs = find(~tIndex);
    if isempty(tlocs)

        % All the types is being deleted
        obj = obj.empty();

    else
        nt        = size(find(tIndex),2);
        obj.types = obj.types(tlocs);
        obj.data  = obj.data(tlocs,:,:);
    end

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@deleteTypes,{deletedType});
        
    end
    
end

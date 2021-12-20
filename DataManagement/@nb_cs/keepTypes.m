function obj = keepTypes(obj,keptType)
% Syntax:
%
% obj = keepTypes(obj,keptType)
%
% Description:
%
% Keep types from the current nb_cs object (letter size 
% has somthing to say)
%
% If some of the types you specify in keptType does not exist 
% in the object, this will not have anything to say for the object. 
% (The types cannot be kept, because the types do not 
% exist.)
%
% Input:
% 
% - obj        : An object of class nb_cs
% 
% - keptType    : Must be a char or a cellstr
% 
%     Keeps all the type names, given in the char array 
%     or cellstr array keptType, of current the nb_cs object.
% 
%     NB! If keptType is just one string and include a * as the 
%           last letter, this function will keep all the type 
%           names, from the DB, that start with the letters which 
%           is in front of the * in the string. 
% 
%         i.e. obj = keepTypes(obj,'DPQ*');
% 
%         Keep all the types in the obj which has type 
%         names starting with 'DPQ'.
% 
% 
%         If keptType is just one string and include a * as the 
%           first letter, this function will keep all the type 
%           names, from the DB, that include the letters which 
%           follows in the string.
% 
%         i.e. obj = keepTypes(obj, '*shift');
% 
%         Keeps all the types in the obj which has type 
%         names which include 'shift'.
% 
% Output: 
%
% - obj         : A nb_cs object with the types specified in 
%                 the input keptType kept, all the others are 
%                 deleted.
% 
% Examples:
%
% obj = nb_cs([2;2],'test',{'First','Second'},{'Var1'});
% obj = obj.keepTypes({'First','Second'});
% obj = obj.keepTypes(char('First','Second'));
% obj = obj.keepTypes(obj.types);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen


    if ~ischar(keptType) && ~iscellstr(keptType)
        error([mfilename ':: The second argument (including the object itself) should be a char, char array or a cellstr'])
    end

    if isempty(obj.types)
        warning('nb_cs:keepTypes:empty',[mfilename,':: The object dosen''t contain any types, no types to be kept']) 
    end

    if ischar(keptType) && (size(keptType, 1) == 1) && ~isempty(strfind(keptType,'*'))

        if strcmp('*',keptType(1,1))

            % Keep all types including the string 
            % 'keptType'
            tIndex = zeros(size(obj.types));
            for j = 1:size(obj.types,2)

                try
                    found = strfind(obj.types{j}, strtrim(keptType(1,2:end)));

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

            % Keep all types starting with the string 
            % 'keptType'
            tIndex = zeros(size(obj.types));
            len      = length(keptType) - 1;
            for j = 1:size(obj.types,2) 
                try 
                    tIndex(j) = strcmp(obj.types{j}(1,1:len), strtrim(keptType(1,1:end-1)));
                catch err

                    if strcmp(err.identifier,'MATLAB:badsubscript')
                        % Do nothing. (the obj.types{j} 
                        % is to short to possibly be starting 
                        % with the string 'keptType')
                    else
                        rethrow(err)
                    end

                end
            end

        end

    else
        % Here we keep all the types given in the array 
        % 'keptType' (can be of size 1)

        keptType = cellstr(keptType);

        tIndex     = zeros(size(obj.types));
        for j = 1:length(keptType)

            tIndex = tIndex + strcmp(keptType{j}, obj.types);

        end

    end

    % Keep the found types in the dataset 
    tlocs = find(tIndex);
    if isempty(tlocs)

        % No types to keep
        obj = obj.empty();

    else
        obj.types         = obj.types(tlocs);
        obj.data          = obj.data(tlocs,:,:);
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@keepTypes,{keptType});
        
    end

end

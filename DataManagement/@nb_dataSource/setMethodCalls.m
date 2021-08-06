function obj = setMethodCalls(obj,c)
% Syntax:
%
% obj = setMethodCalls(obj,c)
%
% Description:
%
% Set all method calls of the object with a cell matrix. The object needs 
% to be updatable.
%
% Caution: To delete method calls use deleteMethodCalls
%
% Caution: Call obj = update(obj) to interpret the changes made!
% 
% Input:
% 
% - obj : An object of class nb_ts, nb_cs or nb_data.
%
% - c   : A cell matrix. See the output of getMethodCalls
% 
% Output:
%
% - obj : An object of class nb_ts, nb_cs or nb_data. 
%
% See also:
% nb_dataSource.deleteMethodCalls, nb_dataSource.getMethodCalls
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~obj.updateable
        error([mfilename ':: The object is not updateable'])
    end
    
    link     = obj.links;
    nSources = size(link.subLinks,2);
    dim3     = size(c,3);
    if nSources ~= dim3
        error([mfilename ':: The number of sources and the third dimension of the c input does not match'])
    end
    
    % Set the updated method calls for each source
    for ii = 1:nSources
        
        oldOp = link.subLinks(ii).operations;
        newOp = oldOp;
        for jj = 1:size(c,1)
            
            method = c{jj,1,ii};
            if isempty(method) || strcmpi(method,'not editable')
                break
            end
            try
                methodOld = oldOp{jj}{1};
                if ~ischar(methodOld)
                    methodOld = func2str(methodOld);
                end
            catch  %#ok<CTCH>
                error([mfilename ':: The provided cell matrix is inconsitent with the method calls of the object.'])
            end
            if ~strcmp(methodOld,method)
                error([mfilename ':: The provided cell matrix is inconsitent with the method calls of the object.'])
            end
            
            inputsOld = oldOp{jj}{2};
            inputs    = c(jj,2:end,ii);
            for ll = 1:length(inputsOld)
               
                inp    = inputs{ll};
                inpOld = inputsOld{ll};
                if strcmpi(inp,'Not editable')
                    inp = inpOld;
                elseif isnumeric(inpOld) && numel(inpOld) == 1
                    
                    if ischar(inp)
                        if strcmpi(inp,'nan')
                            inp = nan;
                        else
                            inpTemp = str2double(inp);
                            if isnan(inpTemp)
                                error([mfilename ':: The input nr ' int2str(ll) ' to the method ' method ' must be a number, but is ' class(inp)])
                            end
                            inp = inpTemp;
                        end
                    else
                        if ~isnumeric(inp)
                            error([mfilename ':: The input nr ' int2str(ll) ' to the method ' method ' must be a number, but is ' class(inp)])
                        end
                    end
                    
                elseif iscellstr(inpOld)
                    
                    % Convert from string representing a cellstr 2 cellstr
                    if numel(inp,2) && strcmp(inp,'{}')
                        inp = {};
                    else
                        inp = inp(2:end-1);
                        inp = regexp(inp,'\s\\\\\s','split'); 
                    end
                    
                elseif isa(inpOld,'nb_date') && ischar(inp)
                    
                    try
                        interpretDateInput(obj,inp);
                    catch %#ok<CTCH>
                        error([mfilename ':: The input nr ' int2str(ll) ' to the method ' method ' must be a string representing '...
                            'a date on the frequency ' nb_date.getFrequencyAsString(obj.frequency) ' or refer to a local variable that does. Is ' inp])
                    end
                    
                elseif ischar(inpOld) && ~ischar(inp)
                    
                    error([mfilename ':: The input nr ' int2str(ll) ' to the method ' method ' must be a string, but is ' class(inp)])
                    
                elseif ~isa(inp,class(inpOld))
                    
                    error([mfilename ':: The input nr ' int2str(ll) ' to the method ' method ' must be of ' class(inpOld) ', but is of class ' class(inp)])

                end 
                
                inputsOld{ll} = inp;
                
            end
            
            newOp{jj}{2} = inputsOld;
            
        end
        link.subLinks(ii).operations = newOp;
        
    end
    
    % Assign object the new method calls (operations)
    obj.links = link;

end

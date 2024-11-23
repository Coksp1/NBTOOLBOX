function varargout = subsasgn(obj,s,b)
% Syntax:
%
% varargout = subsasgn(obj,s,b)
%
% Description:
%
% Makes it possible to do subscripted assignment of the data of an
% object
%
% Input:
% 
% - obj    : An object of class nb_data
% 
% - s      : The same input as when you do subscripted assignment 
%            one a double matrix
% 
% - b      : The assign data at the given index s.
% 
% Output:
%
% - obj    : The assign data property setted of the given object.
% 
% Examples:
% 
% obj        = nb_data([2;3;4],'',1,{'Var1'}); 
% obj(1:3,1) = [1;2;3]
% obj = 
% 
%     'Time'    'Var1'
%     '2012'    [   1]
%     '2013'    [   2]
%     '2014'    [   3]
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    switch s(1).type

        case '()'

            if isnumeric(s(1).subs{1}) || strcmpi(s(1).subs{1},':')
                try 
                    index1 = s(1).subs{1};
                    try 
                        index2 = s(1).subs{2};
                    catch Err
                        switch Err.identifier
                            case 'MATLAB:badsubscript'
                                index2 = 1;
                            otherwise
                                rethrow(Err)
                        end
                    end

                    try 
                        index3 = s(1).subs{3};
                    catch Err
                        switch Err.identifier
                            case 'MATLAB:badsubscript'
                                index3 = 1;
                            otherwise
                                rethrow(Err)
                        end
                    end

                catch Err

                    switch Err.identifier
                        case 'MATLAB:badsubscript'
                            % If you write obj() you keep the size of
                            % the object.
                            index1 = 1:obj.numberOfObservations;
                            index2 = 1:obj.numberOfVariables;
                            index3 = 1:obj.numberOfDatasets;
                        otherwise
                            rethrow(Err)
                    end
                end

                if obj.updateable
                    error([mfilename ':: Wrong asignment. Data is updateable'])
                else
                    if isa(b,'nb_data')
                        check(obj,b,index1,index2,index3);
                        loc                            = ismember(b.variables,obj.variables(index2));
                        db                             = double(b);
                        obj.data(index1,index2,index3) = db(:,loc,:);
                    else
                        obj.data(index1,index2,index3) = b;
                    end
                end
                varargout{1} = obj;
                
            elseif isa(s(1).subs{1},'nb_data')
                
                objInd = s(1).subs{1};
                if ~islogical(objInd.data)
                    error([mfilename ':: Wrong asignment.'])
                end
                [~,err] = checkConformity(obj,objInd);
                nb_data.errorConformity(err)
                if obj.updateable
                    error([mfilename ':: Wrong asignment. Data is updateable'])
                else
                    obj.data(objInd.data) = b;
                end
                varargout{1} = obj;     

            else
                error([mfilename ':: Wrong asignment.'])
            end

        otherwise

            % Makes it possible to asign properties 
            % of the object in the ordinary way.
            [varargout{1:nargout}]  = builtin('subsasgn', obj, s, b);

    end

end

function check(obj,b,index1,index2,index3)

    if strcmpi(index1,':')
        if obj.startObs ~= b.startObs || obj.endObs ~= b.endObs
            error([mfilename ':: The start and end obs of the assign object must match ',...
                             'the window of the object being assing to.'])
        end
    else
        if length(index1) ~= index1(end) - index1(1) + 1
            error([mfilename ':: The index in the first dimension cannot have wholes.'])
        end
        if any(index1 < 1)
            error([mfilename ':: The index in the first dimension cannot be negative or zero.'])
        end
        if obj.startDate + (index1(1) - 1) ~= b.startObs || obj.startObs + (index1(end) - 1) ~= b.endObs
            error([mfilename ':: The start and end obs of the assign object must match ',...
                             'the window of the object being assing to.'])
        end
    end
    
    if strcmpi(index2,':')
        if obj.numberOfVariables ~= b.numberOfVariables
            error([mfilename ':: When the second index is given as : the two object must have the same number of variables.'])
        end
        test = ismember(obj.variables,b.variables);
        if ~all(test)
            error([mfilename ':: When the second index is given as : the two object must have the same variables.'])
        end
    else
        if length(index2) ~= b.numberOfVariables
            error([mfilename ':: The second index results in dimension mismatch. Is ' int2str(length(index2)) ...
                             ', but must be ' int2str(b.numberOfVariables) '.'])
        end
        if any(index2 < 1)
            error([mfilename ':: The index in the second dimension cannot be negative or zero.'])
        end
        test = ismember(obj.variables(index2),b.variables);
        if ~all(test)
            error([mfilename ':: The indexed variables of the object assign to must match the variables ',...
                             'of object assign from.'])
        end
    end
    
    if strcmpi(index3,':')
        if b.numberOfDatasets ~= obj.numberOfDatasets
            error([mfilename ':: When the third index is given as : the two object must have the same number of pages.']) 
        end
    else
        if length(index3) ~= b.numberOfDatasets
            error([mfilename ':: The third index results in dimension mismatch. Is ' int2str(length(index3)) ...
                             ', but must be ' int2str(b.numberOfDatasets) '.'])
        end
        if any(index3 < 1)
            error([mfilename ':: The index in the third dimension cannot be negative or zero.'])
        end
    end
             
end

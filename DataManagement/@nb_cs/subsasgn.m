function varargout = subsasgn(obj,s,b)
% Syntax:
%
% varargout = subsasgn(obj,s,b)
%
% Description:
%
% Makes it possible to do subscripted assignment of the data of an
% nb_cs object
% 
% Input:
% 
% - obj    : AN object of class nb_cs
% 
% - s      : The same input as when you do subscripted assignment 
%            one a double matrix
% 
% - b      : The assign data at the given index s.
% 
% Output:
% 
% - obj    : An nb_cs object where the assign data property is 
%            setted.
% 
% Examples:
% 
% obj(1:2) = [2;3];
% 
%     same as
% 
%     obj(1:2,1,1) = [2;3];
% 
%     same as
% 
%     obj.data(1:2,1,1) = [2;3];
% 
%     obj(1:2,2,3) = [2;3];
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    switch s(1).type

        case '()'

            if isnumeric(s(1).subs{1})
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
                            index1 = 1:obj.numberOfTypes;
                            index2 = 1:obj.numberOfVariables;
                            index3 = 1:obj.numberOfDatasets;
                        otherwise
                            rethrow(Err)
                    end
                end

                if obj.updateable
                    error([mfilename ':: Wrong asignment. Data is updateable'])
                else
                    obj.data(index1,index2,index3) = b;
                end
                varargout{1} = obj;
                
            elseif isa(s(1).subs{1},'nb_cs')
                
                objInd = s(1).subs{1};
                if ~islogical(objInd.data)
                    error([mfilename ':: Wrong asignment.'])
                end
                [~,err] = checkConformity(obj,objInd);
                nb_cs.errorConformity(err)
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

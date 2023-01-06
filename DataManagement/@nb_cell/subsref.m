function varargout = subsref(obj,s)
% Syntax:
%
% Description:
%
% Makes it possible to do subscripted reference of the data of a
% nb_cell object. See the examples for more
% 
% Uses the method window, just using indexing instead
% 
% Input:
% 
% - obj    : An object of class nb_cell
% 
% - s      : A structure on have to index the object
% 
% Output:
% 
% - obj    : An nb_cs object indexed as wanted.
% 
% Examples:
% 
% obj = obj(1,2:4,1)
% 
%     same as
% 
%     obj = obj(1,2:4)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    switch s(1).type

        case '()'

            if isnumeric(s(1).subs{1}) % Try to index the 'cdata' property

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
                            index1 = 1:size(obj.data,1);
                            index2 = 1:size(obj.data,2);
                            index3 = 1:obj.numberOfDatasets;

                        otherwise

                            rethrow(Err)

                    end

                end

                obj.c    = obj.c(index1,index2,index3);
                obj.data = obj.data(index1,index2,index3);

                if isempty(obj.data)
                    obj = empty(obj);
                else
                    obj.dataNames         = obj.dataNames(1,index3);
                end

                if size({s.type},2) > 1
                    % Make it possible to for example write
                    % obj(1,2,3).data
                    try
                        [varargout{1:nargout}] = builtin('subsref', obj, s(2:end));
                    catch  %#ok<CTCH>
                        builtin('subsref', obj, s(2:end));
                    end
                else
                    varargout{1} = obj;
                end

            else

                % To be robust
                [varargout{1:nargout}]  = builtin('subsref', obj, s);

            end

        otherwise

            % Makes it possible to reference properties and methods 
            % of the object in the ordinary way.
            [varargout{1:nargout}]  = builtin('subsref', obj, s);

    end

end

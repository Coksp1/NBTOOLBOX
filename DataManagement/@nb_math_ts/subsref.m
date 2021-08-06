function varargout = subsref(obj,s)
% Syntax:
%
% varargout = subsref(obj,s)
%
% Description:
%
% Makes it possible to do subscripted reference of the data of an
% nb_math_ts object. See the examples for more
% 
% Using the method window, just using indexing instead
% 
% Input:
% 
% - obj    : An object of class nb_math_ts
% 
% - s      : A structure on have to index the object
% 
% Output:
% 
% - obj    : The indexed object.
% 
% Examples:
% 
% obj = obj(1,2:4,1)
% 
%     same as
% 
%     obj = obj(1,2:4)
% 
%     Be aware that that obj(1,:) will work but not obj(1,2:end)
% 
% 
% obj = obj('1994Q1')
% 
%     same as
% 
%     obj.window('1994Q1','1994Q1')
% 
% 
% obj = obj('1994Q1','1994Q4')
% 
%     same as 
% 
%     obj.window('1994Q1','1994Q4')
% 
%
% obj = obj('1994Q1','1994Q4',1:2)
% 
%     same as 
% 
%     obj.window('1994Q1','1994Q4',1:2)
% 
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch s(1).type

        case '()'

            if ischar(s(1).subs{1}) % variable indexation;  obj = obj('Var1','Var2',...)

                startsWithANumber = regexp(s(1).subs{1},'^[0-9]','match');

                if isempty(startsWithANumber) && ~isempty(s(1).subs{1})

                    if strcmp(s(1).subs{1},':')
                        s(1).subs{1} = 1:obj.dim1;
                        varargout    = subsref(obj,s);
                        varargout    = {varargout};
                    else
                        error([mfilename ':: Not possible to index an object of class nb_math_ts with a string which is not a date'])
                    end

                else

                    switch size(s(1).subs,2)

                        case 1

                            % Make it possible to for example write
                            % obj('date'), which is the same
                            % as obj.window('date','date')
                            date         = s(1).subs{1};
                            obj          = window(obj,date,date);

                            if size({s.type},2) > 1
                                % Make it possible to for example write
                                % obj('date').data
                                try
                                    varargout{1}  = builtin('subsref', obj, s(2:end));
                                catch %#ok
                                    builtin('subsref', obj, s(2:end));
                                end
                            else
                                varargout{1} = obj;
                            end

                        case 2

                            % Make it possible to for example write
                            % obj('startdate','endDate'), which is 
                            % the same as 
                            % obj.window('startDate','endDate')
                            startDateWin = s(1).subs{1};
                            endDateWin   = s(1).subs{2};
                            obj          = window(obj,startDateWin,endDateWin);

                            if size({s.type},2) > 1
                                % Make it possible to for example write
                                % obj.window('startDate','endDate').data
                                try
                                    varargout{1}  = builtin('subsref', obj, s(2:end));
                                catch %#ok
                                    builtin('subsref', obj, s(2:end));
                                end
                            else
                                varargout{1} = obj;
                            end

                        case 3

                            % Make it possible to for example write
                            % obj('startdate','endDate',pages), 
                            % which is the same as 
                            % obj.window('startDate','endDate',pages)
                            startDateWin = s(1).subs{1};
                            endDateWin   = s(1).subs{2};
                            pages        = s(1).subs{3};
                            obj          = window(obj,startDateWin,endDateWin,pages);

                            if size({s.type},2) > 1
                                % Make it possible to for example write
                                % obj.window('startDate','endDate',{'Var1','Var2',...}).data
                                try
                                    varargout{1}  = builtin('subsref', obj, s(2:end));
                                catch %#ok
                                    builtin('subsref', obj, s(2:end));
                                end
                            else
                                varargout{1} = obj;
                            end

                        otherwise

                            error([mfilename ':: You are using a short notation for the window method, which only takes 3 inputs. '...
                                             'Currently given ' int2str(size(s(1).subs,2)) ' inputs.'])
                    end

                end

            elseif isnumeric(s(1).subs{1}) % Try to index the 'data' property

                try 
                    index1 = s(1).subs{1};

                    try 
                        index2 = s(1).subs{2};
                    catch Err

                        switch Err.identifier

                            case 'MATLAB:badsubscript'

                                index2 = 1:obj.dim2;

                            otherwise

                                rethrow(Err)

                        end

                    end

                    try 
                        index3 = s(1).subs{3};
                    catch Err

                        switch Err.identifier

                            case 'MATLAB:badsubscript'

                                index3 = 1:obj.dim3;

                            otherwise

                                rethrow(Err)

                        end

                    end

                catch Err

                    switch Err.identifier

                        case 'MATLAB:badsubscript'

                            % If you write obj() you keep the size of
                            % the object.
                            index1 = 1:obj.dim1;
                            index2 = 1:obj.dim2;
                            index3 = 1:obj.dim3;

                        otherwise

                            rethrow(Err)

                    end

                end
                
                if strcmp(index2,':')
                    index2 = 1:obj.dim2;
                end
                
                if strcmp(index2,':')
                    index3 = 1:obj.dim3;
                end

                obj.data = obj.data(index1,index2,index3);
                if isempty(obj.data)
                    obj = empty(obj);
                else
                    obj.startDate = obj.startDate + index1(1) - 1;
                    obj.endDate   = obj.startDate + index1(end) - index1(1);
                end

                if size({s.type},2) > 1
                    % Make it possible to for example write
                    % obj(1,2,1).data
                    try
                        varargout{1}  = builtin('subsref', obj, s(2:end));
                    catch 
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

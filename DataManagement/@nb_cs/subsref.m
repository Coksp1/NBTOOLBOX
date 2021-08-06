function varargout = subsref(obj,s)
% Syntax:
%
% Description:
%
% Makes it possible to do subscripted reference of the data of an
% nb_cs object. See the examples for more
% 
% Uses the method window, just using indexing instead
% 
% Input:
% 
% - obj    : An object of class nb_cs
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
% 
% obj = obj({'Type1','Type2',...})
% 
%     same as 
% 
%     obj.window({'Type1','Type2',...})
% 
% 
% obj = obj({'Type1','Type2',...},{'Var1','Var2',...})
% 
%     same as 
% 
%     obj.window({'Type1','Type2',...},{'Var1','Var2',...})
% 
% 
% obj = obj({'Type1','Type2',...},{'Var1','Var2',...},1:2)
% 
%     same as 
% 
%     obj.window({'Type1','Type2',...},{'Var1','Var2',...},1:2)
% 
% 
% obj = obj('Var1','Var2',...)
% 
%     same as 
% 
%     obj.window('','',{'Var1','Var2',...},1:obj.numberOfDatasets)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch s(1).type

        case '()'

            if isnumeric(s(1).subs{1}) || strcmpi(s(1).subs{1},':') || islogical(s(1).subs{1}) % Try to index the 'data' property

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

                if strcmpi(index1,':')
                    index1 = 1:obj.numberOfTypes;
                end
                if strcmpi(index2,':')
                    index2 = 1:obj.numberOfVariables;
                end
                if strcmpi(index3,':')
                    index3 = 1:obj.numberOfDatasets;
                end
                
                obj.data = obj.data(index1,index2,index3);

                if isempty(obj.data)

                    obj = empty(obj);

                else

                    obj.types     = obj.types(1,index1);
                    obj.variables = obj.variables(1,index2);
                    obj.dataNames = obj.dataNames(1,index3);
                end

                if size({s.type},2) > 1
                    % Make it possible to for example write
                    % obj(1,2,3).data
                    try
                        [varargout{1:nargout}]  = builtin('subsref', obj, s(2:end));
                    catch 
                        builtin('subsref', obj, s(2:end));
                    end
                else
                    varargout{1} = obj;
                end
            
            elseif ischar(s(1).subs{1}) % variable indexation;  obj = obj('Var1','Var2',...)

                if ~isempty(s(1).subs{1})

                    % Make it possible to for example write
                    % obj('Var1','Var2',...), which is the same
                    % as obj.window({},{'Var1','Var2',...})
                    vars         = s(1).subs;
                    obj          = obj.window({},vars);

                    if size({s.type},2) > 1
                        % Make it possible to for example write
                        % obj('Var1','Var2',...).data
                        try
                            [varargout{1:nargout}]  = builtin('subsref', obj, s(2:end));
                        catch 
                            builtin('subsref', obj, s(2:end));
                        end
                    else
                        varargout{1} = obj;
                    end

                else

                    varargout{1} = obj;

                end

            elseif iscell(s(1).subs{1}) % Short notation for the window method

                switch size(s(1).subs,2)

                    case 1

                        % Make it possible to for example write
                        % obj({'Type1','Type2',...}), which is the 
                        % same as obj.window({'Type1','Type2',...})
                        typesWin = s(1).subs{1};
                        obj      = window(obj,typesWin);

                        if size({s.type},2) > 1
                            % Make it possible to for example write
                            % obj('date').data
                            try
                                [varargout{1:nargout}]  = builtin('subsref', obj, s(2:end));
                            catch 
                                builtin('subsref', obj, s(2:end));
                            end
                        else
                            varargout{1} = obj;
                        end

                    case 2

                        % Make it possible to for example write
                        % obj({'Type1','Type2',...},{'Var1','Var2',...}), 
                        % which is the same as obj.window({'Type1','Type2',...},{'Var1','Var2',...})
                        typesWin = s(1).subs{1};
                        varsWin  = s(1).subs{2};
                        obj      = window(obj,typesWin,varsWin);

                        if size({s.type},2) > 1
                            % Make it possible to for example write
                            % obj.window('startDate','endDate').data
                            try
                                [varargout{1:nargout}]  = builtin('subsref', obj, s(2:end));
                            catch 
                                builtin('subsref', obj, s(2:end));
                            end
                        else
                            varargout{1} = obj;
                        end

                    case 3

                        % Make it possible to for example write
                        % obj({'Type1','Type2',...},{'Var1','Var2',...},pages),
                        % which is the same as
                        % obj.window({'Type1','Type2',...},{'Var1','Var2',...},pages)
                        typesWin = s(1).subs{1};
                        varsWin  = s(1).subs{2};
                        pagesWin = s(1).subs{3};
                        obj      = window(obj,typesWin,varsWin,pagesWin);

                        if size({s.type},2) > 1
                            % Make it possible to for example write
                            % obj.window('startDate','endDate',{'Var1','Var2',...}).data
                            try
                                [varargout{1:nargout}]  = builtin('subsref', obj, s(2:end));
                            catch 
                                builtin('subsref', obj, s(2:end));
                            end
                        else
                            varargout{1} = obj;
                        end

                    otherwise

                        error([mfilename ':: You are using a short notation for the window method, which takes only 3 inputs. '...
                            'Currently given ' int2str(size(s(1).subs,2)) ' inputs.'])
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

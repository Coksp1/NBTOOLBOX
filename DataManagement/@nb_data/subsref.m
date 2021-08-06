function varargout = subsref(obj,s)
% Syntax:
%
% varargout = subsref(obj,s)
%
% Description:
%
% Makes it possible to do subscripted reference of the data of an
% object. See the examples for more
% 
% Using the method window, just using indexing instead
% 
% Input:
% 
% - obj    : An object of class nb_data
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
%     Be aware that that obj(1,:) and obj(1,2:end) will also work
% 
% 
% obj = obj('2')
% 
%     same as
% 
%     obj.window('2','2')
% 
% 
% obj = obj('2','4')
% 
%     same as 
% 
%     obj.window('2','4')
% 
% 
% obj = obj('2','4',{'Var1','Var2',...})
% 
%     same as 
% 
%     obj.window('2','4',{'Var1','Var2',...})
% 
% 
% obj = obj('2','4',{'Var1','Var2',...},1:2)
% 
%     same as 
% 
%     obj.window('2','4',{'Var1','Var2',...},1:2)
% 
% 
% obj = obj('Var1','Var2',...)
% 
%     same as 
% 
%     obj.window('','',{'Var1','Var2',...},1:obj.numberOfDatasets)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen


    switch s(1).type

        case '()'

            if ischar(s(1).subs{1}) % variable indexation;  obj = obj('Var1','Var2',...)
                                    % obs indexation     ;  obj = obj('1','2')

                startsWithANumber = regexp(s(1).subs{1},'^[0-9]','match');

                if isempty(startsWithANumber) && ~isempty(s(1).subs{1})

                    if strcmp(s(1).subs{1},':')
                        s(1).subs{1} = 1:obj.numberOfObservations;
                        varargout    = subsref(obj,s);
                        varargout    = {varargout};
                    else
                    
                        % Make it possible to for example write
                        % obj('Var1','Var2',...), which is the same
                        % as obj.window('','',{'Var1','Var2',...})
                        vars         = s(1).subs;
                        obj          = window(obj,'','',vars);
                        varargout{1} = obj;

                        if size({s.type},2) > 1
                            % Make it possible to for example write
                            % obj('Var1','Var2',...).data
                            try
                                [varargout{1:nargout}]  = builtin('subsref', obj, s(2:end));
                            catch %#ok
                                builtin('subsref', obj, s(2:end));
                            end
                        else
                            varargout{1} = obj;
                        end
                        
                    end

                else

                    switch size(s(1).subs,2)

                        case 1

                            % Make it possible to for example write
                            % obj('obs'), which is the same
                            % as obj.window('obs','obs')
                            obs = s(1).subs{1};
                            obj = window(obj,str2double(obs),str2double(obs));

                            if size({s.type},2) > 1
                                % Make it possible to for example write
                                % obj('date').data
                                try
                                    [varargout{1:nargout}]  = builtin('subsref', obj, s(2:end));
                                catch %#ok
                                    builtin('subsref', obj, s(2:end));
                                end
                            else
                                varargout{1} = obj;
                            end

                        case 2

                            % Make it possible to for example write
                            % obj('startobs','endobs'), which is 
                            % the same as 
                            % obj.window('startobs','endobs')
                            startObsWin = s(1).subs{1};
                            endObsWin   = s(1).subs{2};
                            obj         = window(obj,str2double(startObsWin),str2double(endObsWin));

                            if size({s.type},2) > 1
                                % Make it possible to for example write
                                % obj.window('startDate','endobs').data
                                try
                                    [varargout{1:nargout}]  = builtin('subsref', obj, s(2:end));
                                catch %#ok
                                    builtin('subsref', obj, s(2:end));
                                end
                            else
                                varargout{1} = obj;
                            end

                        case 3

                            % Make it possible to for example write
                            % obj('startobs','endobs',{'Var1','Var2',...}), 
                            % which is the same as 
                            % obj.window('startobs','endobs',{'Var1','Var2',...})
                            startObsWin = s(1).subs{1};
                            endObsWin   = s(1).subs{2};
                            vars        = s(1).subs{3};
                            obj         = window(obj,str2double(startObsWin),str2double(endObsWin),vars);

                            if size({s.type},2) > 1
                                % Make it possible to for example write
                                % obj.window('startobs','endobs',{'Var1','Var2',...}).data
                                try
                                    [varargout{1:nargout}] = builtin('subsref', obj, s(2:end));
                                catch %#ok
                                    builtin('subsref', obj, s(2:end));
                                end
                            else
                                varargout{1} = obj;
                            end

                        case 4

                            % Make it possible to for example write
                            % obj('startobs','endobs',{'Var1','Var2',...},pages), 
                            % which is the same as 
                            % obj.window('startobs','endobs',{'Var1','Var2',...},pages)
                            startObsWin = s(1).subs{1};
                            endObsWin   = s(1).subs{2};
                            vars        = s(1).subs{3};
                            pages       = s(1).subs{4};
                            obj         = window(obj,str2double(startObsWin),str2double(endObsWin),vars,pages);

                            if size({s.type},2) > 1
                                % Make it possible to for example write
                                % obj.window('startobs','endobs',{'Var1','Var2',...},pages).data
                                try
                                    [varargout{1:nargout}] = builtin('subsref', obj, s(2:end));
                                catch %#ok
                                    builtin('subsref', obj, s(2:end));
                                end
                            else
                                varargout{1} = obj;
                            end

                        otherwise

                            error([mfilename ':: You are using a short notation for the window method, which takes only 4 inputs. '...
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
                
                if strcmp(index2,':')
                    index2 = 1:obj.numberOfVariables;
                end
                
                if strcmp(index2,':')
                    index3 = 1:obj.numberOfDatasets;
                end

                obj.data      = obj.data(index1,index2,index3);

                if isempty(obj.data)

                    obj = empty(obj);

                else

                    obj.variables = obj.variables(1,index2);
                    obj.dataNames = obj.dataNames(index3);
                    obj.startObs  = obj.startObs + index1(1) - 1;
                    obj.endObs    = obj.startObs + index1(end) - index1(1);
                end

                if size({s.type},2) > 1
                    % Make it possible to for example write
                    % obj(1,2,1).data
                    try
                        [varargout{1:nargout}] = builtin('subsref', obj, s(2:end));
                    catch %#ok
                        builtin('subsref', obj, s(2:end));
                    end
                else
                    varargout{1} = obj;
                end
                
            elseif islogical(s(1).subs{1})
                error([mfilename ':: Cannot index the first dimension with a logical vector.'])
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

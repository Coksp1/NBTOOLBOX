function varargout = subsref(obj,s)
% Syntax:
%
% varargout = subsref(obj,s)
%
% Description:
%
% Makes it possible to do subscripted reference to an object of class
% nb_symMatrix.
% 
% Input:
% 
% - obj    : An object of class nb_symMatrix.
% 
% - s      : A structure on how to index the object.
% 
% Output:
% 
% - obj    : An object of class nb_symMatrix.
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch s(1).type

        case '()'

            if isnumeric(s(1).subs{1}) || strcmp(s(1).subs{1},':')

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
                    
                catch Err
                    switch Err.identifier
                        case 'MATLAB:badsubscript'
                            % If you write obj() you keep the size of
                            % the object.
                            index1 = 1:size(obj,1);
                            index2 = 1:size(obj,2);
                        otherwise
                            rethrow(Err)
                    end
                end
                if not(isnumeric(index2) || strcmp(index2,':'))
                    error([mfilename ':: Wrong asignment.'])
                end
                obj.symbols = obj.symbols(index1,index2);
                
                if size({s.type},2) > 1
                    try
                        [varargout{1:nargout}]  = builtin('subsref', obj, s(2:end));
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

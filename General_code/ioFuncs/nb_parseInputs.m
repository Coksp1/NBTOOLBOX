function [inputs,message,index] = nb_parseInputs(mfile,default,varargin)
% Syntax:
%
% [inputs,message,index] = nb_parseInputs(varargin)
%
% Description:
%
% Parse inputs.
% 
% Input:
% 
% - mfile    : The name of the function that calls the parser.
%
% - default  : A cell with the following:
%
%               {'inputName1',inputValue1,@isnumeric;...
%                'inputName2',inputValue2,{{@isa,'nb_ts'}},...
%                'inputName2',inputValue2,{@isnumeric,'&&',@isscalar}}
%
%              Can also be a cell array with 4 columns. In the 4th column
%              you can include a function_handle that will be called when
%              the corresponding property is being set. If the element is
%              anything else than a function_handle, it will not be done 
%              anything. The function_handle need to take 2 inputs. The
%              input name and the input value (In that order).
% 
% - varargin : The input name, input value pairs from the user.
%
% Output:
% 
% - inputs   : A struct with the parsed options.
%
% - message  : Error message. If empty, there where no problems
%
% - index    : An index of the inputs that are set by the varargin input.
%              A logical vector with size size(default,1), where the
%              matching element in default is true if set.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Expand varargin if given as struct
    if length(varargin) == 1
        if isstruct(varargin{1})
            varargin = nb_struct2cellarray(varargin{1});
        end
    end
    
    if rem(length(varargin),2) ~= 0
        inputs  = struct();
        message = 'The optional inputs must come in pairs.';
        index   = false(size(default,1),1); 
        return
    end

    message      = '';
    index        = false(size(default,1),1); 
    inputNames   = default(:,1);
    inputValues  = default(:,2);
    inputs       = cell2struct(inputValues,inputNames);
    for ii = 1:2:size(varargin,2)

        argumentName = varargin{ii};
        try
            argumentValue = varargin{ii+1};
            cont          = 1;
        catch  %#ok<CTCH>
            cont = 0;
        end

        if cont

            ind        = strcmpi(argumentName,inputNames);
            index(ind) = true;
            if ~any(ind)
                message = [mfile ':: ''' argumentName ''' is not a valid input.'];
                return
            else
                specs = default{ind,3};
                isOK  = true(ceil(length(specs)/2),1);
                if iscell(specs)
                    
                    tested = specs(1:2:end);
                    for jj = 1:length(tested)
                        [~,messageT] = checkOneInput(inputs,inputNames{ind},tested{jj},argumentName,argumentValue);
                        if ~isempty(messageT)
                            isOK(jj) = false;
                        end
                    end
                    
                    logic = specs(2:2:end);
                    orOp  = find(strcmp('|',logic) | strcmp('||',logic));
                    if isempty(orOp)
                        test = all(isOK);
                    else
                        test = all(isOK(1:orOp(1)));
                        for ll = 1:length(orOp)-1
                            test = test || all(isOK(orOp(ll)+1:orOp(ll+1)));
                        end
                        test = test || all(isOK(orOp(end)+1:end));
                    end
                    
                    if test
                        inputs.(inputNames{ind}) = argumentValue;
                    else
                        func    = getRestrictionAsString(specs);
                        message = ['The input after ''' argumentName  ''' must satisfy the restriction given by; ' func '.'];
                        return
                    end
                    
                else
                    [inputs,message] = checkOneInput(inputs,inputNames{ind},specs,argumentName,argumentValue);
                    if ~isempty(message)
                        message = [mfile ':: ' message]; %#ok<AGROW>
                        return
                    end
                end
                if size(default,2) > 3
                    % In this case the 4th column must contain a function
                    % handle
                    if isa(default{ind,4},'function_handle')
                        try
                            default{ind,4}(inputNames{ind},argumentValue);
                        catch Err
                            message = [mfile ':: The function called when setting the ''' argumentName ''' produced an error: ' Err.message];
                        end
                    end
                end
                
            end

        end

    end
    
end

%==========================================================================
function [inputs,message] = checkOneInput(inputs,inputName,specs,argumentName,argumentValue)

    message = '';
    if isempty(specs)
        return
    end
    
    if isa(specs,'function_handle')
                    
        if specs(argumentValue)
            inputs.(inputName) = argumentValue;
        else
            message = ['The input after ''' argumentName  ''' must satisfy the restriction given by; @' func2str(specs) '.'];
            return
        end

    elseif iscell(specs)

        specsInput = specs(2:end);
        specs      = specs{1};
        if isa(specs,'function_handle')

            try
                test = specs(argumentValue,specsInput{:});
            catch Err
                if strcmpi(Err.identifier,'MATLAB:ISMEMBER:InputClass')
                    message = ['The input after ''' argumentName  ''' must satisfy the restriction given by; @' func2str(specs) '(inputValue,' toString(specsInput) ').'];
                    return
                else
                    error([mfilename ':: The third column of the default option is wrong for the input; ' inputName ' :: ' Err.message])
                end
            end

            if test
                inputs.(inputName) = argumentValue;
            else
                message = ['The input after ''' argumentName  ''' must satisfy the restriction given by; @' func2str(specs) '(inputValue,' toString(specsInput) ').'];
                return
            end

        else
            error([mfilename ':: The third column of the default option is wrong for the input; ' inputName])
        end

    else
        error([mfilename ':: The third column of the default option is wrong for the input; ' inputName])
    end

end

%==========================================================================
function func = getRestrictionAsString(specs)

    func = '';
    for ii = 1:length(specs)
       
        specsTemp = specs{ii};
        if iscell(specsTemp)
            func = [func, ' @', func2str(specsTemp{1}) '(inputValue,' nb_cell2String(specsTemp(2:end)) ')']; %#ok<AGROW>
        elseif any(strcmp(specsTemp,{'|','||','&','&&'}))
            func = [func, ' ' specsTemp]; %#ok<AGROW>
        else
            func = [func, ' @' func2str(specsTemp)]; %#ok<AGROW>
        end
        
    end

end

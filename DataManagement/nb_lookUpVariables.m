function [vars,numberOfLines] = nb_lookUpVariables(variables,lookUpMatrix,language,numerOfLinesOutput)
% Syntax:
%
% [vars,numberOfLines] = nb_lookUpVariables(variables,lookUpMatrix,language,numerOfLinesOutput)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(lookUpMatrix)
        vars          = variables;
        if strcmpi(numerOfLinesOutput,'scalar')
            numberOfLines = 1;
        else
            numberOfLines = ones(size(vars));
        end
        return
    end

    if size(lookUpMatrix,3) && ~iscell(lookUpMatrix)
        error([mfilename ':: The lookUpMatrix input must be a cell. Get help by typing help nb_ts.writeTex.'])
    end

    vars          = cell(size(variables));

    switch numerOfLinesOutput

        case 'scalar'

            numberOfLines = 1;

            for kk = 1:size(variables,2)

                stringInd = find(strcmp(variables{kk},lookUpMatrix(:,1)));

                if ~isempty(stringInd)
                    switch language

                        case {'norsk','norwegian'}
                            vars{kk} = lookUpMatrix{stringInd,3};
                        case {'english','engelsk'}
                            vars{kk} = lookUpMatrix{stringInd,2};
                        otherwise

                            error([mfilename, ':: Language ' language ' is not supported by this function'])
                    end
                else
                    vars{kk} = variables{kk};
                end

                tempSize = size(vars{kk},1);
                if numberOfLines < tempSize
                    numberOfLines = tempSize;
                end

                if tempSize == 0
                    error([mfilename ':: The description provided by the lookUpMatrix input cannot be empty! Which is the case for ' variables{kk}])
                end

            end

        case 'vector'

            numberOfLines = nan(size(variables));

            for kk = 1:size(variables,2)

                stringInd = find(strcmp(variables{kk},lookUpMatrix(:,1)));

                if ~isempty(stringInd)
                    switch language

                        case {'norsk','norwegian'}
                            vars{kk} = lookUpMatrix{stringInd,3};
                        case {'english','engelsk'}
                            vars{kk} = lookUpMatrix{stringInd,2};
                        otherwise

                            error([mfilename, ':: Language ' language ' is not supported by this function'])
                    end
                else
                    vars{kk} = variables{kk};
                end

                numLine           = size(vars{kk},1);
                numberOfLines(kk) = numLine;

                if numLine == 0
                    error([mfilename ':: The description provided by the lookUpMatrix input cannot be empty! Which is the case for ' variables{kk}])
                end

            end

    end

end

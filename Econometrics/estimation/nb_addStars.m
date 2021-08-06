function tests = nb_addStars(tests,indNT,indW,indARCH,indAT)
% Syntax:
%
% tests = nb_addStars(results,tests,indNT,indW,indARCH,indAT)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Indicate if significant
    if ~isempty(indNT)
        
        for jj = 1:size(tests,2)
            pvalNT  = 1 - chi2cdf(str2double(tests{indNT,jj}),2);
            if pvalNT < 0.1
                if pvalNT < 0.05
                    tests{indNT,jj} = ['**' tests{indNT,jj}];
                else
                    tests{indNT,jj} = ['*' tests{indNT,jj}];
                end
            end

        end
    end

    if ~isempty(indW)
        
        for jj = 1:size(tests,2)
            pvalW  = 1 - chi2cdf(str2double(tests{indW,jj}),2);
            if pvalW < 0.1
                if pvalW < 0.05
                    tests{indW,jj} = ['**' tests{indW,jj}];
                else
                    tests{indW,jj} = ['*' tests{indW,jj}];
                end
            end

        end
    end

    if ~isempty(indARCH)

        for jj = 1:size(tests,2)
            pvalARCHT  = 1 - chi2cdf(str2double(tests{indARCH,jj}),2);
            if pvalARCHT < 0.1
                if pvalARCHT < 0.05
                    tests{indARCH,jj} = ['**' tests{indARCH,jj}];
                else
                    tests{indARCH,jj} = ['*' tests{indARCH,jj}];
                end
            end

        end
    end

    if ~isempty(indAT)

        for jj = 1:size(tests,2)
            pvalAT  = 1 - chi2cdf(str2double(tests{indAT,jj}),2);
            if pvalAT < 0.1
                if pvalAT < 0.05
                    tests{indAT,jj} = ['**' tests{indAT,jj}];
                else
                    tests{indAT,jj} = ['*' tests{indAT,jj}];
                end
            end

        end
    end

end

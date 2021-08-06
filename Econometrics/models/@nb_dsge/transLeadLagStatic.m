function eqs = transLeadLagStatic(eqs)
% Syntax:
%
% eqs = nb_dsge.transLeadLagStatic(eqs)
%
% Description:
%
% Rename Var(+1) and Var(-1) to Var and Var, i.e. it can be used to get the
% static representation of the model.
%
% The part (?<=[^+-\*\^]) is to prevent matches with ^(-1) and so forth.
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    eqs = regexprep(eqs,'(?<=[^+-\*\^])\({1}[+]{1}\d{1,2}\){1}','');
    eqs = regexprep(eqs,'(?<=[^+-\*\^])\({1}[-]{1}\d{1,2}\){1}','');
    
    % Remove calls to the steady_state function
    for ii = 1:size(eqs,1)
        
        % Subst steady_state(X) with X
        m = regexp(eqs{ii},'steady_state\([^\)]+\)','match');
        if ~isempty(m)
            s = cellfun(@(x)x(14:end-1),m,'UniformOutput',false);
            for jj = 1:length(m)
                eqs{ii} = strrep(eqs{ii},m{jj},s{jj});
            end
        end
        
        % Subst steady_state_init(X) with X_SS_INIT
        m = regexp(eqs{ii},'steady_state_init\([^\)]+\)','match');
        if ~isempty(m)
            s = cellfun(@(x)x(19:end-1),m,'UniformOutput',false);
            s = strcat(s,'_SS_INIT');
            for jj = 1:length(m)
                eqs{ii} = strrep(eqs{ii},m{jj},s{jj});
            end
        end
        
    end

end

% This functionality is still being developed and the interface is subject
% to change. Please be aware that backward compatibility for this function 
% is not ensured at this time.

function arAddConditionConstraint( m, c1, c2, t, sd, states )

    global ar;
    
    strct.m         = m;
    strct.c1        = c1;
    strct.c2        = c2;
    strct.t         = t;
    strct.sd        = sd;
    if ( ~exist( 'states', 'var' ) )
        strct.states = 1:length(ar.model(m).x);
    else
        strct.states = states;
    end

    if ~isfield( ar, 'conditionconstraints' )
        ar.conditionconstraints = strct;
    else
        ar.conditionconstraints(end+1) = strct;
    end

    % Add necessary time points to the conditions
    arAddEvent(m, c1, t );
    arAddEvent(m, c2, t );
    arLink;
    
end
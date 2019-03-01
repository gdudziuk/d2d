% arWriteClusterMoab(conf)
% 
% arWriteClusterMoab writes the *.moab file required on the bwGrid cluster.
% 
%   conf  configuration struct generated by arClusterConfig
% 
% Example:
% conf = arClusterConfig
% arWriteClusterMoab(conf)
% 
% See also arClusterConfig, arFitLhsBwCluster

function arWriteClusterMoab(conf)
if isnumeric(conf.arg1)
    conf.arg1 = num2str(conf.arg1);
elseif ~ischar(conf.arg1)
    error('~ischar(conf.arg1)');
end
    
fid = fopen(conf.file_moab,'w');

fprintf(fid,'%s\n','#!/bin/sh');
fprintf(fid,'%s\n','########## Begin MOAB/Slurm header ##########');
fprintf(fid,'%s\n',['#MOAB -N ',conf.name]);
fprintf(fid,'%s\n',['#MOAB -l nodes=1:ppn=16:' conf.qu]);
fprintf(fid,'%s\n',['#MOAB -l walltime=' conf.walltime']);
fprintf(fid,'%s\n','#MOAB -j oe');
fprintf(fid,'%s\n','#MOAB -m a');
fprintf(fid,'%s\n','########### End MOAB header ##########');
fprintf(fid,'%s\n','echo "Submit Directory: $MOAB_SUBMITDIR"');
fprintf(fid,'%s\n','echo "Working Directory: $PWD"');
fprintf(fid,'%s\n','echo "Running on host $HOSTNAME"');
fprintf(fid,'%s\n','echo "Job id: $MOAB_JOBID"');
fprintf(fid,'%s\n','echo "Job name: $MOAB_JOBNAME"'); 
fprintf(fid,'%s\n','echo "Number of nodes allocated to job: $MOAB_NODECOUNT"');
fprintf(fid,'%s\n','echo "Number of cores allocated to job: $MOAB_PROCCOUNT"');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','# Go to submit directory');
fprintf(fid,'%s\n','cd $MOAB_SUBMITDIR');
fprintf(fid,'%s\n','echo Directory is `pwd`');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n',['module load math/matlab/',conf.matlab_release]);
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','##### for-loop for parallization within a node #######');
fprintf(fid,'%s\n',['for iInNode in {1..',num2str(conf.n_inNode),'}    ']);
fprintf(fid,'%s\n','do');
% conf.arg1 is a placeholder/template for further arguments passed to
% matlab:
fprintf(fid,'%s\n',['( matlab -nodisplay -r "icall=$1; iInNode=$iInNode; arg1=',conf.arg1,'; ',strrep(conf.file_matlab,'.m',''),'" &> ${1}_${iInNode}.log ) &']);
fprintf(fid,'%s\n','    sleep 2');
fprintf(fid,'%s\n','done');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','# Wait for all background processes to finish');
fprintf(fid,'%s\n','wait');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','exit');

fclose(fid);

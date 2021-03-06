% arEvalToAllExamples(fun, [result_suffix], [workspace_pattern], [depth], [varargin])
% 
% Loads recursively the latest result workspaces and applies function fun. 
% 
%   fun             a D2D or user-defined function 
%   result_suffix   ['arEvalToAllExamples']
%                   used as argument for arSave after fun is finished
%                   If result_suffix = 'current' then the loaded workspace used
%                   'none' keyword indicating NO SAVING at all.
% 
%   workspace_pattern   used as argument for arLoadLatest to load a
%                       workspace
% 
%   depth       [Inf]
%               folder depth for which the fucntion should work.
%               The argument depth is given to list_files_recursive(depth).
%               Inf: means working recursively through all folders
%               0: applies fun to models in the current folder (but
%               not in subfolder), e.g. to workspaces in ModelAuthorYear/Results/*
%               1: applies fun in the current folder and in all
%               existing subfolders (but not in subsubfolder)
% 
%   vargin      additional arguments passed to fun
% 
% 
% The function checks whether a folder is a D2D working folder by
% checking existance of the folders 'Results' and 'Models'.
% 
% Examples:
% arEvalToAllExamples('arFitLHS','LHS100',[],1,100);
% arEvalToAllExamples('arUpdateResultWorkspaces','none',[],2);
% 
% addpath(pwd); % add path to the working dir to find the user-function
% arEvalToAllExamples(@userfun,'none',[],2);
% 
% See also arEvaluate, arEvalWithOldRevision

function varargout = arEvalToAllExamples(fun, result_suffix, workspace_pattern, depth, varargin)
if ~exist('depth','var') || isempty(depth)
    depth = Inf;
end
if ~exist('result_suffix','var') || isempty(result_suffix)
    result_suffix = 'arEvalToAllExamples';
end
if ~exist('workspace_pattern','var') || isempty(workspace_pattern)
    workspace_pattern = '';
end

[~,folders]=list_files_recursive(depth);

pw = pwd;
out = cell(1,length(nargout));
useDir = 0;
for i=1:length(folders)
    try
        cd(folders{i});
        fprintf('Folder %s ... \n',folders{i});
        
        if isdir('Results') && isdir('Models') % if this seems to be a D2D modelling folder;
            switch nargout
                case 1
                    tmp = applyCore(fun,result_suffix,workspace_pattern,varargin{:});
                    if ~isempty(tmp)
                        useDir = useDir+1;
                        out{1}{useDir}.folder = folders{i};
                        out{1}{useDir}.result = tmp;
                    end
                case 2
                    [tmp1,tmp2] = applyCore(fun,result_suffix,workspace_pattern,varargin{:});
                    if ~isempty(tmp1)
                        useDir = useDir+1;
                        out{1}{useDir}.folder = folders{i};
                        out{1}{useDir}.result = tmp1;
                        out{2}{useDir}.folder = folders{i};
                        out{2}{useDir}.result = tmp2;
                    end
                otherwise
                    applyCore(fun,result_suffix,workspace_pattern,varargin{:});
            end
        end
        
    catch ERR
        cd(pw)
        rethrow(ERR)
    end
end
if nargout>0
    varargout = out;
end
cd(pw)


function varargout = applyCore(fun,result_suffix,workspace_pattern,varargin)
global ar
status = arLoadLatest(workspace_pattern);
out = cell(1,nargout);
if status
    fprintf('Evaluating %s for workspace %s ... \n',char(fun),ar.config.savepath);
    switch nargout
        case 1
            tmp = feval(fun,varargin{:});
            out = {tmp};
        case 2
            [tmp1,tmp2] = feval(fun,varargin{:});
            out = {tmp1,tmp2};
        otherwise 
            feval(fun,varargin{:});
    end
    if strcmpi(result_suffix,'none')~=1
        arSave(result_suffix)
    else
        disp('Saving of workspace is switched off.');
    end
end
if nargout>0
    varargout = out;
end
function roast(subj,recipe,varargin)
% roast(subj,recipe,varargin)
%
% Main function of ROAST.
% 
% subj: file name (can be either relative or absolute path) of the MRI of
% the subject that you want to run simulation on. The MRI can be either T1
% or T2. If you have both T1 and T2, then put T2 file in the option "T2"
% (see below options for details). If you do not have any MRI but just want
% to run ROAST for a general result, you can use the default subject the
% MNI152 averaged head (see Example 1) or the New York head (see Example 2).
% 
% recipe: how you want to ROAST the subject you specified above. Default
% recipe is anode on Fp1 (1 mA) and cathode on P4 (-1 mA). You can specify
% any recipe you want in the format of electrodeName-injectedCurrent pair
% (see Example 3). You can pick any electrode from the 10/20, 10/10, 10/05 or BioSemi-256
% EEG system (see the Microsoft Excel file capInfo.xls under the root directory
% of ROAST). The unit of the injected current is in milliampere (mA). Make sure
% they sum up to 0. You can also place electrodes at customized locations
% on the scalp. See Example 5 for details.
%
% Example 1: roast
%
% Default call of ROAST, will demo a modeling process on the MNI152 head.
% Specifically, this will use the MRI of the MNI152 head to build a model
% of transcranial electric stimulation (TES) with anode on Fp1 (1 mA) and cathode
% on P4 (-1 mA). Electrodes are modeled by default as small disc electrodes.
% See options below for details.
% 
% Example 2: roast('nyhead')
% 
% ROAST New York head. Again this will run a simulation with anode on Fp1 (1 mA)
% and cathode on P4 (-1 mA), but on the 0.5-mm resolution New York head. A decent
% machine of 16GB memory and above is recommended for running New York
% head. Again electrodes are modeled by default as small disc electrodes.
% See options below for details.
%
% Example 3: roast('example/subject1.nii',{'F1',0.3,'P2',0.7,'C5',-0.6,'O2',-0.4})
%
% Build the TES model on any subject with your own "recipe". Here we inject
% 0.3 mA at electrode F1, 0.7 mA at P2, and we ask 0.6 mA coming out of C5,
% and 0.4 mA flowing out of O2. You can define any stimulation montage you want
% in the 2nd argument, with electrodeName-injectedCurrent pair. Electrodes are
% modeled by default as small disc electrodes. You can pick any electrode
% from the 10/20, 10/10, 10/05 or BioSemi-256 EEG system. You can find all
% the info on electrodes (names, locations, coordinates) in the Microsoft
% Excel file capInfo.xls under the root directory of ROAST. Note the unit of
% the injected current is milliampere (mA). Make sure they sum up to 0.
% 
%
% Options for ROAST can be entered as Name-Value Pairs in the 3rd argument 
% (available from ROAST v2.0). The syntax follows the Matlab convention (see plot() for example).
% 
% 'capType': the EEG system that you want to pick any electrode from.
% '1020' | '1010' (default) | '1005' | 'BioSemi'
% You can also use customized electrode locations you defined. Just provide
% the text file that contains the electrode coordinates. See below Example 5 for details.
% 
% 'elecType': the shape of electrode.
% 'disc' (default) | 'pad' | 'ring'
% Note you can specify different shapes to different electrodes, i.e., you
% can place different types of electrodes at the same time. See below
% Example 6 for details.
% 
% 'elecSize': the size of electrode.
% For disc electrodes, sizes follow the format of [radius height], and
% default size is [6mm 2mm]; for pad electrodes, sizes follow the format of
% [length width height], and default size is [50mm 30mm 3mm]; for ring
% electrodes, sizes follow the format of [innerRadius outterRadius height],
% and default size is [4mm 6mm 2mm].
% 
% If you're placing only one type of electrode (e.g., either disc, or pad,
% or ring), you can use a one-row vector to customize the size, see Example
% 7; if you want to control the size for each electrode separately
% (provided you're placing only one type of electrode), you need to specify
% the size for each electrode correspondingly in a N-row matrix, where N is
% the number of electrodes to be placed, see Example 8; if you're placing
% more than one type of electrodes and also want to customize the sizes,
% you need to put the size of each electrode in a 1-by-N cell (put [] for
% any electrode that you want to use the default size), where N is the number
% of electrodes to be placed, see Example 9.
% 
% 'elecOri': the orientation of pad electrode (ONLY applies to pad electrodes).
% 'lr' (default) | 'ap' | 'si' | direction vector of the long axis
% For pad electrodes, you can define their orientation by giving the
% direction of the long axis. You can simply use the three pre-defined keywords:
% lr--long axis going left (l) and right (r); ap--long axis pointing front (anterior) and back (posterior);
% si--long axis going up (superior) and down (inferior). For other orientations you can also specify
% the direction precisely by giving the direction vector of the long axis.
% 
% If you're placing pad electrodes only, use the pre-defined keywords
% (Example 10) or the direction vector of the long axis (Example 11) to
% customize the orientations; if you want to control the
% orientation for each pad electrode separately, you need to specify
% the orientation for each pad correspondingly using the pre-defined
% keywords in a 1-by-N cell (Example 12) or the direction vectors of the
% long axis in a N-by-3 matrix (Example 13), where N is the number of pad 
% electrodes to be placed; if you're placing more than one type of electrodes
% and also want to customize the pad orientations, you need to put the
% orientations into a N-by-3 matrix (Example 14; or just a 1-by-3 vector or a
% single pre-defined keyword if same orientation for all the pads) where N
% is the number of pad electrodes, or into a 1-by-N cell (Example 15), where N
% is the number of all electrodes to be placed (put [] for non-pad electrodes).
%
% 'T2': use a T2-weighted MRI to help segmentation.
% [] (default) | file path to the T2 MRI
% If you have a T2 MRI aside of T1, you can put the T2 file in this option,
% see Example 16, note you should put the T1 and T2 files in the same
% directory.
% If you ONLY have a T2 MRI, put the T2 file in the first argument 'subj'
% when you call roast, just like what you would do when you only have a T1.
% 
% 'meshOptions': advanced options of ROAST, for controlling mesh parameters
% (see Example 17).
% 5 sub-options are available:
% meshOpt.radbound: maximal surface element size, default 5;
% meshOpt.angbound: mimimal angle of a surface triangle, default 30;
% meshOpt.distbound: maximal distance between the center of the surface bounding circle
% and center of the element bounding sphere, default 0.4;
% meshOpt.reratio: maximal radius-edge ratio, default 3;
% meshOpt.maxvol: target maximal tetrahedral element volume, default 10.
% See iso2mesh documentation for more details on these options.
%
% 'simulationTag': a unique tag that identifies each simulation.
% dateTime string (default) | user-provided string
% This tag is used by ROAST for managing simulation data. ROAST can
% identify if a certain simulation has been already run. If yes, it will
% just load the results to save time. You can leave this option empty so 
% that ROAST will just use the date and time as the unique tag for the
% simulation. Or you can provide your preferred tag for a specific
% simulation (Example 18), then you can find it more easily later. Also all the
% simulation history with options info for each simulation are saved in the
% log file (named as "subjName_log"), parsed by the simulation tags.
%
% More advanced examples with these options:
% 
% Example 4: roast('example/subject1.nii',{'G12',1,'J7',-1},'captype','biosemi')
% 
% Run simulation on subject1 with anode on G12 (1 mA) and cathode on J7 (-1
% mA) from the extended BioSemi-256 system (see capInfo.xls under the root
% directory of ROAST).
%  
% Example 5: roast('example/subject1.nii',{'G12',0.25,'J7',-0.25,'Nk1',0.5,'Nk3',-0.5,'custom1',0.25,'custom3',-0.25},'captype','biosemi')
% 
% Run simulation on subject1 with recipe that includes: BioSemi electrodes
% G12 and J7; neck electrodes Nk1 and Nk3 (see capInfo.xls); and
% user-provided electrodes custom1 and custom3. You can use a free program
% called MRIcro (http://www.mccauslandcenter.sc.edu/crnl/mricro) to load
% the MRI first and click the locations on the scalp surface where you want
% to place the electrodes, record the voxel coordinates returned by MRIcro
% into a text file, and save the text file to the MRI data directory with name
% "subjName_customLocations" (e.g., here for subject1 it's saved as
% "subject1_customLocations"). ROAST will load the text file and place the
% electrodes you specified. You need to name each customized electrode in
% the text file starting with "custom" (e.g., for this example they're
% named as custom1, custom2, etc. You can of course do
% "custom_MyPreferredElectrodeName").
% 
% Example 6: roast([],{'Fp1',1,'FC4',1,'POz',-2},'electype',{'disc','pad','ring'})
% 
% Run simulation on the MNI152 averaged head with the specified recipe. A disc
% electrode will be placed at location Fp1, a pad electrode will be placed at FC4,
% and a ring electrode will be placed at POz. The sizes and orientations will be set
% as default.
% 
% Example 7: roast('nyhead',[],'electype','ring','elecsize',[7 10 3])
% 
% Run simulation on the New York head with default recipe. Ring electrodes
% will be placed at Fp1 and P4. The size of each ring is 7mm inner radius,
% 10mm outter radius and 3mm height.
% 
% Example 8: roast('nyhead',{'Fp1',1,'FC4',1,'POz',-2},'electype','ring','elecsize',[7 10 3;6 8 3;4 6 2])
% 
% Run simulation on the New York head with the specified recipe. Ring electrode
% placed at Fp1 will have size [7mm 10mm 3mm]; ring at FC4 will have size
% [6mm 8mm 3mm]; and ring at POz will have size [4mm 6mm 2mm].
% 
% Example 9: roast([],{'Fp1',1,'FC4',1,'POz',-2},'electype',{'disc','pad','ring'},'elecsize',{[8 2],[45 25 4],[5 8 2]})
% 
% Run simulation on the MNI152 averaged head with the specified recipe. A disc
% electrode will be placed at location Fp1 with size [8mm 2mm], a pad electrode
% will be placed at FC4 with size [45mm 25mm 4mm], and a ring electrode will be
% placed at POz with size [5mm 8mm 2mm].
% 
% Example 10: roast([],[],'electype','pad','elecori','ap')
% 
% Run simulation on the MNI152 averaged head with default recipe. Pad
% electrodes will be placed at Fp1 and P4, with default size of [50mm 30mm
% 3mm] and the long axis will be oriented in the direction of front to back.
% 
% Example 11: roast([],[],'electype','pad','elecori',[0.71 0.71 0])
% 
% Run simulation on the MNI152 averaged head with default recipe. Pad
% electrodes will be placed at Fp1 and P4, with default size of [50mm 30mm
% 3mm] and the long axis will be oriented in the direction specified by the
% vector [0.71 0.71 0].
% 
% Example 12: roast('example/subject1.nii',{'Fp1',1,'FC4',1,'POz',-2},'electype','pad','elecori',{'ap','lr','si'})
% 
% Run simulation on subject1 with specified recipe. Pad electrodes will be 
% placed at Fp1, FC4 and POz, with default size of [50mm 30mm 3mm]. The long
% axis will be oriented in the direction of front to back for the 1st pad,
% left to right for the 2nd pad, and up to down for the 3rd pad.
% 
% Example 13: roast('example/subject1.nii',{'Fp1',1,'FC4',1,'POz',-2},'electype','pad','elecori',[0.71 0.71 0;-0.71 0.71 0;0 0.71 0.71])
% 
% Run simulation on subject1 with specified recipe. Pad electrodes will be 
% placed at Fp1, FC4 and POz, with default size of [50mm 30mm 3mm]. The long
% axis will be oriented in the direction of [0.71 0.71 0] for the 1st pad,
% [-0.71 0.71 0] for the 2nd pad, and [0 0.71 0.71] for the 3rd pad.
% 
% Example 14: roast([],{'Fp1',1,'FC4',1,'POz',-2},'electype',{'pad','disc','pad'},'elecori',[0.71 0.71 0;0 0.71 0.71])
% 
% Run simulation on the MNI152 averaged head with specified recipe. A disc
% electrode will be placed at FC4. Two pad electrodes will be placed at Fp1
% and POz, with long axis oriented in the direction of [0.71 0.71 0] and 
% [0 0.71 0.71], respectively.
% 
% Example 15: roast([],{'Fp1',1,'FC4',1,'POz',-2},'electype',{'pad','disc','pad'},'elecori',{'ap',[],[0 0.71 0.71]})
% 
% Run simulation on the MNI152 averaged head with specified recipe. A disc
% electrode will be placed at FC4. Two pad electrodes will be placed at Fp1
% and POz, with long axis oriented in the direction of front-back and [0 0.71 0.71], respectively.
% 
% Example 16: roast('example/subject1.nii',[],'T2','example/subject1_T2.nii')
% 
% Run simulation on subject1 with default recipe. The T2 image will be used
% for segmentation as well.
%
% Example 17: roast([],[],'meshoptions',struct('radbound',4,'maxvol',8))
% 
% Run simulation on the MNI152 averaged head with default recipe. Two of
% the mesh options are customized.
% 
% Example 18: roast([],[],'simulationTag','roastDemo')
% 
% Give the default run of ROAST a tag as 'roastDemo'.
% 
% All the options above can be combined to meet your specific simulation
% needs. For example:
% roast('path/to/your/subject.nii',{'Fp1',0.3,'F8',0.2,'POz',-0.4,'Nk1',0.5,'custom1',-0.6},...
%         'electype',{'disc','ring','pad','ring','pad'},...
%         'elecsize',{[],[7 9 3],[40 20 4],[],[]},...
%         'elecori','ap','T2','path/to/your/t2.nii',...
%         'meshoptions',struct('radbound',4,'maxvol',8),...
%         'simulationTag','awesomeSimulation')
% Now you should know what this will do.
%
% ROAST outputs 6 figures for quick visualization of the simulation
% results. It also save the results as "subjName_simulationTag_result.mat".
% 
% For a formal description of ROAST, one is referred to (please use this as reference):
% https://www.biorxiv.org/content/early/2017/11/10/217331
%
% For a published version of the manuscript above, use this as reference:
% Huang, Y., Datta, A., Bikson, M., Parra, L.C., ROAST: an open-source,
% fully-automated, Realistic vOlumetric-Approach-based Simulator for TES.
% Proceedings of the 40th Annual International Conference of the IEEE 
% Engineering in Medicine and Biology Society, Honolulu, HI, July 2018
% 
% If you use New York head to run simulation, please also cite the
% following:
% Huang, Y., Parra, L.C., Haufe, S.,2016. The New York Head - A precise
% standardized volume conductor model for EEG source localization and tES
% targeting. NeuroImage,140, 150-162
% 
% (c) Yu (Andy) Huang, Parra Lab at CCNY
% yhuang16@citymail.cuny.edu
% April 2018

fprintf('\n\n');
disp('======================================================')
disp('CHECKING INPUTS...')
disp('======================================================')
fprintf('\n');

% warning('on');

% check subject name
if nargin<1 || isempty(subj)
    subj = 'example/MNI152_T1_1mm.nii';
end

if strcmpi(subj,'nyhead')
    subj = 'example/nyhead.nii';
end

if isempty(strfind(subj,'nyhead')) && ~exist(subj,'file')
    error(['The subject MRI you provided ' subj ' does not exist.']);
end

% check recipe syntax
if nargin<2 || isempty(recipe)
    recipe = {'Fp1',1,'P4',-1};
end

if mod(length(recipe),2)~=0
    error('Unrecognized format of your recipe. Please enter as electrodeName-injectedCurrent pair.');
end

elecName = (recipe(1:2:end-1))';

% take in user-specified options
if mod(length(varargin),2)~=0
    error('Unrecognized format of options. Please enter as property-value pair.');
end
    
indArg = 1;
while indArg <= length(varargin)
    switch lower(varargin{indArg})
        case 'captype'
            capType = varargin{indArg+1};
            indArg = indArg+2;
        case 'electype'
            elecType = varargin{indArg+1};
            indArg = indArg+2;
        case 'elecsize'
            elecSize = varargin{indArg+1};
            indArg = indArg+2;
        case 'elecori'
            elecOri = varargin{indArg+1};
            indArg = indArg+2;
        case 't2'
            T2 = varargin{indArg+1};
            indArg = indArg+2;
        case 'meshoptions'
            meshOpt = varargin{indArg+1};
            indArg = indArg+2;
        case 'simulationtag'
            simTag = varargin{indArg+1};
            indArg = indArg+2;
        otherwise
            error('Supported options are: ''capType'', ''elecType'', ''elecSize'', ''elecOri'', ''T2'', ''meshOptions'' and ''simulationTag''.');
    end
end

% set up defaults and check on option conflicts
if ~exist('capType','var')
    capType = '1010';
else
    if ~any(strcmpi(capType,{'1020','1010','1005','biosemi'}))
        error('Supported cap types are: ''1020'', ''1010'', ''1005'' and ''BioSemi''.');
    end
end

if ~exist('elecType','var')
    elecType = 'disc';
else
    if ~iscellstr(elecType)
        if ~any(strcmpi(elecType,{'disc','pad','ring'}))
            error('Supported electrodes are: ''disc'', ''pad'' and ''ring''.');
        end
    else
        if length(elecType)~=length(elecName)
            error('You want to place more than 1 type of electrodes, but did not tell ROAST which type for each electrode. Please provide the type for each electrode respectively, as the value for option ''elecType'', in a cell array of length equals to the number of electrodes to be placed.');
        end
        for i=1:length(elecType)
           if ~any(strcmpi(elecType{i},{'disc','pad','ring'}))
               error('Supported electrodes are: ''disc'', ''pad'' and ''ring''.');
           end
        end
    end
end

if ~exist('elecSize','var')
    if ~iscellstr(elecType)
        switch lower(elecType)
            case {'disc'}
                elecSize = [6 2];
            case {'pad'}
                elecSize = [50 30 3];
            case {'ring'}
                elecSize = [4 6 2];
        end
    else
        elecSize = cell(1,length(elecType));
        for i=1:length(elecSize)
            switch lower(elecType{i})
                case {'disc'}
                    elecSize{i} = [6 2];
                case {'pad'}
                    elecSize{i} = [50 30 3];
                case {'ring'}
                    elecSize{i} = [4 6 2];
            end
        end
    end
else
    if ~iscellstr(elecType)
        if iscell(elecSize)
            warning('Looks like you''re placing only 1 type of electrodes. ROAST will only use the 1st entry of the cell array of ''elecSize''. If this is not what you want and you meant differect sizes for different electrodes of the same type, just enter ''elecSize'' option as an N-by-2 or N-by-3 matrix, where N is number of electrodes to be placed.');
            elecSize = elecSize{1};
        end
        if any(elecSize(:)<=0)
            error('Please enter non-negative values for electrode size.');
        end
        if size(elecSize,2)~=2 && size(elecSize,2)~=3
            error('Unrecognized electrode sizes. Please specify as [radius height] for disc, [length width height] for pad, and [innerRadius outterRadius height] for ring electrode.');
        end
        if size(elecSize,1)>1 && size(elecSize,1)~=length(elecName)
            error('You want different sizes for each electrode. Please tell ROAST the size for each electrode respectively, in a N-row matrix, where N is the number of electrodes to be placed.');
        end
        if strcmpi(elecType,'disc') && size(elecSize,2)==3
            warning('Redundant size info for Disc electrodes; the 3rd dimension will be ignored.');
            elecSize = elecSize(:,1:2);
        end
        if any(strcmpi(elecType,{'pad','ring'})) && size(elecSize,2)==2
            error('Insufficient size info for Pad or Ring electrodes. Please specify as [length width height] for pad, and [innerRadius outterRadius height] for ring electrode.');
        end
        if strcmpi(elecType,'pad') && any(elecSize(:,1) < elecSize(:,2))
            error('For Pad electrodes, the width of the pad should not be bigger than its length. Please enter as [length width height]');
        end
        if strcmpi(elecType,'pad') && any(elecSize(:,3) < 3)
            error('For Pad electrodes, the thickness should at least be 3 mm.');
        end
        if strcmpi(elecType,'ring') && any(elecSize(:,1) >= elecSize(:,2))
            error('For Ring electrodes, the inner radius should be smaller than outter radius.');
        end
    else
        if ~iscell(elecSize)
            error('You want to place at least 2 types of electrodes, but only provided size info for 1 type. Please provide complete size info for all types of electrodes in a cell array as the value for option ''elecSize'', or just use defaults by not specifying ''elecSize'' option.');
        end
        if length(elecSize)~=length(elecType)
            error('You want to place more than 1 type of electrodes. Please tell ROAST the size for each electrode respectively, as the value for option ''elecSize'', in a cell array of length equals to the number of electrodes to be placed.');
        end
        for i=1:length(elecSize)
            if isempty(elecSize{i})
                switch lower(elecType{i})
                    case {'disc'}
                        elecSize{i} = [6 2];
                    case {'pad'}
                        elecSize{i} = [50 30 3];
                    case {'ring'}
                        elecSize{i} = [4 6 2];
                end
            else
                if any(elecSize{i}(:)<=0)
                    error('Please enter non-negative values for electrode size.');
                end
                if size(elecSize{i},2)~=2 && size(elecSize{i},2)~=3
                    error('Unrecognized electrode sizes. Please specify as [radius height] for disc, [length width height] for pad, and [innerRadius outterRadius height] for ring electrode.');
                end
                if size(elecSize{i},1)>1
                    error('You''re placing more than 1 type of electrodes. Please put size info for each electrode as a 1-row vector in a cell array for option ''elecSize''.');
                end
                if strcmpi(elecType{i},'disc') && size(elecSize{i},2)==3
                    warning('Redundant size info for Disc electrodes; the 3rd dimension will be ignored.');
                    elecSize{i} = elecSize{i}(:,1:2);
                end
                if any(strcmpi(elecType{i},{'pad','ring'})) && size(elecSize{i},2)==2
                    error('Insufficient size info for Pad or Ring electrodes. Please specify as [length width height] for pad, and [innerRadius outterRadius height] for ring electrode.');
                end
                if strcmpi(elecType{i},'pad') && any(elecSize{i}(:,1) < elecSize{i}(:,2))
                    error('For Pad electrodes, the width of the pad should not be bigger than its length. Please enter as [length width height]');
                end
                if strcmpi(elecType{i},'pad') && any(elecSize{i}(:,3) < 3)
                    error('For Pad electrodes, the thickness should at least be 3 mm.');
                end
                if strcmpi(elecType{i},'ring') && any(elecSize{i}(:,1) >= elecSize{i}(:,2))
                    error('For Ring electrodes, the inner radius should be smaller than outter radius.');
                end
            end
        end
    end
end

if ~exist('elecOri','var')
    if ~iscellstr(elecType)
        if strcmpi(elecType,'pad')
            elecOri = 'lr';
        else
            elecOri = [];
        end
    else
        elecOri = cell(1,length(elecType));
        for i=1:length(elecOri)
            if strcmpi(elecType{i},'pad')
                elecOri{i} = 'lr';
            else
                elecOri{i} = [];
            end
        end
    end
else
    if ~iscellstr(elecType)
        if ~strcmpi(elecType,'pad')
            warning('You''re not placing pad electrodes; customized orientation options will be ignored.');
            elecOri = [];
        else
            if iscell(elecOri)
                allChar = 1;
                for i=1:length(elecOri)
                    if ~ischar(elecOri{i})
                        warning('Looks like you''re only placing pad electrodes. ROAST will only use the 1st entry of the cell array of ''elecOri''. If this is not what you want and you meant differect orientations for different pad electrodes, just enter ''elecOri'' option as an N-by-3 matrix, or as a cell array of length N (put ''lr'', ''ap'', or ''si'' into the cell element), where N is number of pad electrodes to be placed.');
                        elecOri = elecOri{1};
                        allChar = 0;
                        break;
                    end
                end
                if allChar && length(elecOri)~=length(elecName)
                    error('You want different orientations for each pad electrode by using pre-defined keywords in a cell array. Please make sure the cell array has a length equal to the number of pad electrodes.');
                end
            end
            if ~iscell(elecOri)
                if ischar(elecOri)
                    if ~any(strcmpi(elecOri,{'lr','ap','si'}))
                        error('Unrecognized pad orientation. Please enter ''lr'', ''ap'', or ''si'' for pad orientation; or just enter the direction vector of the long axis of the pad');
                    end
                else
                    if size(elecOri,2)~=3
                        error('Unrecognized pad orientation. Please enter ''lr'', ''ap'', or ''si'' for pad orientation; or just enter the direction vector of the long axis of the pad');
                    end
                    if size(elecOri,1)>1 && size(elecOri,1)~=length(elecName)
                        error('You want different orientations for each pad electrode. Please tell ROAST the orientation for each pad respectively, in a N-by-3 matrix, where N is the number of pads to be placed.');
                    end
                end
            end            
        end
    else
        if ~iscell(elecOri)
            elecOri0 = elecOri;
            elecOri = cell(1,length(elecType));
            if ischar(elecOri0)
                if ~any(strcmpi(elecOri0,{'lr','ap','si'}))
                    error('Unrecognized pad orientation. Please enter ''lr'', ''ap'', or ''si'' for pad orientation; or just enter the direction vector of the long axis of the pad');
                end
                for i=1:length(elecType)
                    if strcmpi(elecType{i},'pad')
                        elecOri{i} = elecOri0;
                    else
                        elecOri{i} = [];
                    end
                end
            else
                if size(elecOri0,2)~=3
                    error('Unrecognized pad orientation. Please enter ''lr'', ''ap'', or ''si'' for pad orientation; or just enter the direction vector of the long axis of the pad');
                end
                numPad = 0;
                for i=1:length(elecType)
                    if strcmpi(elecType{i},'pad')
                        numPad = numPad+1;
                    end
                end
                if size(elecOri0,1)>1
                    if size(elecOri0,1)~=numPad
                        error('You want different orientations for each pad electrode. Please tell ROAST the orientation for each pad respectively, in a N-by-3 matrix, where N is the number of pads to be placed.');
                    end
                else
                    elecOri0 = repmat(elecOri0,numPad,1);
                end
                i0=1;
                for i=1:length(elecType)
                    if strcmpi(elecType{i},'pad')
                        elecOri{i} = elecOri0(i0,:);
                        i0 = i0+1;
                    else
                        elecOri{i} = [];
                    end
                end
            end
        else
            if length(elecOri)~=length(elecType)
                error('You want to place another type of electrodes aside from pad. Please tell ROAST the orienation for each electrode respectively, as the value for option ''elecOri'', in a cell array of length equals to the number of electrodes to be placed (put [] for non-pad electrodes).');
            end
            for i=1:length(elecOri)
                if strcmpi(elecType{i},'pad')
                    if isempty(elecOri{i})
                        elecOri{i} = 'lr';
                    else
                        if ischar(elecOri{i})
                            if ~any(strcmpi(elecOri{i},{'lr','ap','si'}))
                                error('Unrecognized pad orientation. Please enter ''lr'', ''ap'', or ''si'' for pad orientation; or just enter the direction vector of the long axis of the pad');
                            end
                        else
                            if size(elecOri{i},2)~=3
                                error('Unrecognized pad orientation. Please enter ''lr'', ''ap'', or ''si'' for pad orientation; or just enter the direction vector of the long axis of the pad');
                            end
                            if size(elecOri{i},1)>1
                                error('You''re placing more than 1 type of electrodes. Please put orientation info for each pad electrode as a 1-by-3 vector or one of the three keywords ''lr'', ''ap'', or ''si'' in a cell array for option ''elecOri''.');
                            end
                        end
                    end
                else
                    %                     warning('You''re not placing pad electrodes; customized orientation options will be ignored.');
                    elecOri{i} = [];
                end
            end
        end
    end
end

elecPara = struct('capType',capType,'elecType',elecType,...
        'elecSize',elecSize,'elecOri',elecOri);

if ~exist('T2','var')
    T2 = [];
else
    if ~exist(T2,'file'), error(['The T2 MRI you provided ' T2 ' does not exist.']); end
end

if ~exist('meshOpt','var')
    meshOpt = struct('radbound',5,'angbound',30,'distbound',0.4,'reratio',3,'maxvol',10);
else
    if ~isstruct(meshOpt), error('Unrecognized format of mesh options. Please enter as a structure, with field names as ''radbound'',''angbound'',''distbound'',''reratio'', and ''maxvol''. Please refer to the iso2mesh documentation for more details.'); end
    meshOptNam = fieldnames(meshOpt);
    if isempty(meshOptNam) || ~all(ismember(meshOptNam,{'radbound';'angbound';'distbound';'reratio';'maxvol'}))
        error('Unrecognized mesh options detected. Supported mesh options are ''radbound'',''angbound'',''distbound'',''reratio'', and ''maxvol''. Please refer to the iso2mesh documentation for more details.');
    end
    warning('You''re changing the advanced options of ROAST. Unless you know what you''re doing, please keep mesh options default.');
    if ~isfield(meshOpt,'radbound'), meshOpt.radbound = 5; end
    if ~isfield(meshOpt,'angbound'), meshOpt.angbound = 30; end
    if ~isfield(meshOpt,'distbound'), meshOpt.distbound = 0.4; end
    if ~isfield(meshOpt,'reratio'), meshOpt.reratio = 3; end
    if ~isfield(meshOpt,'maxvol'), meshOpt.maxvol = 10; end
end

if ~exist('simTag','var'), simTag = []; end

% preprocess electrodes
[elecPara,ind2usrInput] = elecPreproc(subj,elecName,elecPara);

injectCurrent = (cell2mat(recipe(2:2:end)))';
if abs(sum(injectCurrent))>eps
    error('Electric currents going in and out of the head not balanced. Please make sure they sum to 0.');
end
elecName = elecName(ind2usrInput);
injectCurrent = injectCurrent(ind2usrInput);

% sort elec options
if length(elecPara)==1
    if size(elecSize,1)>1, elecPara.elecSize = elecPara.elecSize(ind2usrInput,:); end
    if ~ischar(elecOri) && size(elecOri,1)>1
        elecPara.elecOri = elecPara.elecOri(ind2usrInput,:);
    end
elseif length(elecPara)==length(elecName)
    elecPara = elecPara(ind2usrInput);
else
    error('Something is wrong!');
end

configTxt = [];
for i=1:length(elecName)
    configTxt = [configTxt elecName{i} ' (' num2str(injectCurrent(i)) ' mA), '];
end
configTxt = configTxt(1:end-2);

options = struct('configTxt',configTxt,'elecPara',elecPara,'T2',T2,'meshOpt',meshOpt,'uniqueTag',simTag);

% log tracking
[dirname,baseFilename] = fileparts(subj);
if isempty(dirname), dirname = pwd; end

Sopt = dir([dirname filesep baseFilename '_*_options.mat']);
if isempty(Sopt)
    options = writeRoastLog(subj,options);
else
    isNew = zeros(length(Sopt),1);
    for i=1:length(Sopt)
        load([dirname filesep Sopt(i).name],'opt');
        isNew(i) = isNewOptions(options,opt);
    end
    if all(isNew)
        options = writeRoastLog(subj,options);
    else
        load([dirname filesep Sopt(find(~isNew)).name],'opt');
        options.uniqueTag = opt.uniqueTag;
    end
end
uniqueTag = options.uniqueTag;

fprintf('\n\n');
disp('======================================================')
if ~strcmp(baseFilename,'nyhead')
    disp(['ROAST ' subj])
else
    disp('ROAST New York head')
end
disp('USING RECIPE:')
disp(configTxt)
disp('...and simulation options saved in:')
disp([dirname filesep baseFilename '_log,'])
disp(['under tag: ' uniqueTag])
disp('======================================================')
fprintf('\n\n');

addpath(genpath([fileparts(which(mfilename)) filesep 'lib/']));

if ~strcmp(baseFilename,'nyhead')
    
    if (isempty(T2) && ~exist([dirname filesep 'c1' baseFilename '_T1orT2.nii'],'file')) ||...
            (~isempty(T2) && ~exist([dirname filesep 'c1' baseFilename '_T1andT2.nii'],'file'))
        disp('======================================================')
        disp('            STEP 1: SEGMENT THE MRI...                ')
        disp('======================================================')
        start_seg(subj,T2);
    else
        disp('======================================================')
        disp('          MRI ALREADY SEGMENTED, SKIP STEP 1          ')
        disp('======================================================')
    end
    
    if (isempty(T2) && ~exist([dirname filesep baseFilename '_T1orT2_mask_gray.nii'],'file')) ||...
            (~isempty(T2) && ~exist([dirname filesep baseFilename '_T1andT2_mask_gray.nii'],'file'))
        disp('======================================================')
        disp('          STEP 2: SEGMENTATION TOUCHUP...             ')
        disp('======================================================')
        mysegment(subj,T2);
        autoPatching(subj,T2);
    else
        disp('======================================================')
        disp('    SEGMENTATION TOUCHUP ALREADY DONE, SKIP STEP 2    ')
        disp('======================================================')
    end
    
else
    
    disp('======================================================')
    disp(' NEW YORK HEAD SELECTED, GOING TO STEP 3 DIRECTLY...  ')
    disp('======================================================')
    warning('New York head is a 0.5 mm model so is more computationally expensive. Make sure you have decent machine to run ROAST with New York head.')
    
end

if ~exist([dirname filesep baseFilename '_' uniqueTag '_rnge.mat'],'file')
    disp('======================================================')
    disp('          STEP 3: ELECTRODE PLACEMENT...              ')
    disp('======================================================')
    [rnge_elec,rnge_gel] = electrodePlacement(subj,T2,elecName,elecPara,uniqueTag);
else
    disp('======================================================')
    disp('         ELECTRODE ALREADY PLACED, SKIP STEP 3        ')
    disp('======================================================')
    load([dirname filesep baseFilename '_' uniqueTag '_rnge.mat'],'rnge_elec','rnge_gel');
end

if ~exist([dirname filesep baseFilename '_' uniqueTag '.mat'],'file')
    disp('======================================================')
    disp('            STEP 4: MESH GENERATION...                ')
    disp('======================================================')
    [node,elem,face] = meshByIso2mesh(subj,T2,meshOpt,uniqueTag);
else
    disp('======================================================')
    disp('          MESH ALREADY GENERATED, SKIP STEP 4         ')
    disp('======================================================')
    load([dirname filesep baseFilename '_' uniqueTag '.mat'],'node','elem','face');
end

if ~exist([dirname filesep baseFilename '_' uniqueTag '_v.pos'],'file')
    disp('======================================================')
    disp('           STEP 5: SOLVING THE MODEL...               ')
    disp('======================================================')
    label_elec = prepareForGetDP(subj,T2,node,elem,rnge_elec,rnge_gel,elecName,uniqueTag);
    solveByGetDP(subj,injectCurrent,uniqueTag);
else
    disp('======================================================')
    disp('           MODEL ALREADY SOLVED, SKIP STEP 5          ')
    disp('======================================================')
    load([dirname filesep baseFilename '_' uniqueTag '_elecMeshLabels.mat'],'label_elec');
end

if ~exist([dirname filesep baseFilename '_' uniqueTag '_result.mat'],'file')
    disp('======================================================')
    disp('     STEP 6: SAVING AND VISUALIZING THE RESULTS...    ')
    disp('======================================================')
    [vol_all,ef_mag] = postGetDP(subj,node,uniqueTag);
    visualizeRes(subj,T2,node,elem,face,vol_all,ef_mag,injectCurrent,label_elec,uniqueTag,0);
else
    disp('======================================================')
    disp('  ALL STEPS DONE, LOADING RESULTS FOR VISUALIZATION   ')
    disp('======================================================')
    load([dirname filesep baseFilename '_' uniqueTag '_result.mat'],'vol_all','ef_mag');
    visualizeRes(subj,T2,node,elem,face,vol_all,ef_mag,injectCurrent,label_elec,uniqueTag,1);
end
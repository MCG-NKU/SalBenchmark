function RunDatasets( SubNames, MethodNames, RootDir)
    addpath('../');
    mNum = length(MethodNames);
    dNum = length(SubNames);
    timeUsed = zeros(dNum, mNum);
    for methodID = 1 : mNum %% for each method
        cd(MethodNames{methodID});        
        subDirs = genpath('./');
        addpath(subDirs);
        if exist('./compile.m', 'file')
            compile;
        end
        
        for ds = 1 : dNum %% for each dataset
            WkDir = [RootDir SubNames{ds}];
            InDir = [WkDir 'Imgs/'];
            OutDir = [WkDir 'Saliency/'];
            if ~exist(OutDir, 'dir')
                mkdir(OutDir);
            end
            fprintf('Processing dataset: %s\r', WkDir);    

            d = dir([InDir, '*.jpg']);
            imgFiles = {d(~[d.isdir]).name};
            fileNum = length(imgFiles);

            % Use clock instead to typical tic/toc pairs because these third party 
            % programs some times have mismatched tic/toc commands used inside the *.p 
			% *.mexw* files, which we don't have access to modify. 
            % The cputime function is pretty bad in accuracy as also suggested in matlab doc.
            clockTimeStart = clock;
            
            % Using parfor can get results for the whole dataset faster, 
            % but we ignor it in the default setting to be more fair
            parfor fileID = 1:fileNum  %% for each image file. 
                fprintf('%d/%d: ', fileID, length(imgFiles));    
                GetSal(WkDir, imgFiles{fileID}(1:end-4), MethodNames{methodID});
            end
            timeU = clock - clockTimeStart;
            
            timeUsed(ds, methodID) = (((timeU(3)*24 + timeU(4))*60 + timeU(5))*60 + timeU(6))/fileNum;

        end        
        rmpath(subDirs);
        cd ..
    end    
    rmpath('../');
    
    % Out put timing
  
   
end



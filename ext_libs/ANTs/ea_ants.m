function ea_ants(fixedimage, movingimage, outputimage)
% Wrapper for ANTs linear registration

if fileparts(movingimage)
    volumedir = [fileparts(movingimage), filesep];
else
    volumedir =['.', filesep];
end

[outputdir, outputname, ~] = fileparts(outputimage);
if outputdir 
    outputbase = [outputdir, filesep, outputname];
else
    outputbase = ['.', filesep, outputname];
end

fixedimage = ea_path_helper(fixedimage);
movingimage = ea_path_helper(movingimage);
outputimage = ea_path_helper(outputimage);

basedir = [fileparts(mfilename('fullpath')), filesep];

if ispc
    HEADER = [basedir, 'PrintHeader.exe'];
    ANTS = [basedir, 'antsRegistration.exe'];
elseif isunix
    HEADER = [basedir, 'PrintHeader.', computer];
    ANTS = [basedir, 'antsRegistration.', computer];
end

if ~ispc
    [~, imgsize] = system(['bash -c "', HEADER, ' ',fixedimage, ' 2"']);
else
    [~, imgsize] = system([HEADER, ' ', fixedimage, ' 2']);
end
imgsize = cellfun(@(x) str2double(x),strsplit(imgsize,'x'));

if any(imgsize>256)
    rigidconvergence='[1000x500x250x0,1e-6,10]';
    rigidshrinkfactors='12x8x4x2';
    rigidsoomthingssigmas='4x3x2x1vox';

    affineconvergence='[1000x500x250x0,1e-6,10]';
    affineshrinkfactors='12x8x4x2';
    affinesoomthingssigmas='4x3x2x1vox';
else
    rigidconvergence='[1000x500x250x0,1e-6,10]';
    rigidshrinkfactors='8x4x2x1';
    rigidsoomthingssigmas='3x2x1x0vox';

    affineconvergence='[1000x500x250x0,1e-6,10]';
    affineshrinkfactors='8x4x2x1';
    affinesoomthingssigmas='3x2x1x0vox';
end

rigidstage = [' --transform Rigid[0.1]' ...
              ' --metric MI[', fixedimage, ',', movingimage, ',1,32,Regular,0.25]' ...
              ' --convergence ', rigidconvergence, ...
              ' --shrink-factors ', rigidshrinkfactors, ...
              ' --smoothing-sigmas ', rigidsoomthingssigmas];          
          
if exist([volumedir, 'ct2anat.mat'],'file')
    rigidstage = [' --initial-moving-transform ',ea_path_helper([volumedir, 'ct2anat.mat']), rigidstage];
else
    rigidstage = [' --initial-moving-transform [', fixedimage, ',', movingimage, ',1]', rigidstage];
end

affinestage = [' --transform Affine[0.1]'...
               ' --metric MI[', fixedimage, ',', movingimage, ',1,32,Regular,0.25]' ...
               ' --convergence ', affineconvergence, ...
               ' --shrink-factors ', affineshrinkfactors ...
               ' --smoothing-sigmas ', affinesoomthingssigmas];

ea_libs_helper
cmd = [ANTS, ' --verbose 1' ...
       ' --dimensionality 3 --float 1' ...
       ' --output [',ea_path_helper(outputbase), ',', outputimage, ']' ...
       ' --interpolation Linear' ...
       ' --use-histogram-matching 1' ...
       ' --winsorize-image-intensities [0.005,0.995]', ...
       rigidstage, affinestage];
if ~ispc
    system(['bash -c "', cmd, '"']);
else
    system(cmd);
end
movefile([outputbase, '0GenericAffine.mat'], [volumedir, 'ct2anat.mat']);
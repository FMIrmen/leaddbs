function ea_brainsfit(fixedfilename, movingfilename, coregisteredoutputvolume)
% Wrapper for BRAINSFit
pth=[fileparts(fixedfilename),filesep];
if exist([pth,'ct2anat.xform'],'file');
fixparams = [' --useRigid --useAffine' ...
              ' --samplingPercentage 0.005' ...
              ' --removeIntensityOutliers 0.005' ...
              ' --initializeTransformMode Off' ...
              ' --initialTransform ',pth,'ct2anat.xform';
              ' --interpolationMode Linear' ...
              ' --outputTransform ',pth,'ct2anat.xform'];
else
   fixparams = [' --useRigid --useAffine' ...
              ' --samplingPercentage 0.005' ...
              ' --removeIntensityOutliers 0.005' ...
              ' --initializeTransformMode useGeometryAlign' ...
              ' --interpolationMode Linear' ...
              ' --outputTransform ',pth,'ct2anat.xform']; 
end

basename = [fileparts(mfilename('fullpath')), filesep, 'BRAINSFit'];

if ispc
    BRAINSFit = [basename, '.exe '];
elseif isunix
    BRAINSFit = [basename, '.', computer, ' '];
end

ea_libs_helper
system([BRAINSFit, fixparams, ...
        ' --fixedVolume ' , fixedfilename, ...
        ' --movingVolume ', movingfilename, ...
        ' --outputVolume ', coregisteredoutputvolume]);
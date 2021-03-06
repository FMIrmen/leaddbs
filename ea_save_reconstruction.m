function ea_save_reconstruction(coords_mm,trajectory,markers,elmodel,manually_corrected,options)

reco.props.elmodel=elmodel;
reco.props.manually_corrected=manually_corrected;

if options.native
    reco.native.coords_mm=coords_mm;
    reco.native.trajectory=trajectory;
    reco.native.markers=markers;
    save([options.root,options.patientname,filesep,'ea_reconstruction'],'reco');
    if isfield(options,'hybridsave');
        ea_dispt('Warping fiducials to template space');
        
        ea_reconstruction2mni(options);
        if options.prefs.reco.saveACPC
            ea_dispt('Mapping fiducials to AC/PC space');
            ea_reconstruction2acpc(options);
        end
        load([options.root,options.patientname,filesep,'ea_reconstruction']);
        ea_checkswap_lr(reco,options); % PaCER support, right could be left and vice versa.
        save([options.root,options.patientname,filesep,'ea_reconstruction'],'reco');
        
    end
else
    reco.mni.coords_mm=coords_mm;
    reco.mni.trajectory=trajectory;
    reco.mni.markers=markers;
    save([options.root,options.patientname,filesep,'ea_reconstruction'],'reco');
    
    if isfield(options,'hybridsave');
        
            ea_dispt('Warping fiducials to native space');
            ea_reconstruction2native(options);
            if options.prefs.reco.saveACPC
                ea_dispt('Mapping fiducials to AC/PC space');
                ea_reconstruction2acpc(options);
            end
            load([options.root,options.patientname,filesep,'ea_reconstruction']);
            [reco,corrected]=ea_checkswap_lr(reco,options); % PaCER support, right could be left and vice versa.
        
        save([options.root,options.patientname,filesep,'ea_reconstruction'],'reco');
        if corrected
            options.hybridsave=1;
            ea_save_reconstruction(reco.mni.coords_mm,reco.mni.trajectory,reco.mni.markers,elmodel,manually_corrected,options)
        end
    end
    
end


function [reco,corrected]=ea_checkswap_lr(reco,options)
options.native=0; % this can only be done in MNI space.
%[coords_mm,trajectory,markers,elmodel,manually_corrected]=ea_load_reconstruction(options);
corrected=0;
if mean(reco.mni.coords_mm{1}(:,1))<mean(reco.mni.coords_mm{2}(:,1)) % RL swapped
    % swap RL:
    options.hybridsave=1;
    ncoords_mm{1}=reco.mni.coords_mm{2};    ncoords_mm{2}=reco.mni.coords_mm{1};
    ntrajectory{1}=reco.mni.trajectory{2};    ntrajectory{2}=reco.mni.trajectory{1};
    nmarkers(1)=reco.mni.markers(2); nmarkers(2)=reco.mni.markers(1);

    reco.mni.coords_mm=ncoords_mm;
    reco.mni.trajectory=ntrajectory;
    reco.mni.markers=nmarkers;
    corrected=1;
end

vizz=0;

% check that markers are correct (important for directional leads):
if ~reco.props.manually_corrected
    options.hybridsave=1;
    
    for side=options.sides
        if vizz
        figure
        hold on
        plot3(reco.mni.trajectory{side}(:,1),reco.mni.trajectory{side}(:,2),reco.mni.trajectory{side}(:,3),'r-');
        plot3(reco.mni.markers(side).head(:,1),reco.mni.markers(side).head(:,2),reco.mni.markers(side).head(:,3),'y*');
        plot3(reco.mni.markers(side).tail(:,1),reco.mni.markers(side).tail(:,2),reco.mni.markers(side).tail(:,3),'m*');
        plot3(reco.mni.markers(side).x(:,1),reco.mni.markers(side).x(:,2),reco.mni.markers(side).x(:,3),'k*');
        plot3(reco.mni.markers(side).y(:,1),reco.mni.markers(side).y(:,2),reco.mni.markers(side).y(:,3),'g*');
        end
        if reco.mni.markers(side).head(2)<reco.mni.markers(side).y(2) % FIX ME need to check whether > or < is correct here.
            reco.mni.markers(side).y=reco.mni.markers(side).head+(reco.mni.markers(side).head-reco.mni.markers(side).y); % 180 deg flip
        corrected=1;
        end
        if reco.mni.markers(side).head(1)>reco.mni.markers(side).x(1) % FIX ME need to check whether > or < is correct here.
            reco.mni.markers(side).x=reco.mni.markers(side).head+(reco.mni.markers(side).head-reco.mni.markers(side).x);
        corrected=1;
        end
        if vizz
            plot3(reco.mni.markers(side).x(:,1),reco.mni.markers(side).x(:,2),reco.mni.markers(side).x(:,3),'ko');
            plot3(reco.mni.markers(side).y(:,1),reco.mni.markers(side).y(:,2),reco.mni.markers(side).y(:,3),'go');
            axis equal
            keyboard
        end
        
    end
    reco.mni.coords_mm=ea_resolvecoords(reco.mni.markers,options);
end



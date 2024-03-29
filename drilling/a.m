% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  Copyright (C) 2020 HOLOEYE Photonics AG. All rights reserved.
%  Contact: https://holoeye.com/contact/
%  
%  This file is part of HOLOEYE SLM Display SDK.
%  
%  You may use this file under the terms and conditions of the
%  "HOLOEYE SLM Display SDK Standard License v1.0" license agreement.
%  
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% Uses the built-in blank screen function to show a given grayscale value on the full SLM.
% Then we use the beam manipulation provided through the data handles to apply a phase overlay (tip/tilt/lens/offset).

% Import SDK:
add_heds_path;

% Check if the installed SDK supports the required API version
heds_requires_version(3);


% Make some enumerations available locally to avoid too much code:
heds_types;

% Detect SLMs and open a window on the selected SLM:
heds_slm_init;

% Open the SLM preview window (might have an impact on performance):
show_slm_preview(1.0);

% Configure the blank screen where overlay is applied to:
grayValue = 128;
grayValueOffset = -128; % this value is applied also as a beam manipulation later.

% Configure beam manipulation in physical units:
wavelength_nm = 790.0;  % wavelength of incident laser light



% Upload a datafield into the GPU. The datafield just consists of a single pixel with the grayValue and will
% automatically be extended into full SLM screen due to "PresetAutomatic" show flag.
% The heds_load_data() call creates a handle which refers to the grayValue data.
handle = heds_load_data(uint8(grayValue));

% Wait for the data to be processed internally to speed up the heds_show_datahandle(handle) call later:
heds_datahandle_waitfor(handle.id, heds_state.ReadyToRender);

% Make the data without overlay visible on SLM screen:
heds_show_datahandle(handle.id);

% Wait 2 seconds until we apply the beam manipulation to make the uploaded data visible first:
heds_utils_wait_s(2.0);

p = 0.6;
focal_length_mm = -20000.0;

l = 0.02;%同心环的间隔
n = 6;
s = 0.02;  % density
r = 0;

x=0.0;

% y = 250.88*(x.^(-0.949))
for f=1:30   %0.4/feed

    for u=r:n
        u
        steering_angle_x_deg = p-l*u;
        steering_angle_y_deg = p-l*u;

        for t=0:s:2.0*pi
            steering_angle_x_deg1 = 0 + steering_angle_x_deg*cos(t);
            steering_angle_y_deg1 = 0 + steering_angle_y_deg*sin(t);
                
            % Calculate proper parameters to pass to the data handle:
            beam_lens_param = heds_utils_beam_lens_from_focal_length_mm(wavelength_nm, focal_length_mm);
            beam_steer_x_param = heds_utils_beam_steer_from_angle_deg(wavelength_nm, steering_angle_x_deg1);
            beam_steer_y_param = heds_utils_beam_steer_from_angle_deg(wavelength_nm, steering_angle_y_deg1);
    
            % Now, after heds_load_data(), we apply values to the beam manipulation parameters of the handle:
            handle.beamSteerX = beam_steer_x_param;
            handle.beamSteerY = beam_steer_y_param;
            handle.beamLens = beam_lens_param;
            % The handle.valueOffset is given in float gray values (like in heds_show_data(single(data))).
            % Actually addressed 8-bit gray values in range [0, 255] translate to float gray values in range [0, 1].
            % Both ranges typically translate to a phase shift in range [0 rad, (255/256)*2pi rad] due to the phase calibration
            % of the SLM and to make the addressed phase values periodic, i.e. gray value 256 must equal gray value 0.
            handle.valueOffset = grayValueOffset/255;
%             handle.transformShiftX = 0;
%             handle.transformShiftY = 0;
%             handle.transformScale = .5;
            % Apply the beam steering values from the handle structure to the SLM Display SDK.
            % This will take effect on SLM screen directly, because we made the handle visible before applying values.
            % Of course we also can apply the parameters before showing the handle on screen.
            % We explicitly pass which values to apply by using the "heds_datahandle_applyvalue" flags:
            %+ heds_datahandle_applyvalue.Transform
            heds_datahandle_apply(handle, heds_datahandle_applyvalue.BeamManipulation + heds_datahandle_applyvalue.ValueOffset );
            heds_utils_wait_ms(60);
            % Now the data should have changed by our beam manipulations.
        end
          
    end
%     if f==10||f==15||f==20||f==25||f==28%||f==35  %f==5||
% %     r=r-1
% %     n=n-1
%     end
    x = f*0.014
    f
    focal_length_mm = 250.88*(x.^(-0.949));
    focal_length_mm = -round(focal_length_mm)

end
% % r = r-1
% % % n = n-1;
% for f=1:10
%     x = x+(f*0.015)
%     focal_length_mm = 250.88*(x.^(-0.949)) 
%     for u=r:n
%         u
%         steering_angle_x_deg = p-l*u;
%         steering_angle_y_deg = p-l*u;
% 
%         for t=0:s:2.0*pi
%             steering_angle_x_deg1 = 0 + steering_angle_x_deg*cos(t);
%             steering_angle_y_deg1 = 0 + steering_angle_y_deg*sin(t);
%                 
%             % Calculate proper parameters to pass to the data handle:
%             beam_lens_param = heds_utils_beam_lens_from_focal_length_mm(wavelength_nm, focal_length_mm);
%             beam_steer_x_param = heds_utils_beam_steer_from_angle_deg(wavelength_nm, steering_angle_x_deg1);
%             beam_steer_y_param = heds_utils_beam_steer_from_angle_deg(wavelength_nm, steering_angle_y_deg1);
%     
%             % Now, after heds_load_data(), we apply values to the beam manipulation parameters of the handle:
%             handle.beamSteerX = beam_steer_x_param;
%             handle.beamSteerY = beam_steer_y_param;
%             handle.beamLens = beam_lens_param;
%             % The handle.valueOffset is given in float gray values (like in heds_show_data(single(data))).
%             % Actually addressed 8-bit gray values in range [0, 255] translate to float gray values in range [0, 1].
%             % Both ranges typically translate to a phase shift in range [0 rad, (255/256)*2pi rad] due to the phase calibration
%             % of the SLM and to make the addressed phase values periodic, i.e. gray value 256 must equal gray value 0.
%             handle.valueOffset = grayValueOffset/255;
% %             handle.transformShiftX = 0;
% %             handle.transformShiftY = 0;
% %             handle.transformScale = .5;
%             % Apply the beam steering values from the handle structure to the SLM Display SDK.
%             % This will take effect on SLM screen directly, because we made the handle visible before applying values.
%             % Of course we also can apply the parameters before showing the handle on screen.
%             % We explicitly pass which values to apply by using the "heds_datahandle_applyvalue" flags:
%             %heds_datahandle_apply(handle, heds_datahandle_applyvalue.BeamManipulation + heds_datahandle_applyvalue.ValueOffset + heds_datahandle_applyvalue.Transform);
%             heds_datahandle_apply(handle, heds_datahandle_applyvalue.BeamManipulation + heds_datahandle_applyvalue.ValueOffset );
%             heds_utils_wait_ms(30);
%             % Now the data should have changed by our beam manipulations.
%         end
%             
%     end
%     focal_length_mm = focal_length_mm +400;
% end
% r = r-2
% % n = n-2;
% for f=1:18
%     focal_length_mm 
%     
%     for u=r:n
%         u
%         steering_angle_x_deg = p-l*u;
%         steering_angle_y_deg = p-l*u;
% 
%         for t=0:s:2.0*pi
%             steering_angle_x_deg1 = 0 + steering_angle_x_deg*cos(t);
%             steering_angle_y_deg1 = 0 + steering_angle_y_deg*sin(t);
%                 
%             % Calculate proper parameters to pass to the data handle:
%             beam_lens_param = heds_utils_beam_lens_from_focal_length_mm(wavelength_nm, focal_length_mm);
%             beam_steer_x_param = heds_utils_beam_steer_from_angle_deg(wavelength_nm, steering_angle_x_deg1);
%             beam_steer_y_param = heds_utils_beam_steer_from_angle_deg(wavelength_nm, steering_angle_y_deg1);
%     
%             % Now, after heds_load_data(), we apply values to the beam manipulation parameters of the handle:
%             handle.beamSteerX = beam_steer_x_param;
%             handle.beamSteerY = beam_steer_y_param;
%             handle.beamLens = beam_lens_param;
%             % The handle.valueOffset is given in float gray values (like in heds_show_data(single(data))).
%             % Actually addressed 8-bit gray values in range [0, 255] translate to float gray values in range [0, 1].
%             % Both ranges typically translate to a phase shift in range [0 rad, (255/256)*2pi rad] due to the phase calibration
%             % of the SLM and to make the addressed phase values periodic, i.e. gray value 256 must equal gray value 0.
%             handle.valueOffset = grayValueOffset/255;
% %             handle.transformShiftX = 0;
% %             handle.transformShiftY = 0;
% %             handle.transformScale = .5;
%             % Apply the beam steering values from the handle structure to the SLM Display SDK.
%             % This will take effect on SLM screen directly, because we made the handle visible before applying values.
%             % Of course we also can apply the parameters before showing the handle on screen.
%             % We explicitly pass which values to apply by using the "heds_datahandle_applyvalue" flags:
%             %heds_datahandle_apply(handle, heds_datahandle_applyvalue.BeamManipulation + heds_datahandle_applyvalue.ValueOffset + heds_datahandle_applyvalue.Transform);
%             heds_datahandle_apply(handle, heds_datahandle_applyvalue.BeamManipulation + heds_datahandle_applyvalue.ValueOffset );
%             heds_utils_wait_ms(30);
%             % Now the data should have changed by our beam manipulations.
%         end
%        
%         
%     end
%     focal_length_mm = focal_length_mm +25;
% end

heds_show_phasevalues(128);



% Please uncomment to close SDK at the end:
% heds_utils_wait_s(8.0);
% heds_close_slm

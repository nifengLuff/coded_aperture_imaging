%% correted spectrum and raw spectrum
clear;
spectrum = load('naked_smooth_depth_correction_energy_calibrated_spectrum.txt');
corrected_spectrum=spectrum(66, 4:2:2002);
% original_spectrum=data(:,2);
% selected_spectrum=data(:,3);
x = spectrum(66, 3:2:2002);
figure
plot(x, corrected_spectrum,"LineWidth",1,"Color",'black');
xlim([0, 1500]);
ylim([0, 2500]);
hold on
plot(x, corrected_spectrum,"LineWidth",1,"Color",'b');
hold on
plot(x, corrected_spectrum,"LineWidth",1,"Color",'r');
legend(gca,"without aperture","dark pixel (with aperture)","bright pixel (with aperture)",'Interpreter','none');
xlabel('Energy (keV)','FontWeight','bold','FontName','Times New Roman','FontSize',10);
ylabel('Counts','FontWeight','bold','FontName','Times New Roman','FontSize',10);
set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
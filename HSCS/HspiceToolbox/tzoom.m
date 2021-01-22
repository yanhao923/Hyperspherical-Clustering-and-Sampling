function tzoom (varargin)
%TZOOM   adds GUI zooming and cropping to a 2-D figure with a single plot or
%           multiple axes with a common abscissa (e.g. time). 
%           Note that TZOOM can be used with any 2-D figure regardless of
%           type of the subplots in the figure, and hence the x-axis is not
%           restricted to time. Nevertheless, it will be assumed for the
%           help content below, that time is the x-axis.
%           The follow arguments below are all accessible from the buttons
%   
%   TZOOM with no arguments adds the GUI buttons to the current figure.
%       It does nothing if there is no current figure
%   TZOOM ZOOM zooms the time scale to the time coordinates of the two
%       pointes selected using the left-hand mouse button 
%       Note that if any other buttons are pressed, including the keyboard,
%       tzoom does nothing. This is useful as an escape code.
%   TZOOM UNZOOM unzooms the time scale. Similar to TZOOM ZOOM in
%       operation, but instead unzooms the time scale to the following: 
%       1)scale_center=midpoint between the two points 
%       2)unzoom_factor=(time distance between the two points)/(current scale range)    
%   TZOOM FULL sets the x-axis scale mode to auto, to show the full range of the data 
%   TZOOM LIMITS sets the lower and upper time limits using a user input dialog box.
%       This is useful when precise time scale limits are needed. For example when
%       comparing two figures with slightly shifed signals.
%   TZOOM CROP crops the time scale. Similar to TZOOM ZOOM but instead
%       deletes the data outside the selected limits. This especially useful for
%       plots with a large number of points which take a long time for the
%       figure to refresh. Note that each plot in MATLAB stores its data in 
%       its properties, even if the data was removed from the MATALB workspace.
%       Note that the crop functions are not reversible. All the data
%       outside the specified range will be deleted from the figure (but
%       not from the MATLAB workspace). 
%   TZOOM CROPNEW copies the figure to a new one with identical format but
%       with only the data in the selected time range 
%       This function is especially useful when comparing signals at
%       different times of the same figure.
%       The figure name of the new figure is changed to reflect its origin.
%       For example figure number 13 which was cropped from a figure with the name
%       "Figure No. 11" will be given the name"11/13". The figure name can
%       be changed through the figname function, in CppSim toolbox  
%   TZOOM MARKER toggles the marker in all the plots between a circle and no
%       marker. This is useful to distinguish the location of the data points.
%   TZOOM POINTER toggles the pointer between an arrow and a full
%       crosshair. This is useful when comparing signal levels of different
%       plots at the same time point, e.g. transitions in time diagrams
%   TZOOM REMOVE removes the TZOOM buttons from the figure (useually for
%       printing)
%       
%       Note for zoom/crop functions: clicking outside the plot areas avoids the
%       annoying delay between the pressing of the mouse button and the
%       actual point that gets selected (this happens if the mouse moves
%       after pressing on a plot with a large number of data points)
%
%   Written by Belal M Helal (bhelal@mit.edu) as part of the CppSim package. 6-16-2003
%   For more information: http://www-mtl.mit.edu/research/perrottgroup/tools.html

hf=get(0,'currentfigure');                  %get the handle for the current figure
    if isempty(hf)                          %if there is no current figure, do nothing
        return;
    end;
h_axes=findobj(hf,'Type','axes')';          %find the handles for the axes objects. The transpose is added to make it a one row and hence go through the indices of h_axes
%Check if there is no argument, in which case
if nargin==0;
    Command='gui';
else
    Command=lower(varargin{1});
end;
switch Command
%--------------------------------------------------------------------------
    case 'zoom',
        xx=ginput2;                         %get the two time points from the figure using the mouse
        if xx(1)==xx(2); return;end;        %do nothing if the two points are equal
        set(h_axes,'XLim',xx);              %Update the x-axis scale
%--------------------------------------------------------------------------
    case 'unzoom',
        current_limits=xlim(h_axes(end));       %get current time limits
        current_range=current_limits(2)-current_limits(1);
		xx=ginput2;                             %get the two time points from the figure using the mouse
        if xx(1)==xx(2); return;end;            %do nothing if the two points are equal
        a=xx(1);  b=xx(2);
        new_range=current_range^2/(b-a);
        new_center=(a+b)/2;
        xx=[new_center-new_range/2 new_center+new_range/2];
        set(h_axes,'XLim',xx);                  %Update the x-axis scale
%--------------------------------------------------------------------------        
     case 'full',
         set(h_axes,'XLimMode','auto');              %Update the x-axis scale
%--------------------------------------------------------------------------            
    case 'limits',
        current_limits=xlim(h_axes(end));   %get current time limits
        def = {num2str(current_limits(1),10),num2str(current_limits(2),10)};
        prompt = {'Enter the Lower time-limit:','Enter the Upper time-limit:'};
        answer  = inputdlg(prompt,'Set Time Scale Limits',1,def);
        if isempty(answer);return;end;      %do nothing in the case of a canceled input
        xx=[str2double(answer(1)) str2double(answer(2))];
        if xx(1)==xx(2); return;end;        %do nothing if the two points are equal
        set(h_axes,'XLim',xx);              %Update the x-axis scale
%--------------------------------------------------------------------------
    case 'crop',
        xx=ginput2;                             %get the two time points from the figure using the mouse
        if xx(1)==xx(2); return;end;            %do nothing if the two points are equal
		hl=get(h_axes(end),'Children');         %get the handle of line in the last axis
		xdata=get(hl,'XData');                  %get the time data points
		x1_index=find( min( abs( xdata-xx(1) ) ) == ( abs( xdata-xx(1) ) ) ); % get the index of the nearset point to the starting of the desired limit     
		x2_index=find( min( abs( xdata-xx(2) ) ) == ( abs( xdata-xx(2) ) ) ); % get the index of the nearset point to the end of the desired limit     
		if(x1_index==x2_index); return;end;
		for hai = h_axes; 
			hli=get(hai,'Children');                %get the handle of line in the current axis
            xlim(hai,xx);
			ydata=get(hli,'YData');set(hli,'XData',xdata(x1_index:x2_index),'YData',ydata(x1_index:x2_index));
		end
 %-------------------------------------------------------------------------
    case 'cropnew',
		xx=ginput2;                             %get the two time points from the figure using the mouse
        if xx(1)==xx(2); return;end;            %do nothing if the two points are equal
		hl=get(h_axes(end),'Children');         %get the handle of line in the last axis
		xdata=get(hl,'XData');                  %get the time data points
		x1_index=find( min( abs( xdata-xx(1) ) ) == ( abs( xdata-xx(1) ) ) ); % get the index of the nearset point to the starting of the desired limit     
		x2_index=find( min( abs( xdata-xx(2) ) ) == ( abs( xdata-xx(2) ) ) ); % get the index of the nearset point to the end of the desired limit     
		if(x1_index==x2_index); return;end;     %do nothing if the two points are the same
		old_fig=hf;                             %get the handle of the parent figure
        new_fig=figure; %make a new figure and return its handle
                        %name the figure to refelect that it is a cropped part of the original figure
                        %   this is useful when you have many figures and are trying to
                        %   figure the origins of these figures
        old_fig_name=get(old_fig,'Name');
        if strcmp(get(old_fig,'NumberTitle'),'on');                     %if the figure title is on (i.e. "Figure No. x)
            new_fig_name=[num2str(old_fig) '/' num2str(new_fig)];       %name the new figure x/y, where x and y are the number of the old and new figures, respectively
            if ~isempty(old_fig_name);
                new_fig_name=[new_fig_name ': ' old_fig_name];          %add the old name, in case it was not empty 
            end;
        else                                                            %if the figure title is turned off (i.e. no "Figure No. x"
            [old_num old_name]=strtok(old_fig_name,':');    %check if the figure had the format figure_number: figure_name
            last_slash=findstr(old_num,'/');                % get the position of the slashes, if any, before the ':'
                if length(last_slash)>0;                    %if there is a slash in the figure number (before the ':')  
                    last_slash=last_slash(end);             %get the postion of the last slash (in case there is more than one, e.g. 1/5/12)
                    old_num_last=str2double( old_num(last_slash+1:end) ); %find the number after the last slash/
                else
                    old_num_last=str2double( old_num);      %there is no slash, take the figure number
                end;
            if isnumeric(old_num_last)                      %doublecheck to see if the number before the ":" was a number
                old_num_test=old_num_last;                  %valid number before the ":"
            else 
                old_num_test=0;                             %not a valid number, flag to fail the old_num_test
            end;
                
            if old_num_test==old_fig; % this indicates that the old figure has the form "x: figure name"
                new_fig_name=[old_num '/' num2str(new_fig) old_name];
            else
                new_fig_name=[num2str(old_fig) '/' num2str(new_fig) ': ' old_fig_name];
            end;
        end;
        
        set(new_fig,'Name',new_fig_name);       %set the figure name
		set(new_fig,'NumberTitle','off');       %turn off the default figure title, i.e. don't show "Figure No. "
        subplot_i=0;                            %zero the subplot index
        subplot_n=length(h_axes);               %number of subplots in the figure
        %Consruct the subplots
        for hai = fliplr(h_axes);               %the transpose is added to make it a one row and hence go through the indices of h_axes, flip left-2-righ to start with the upper axes first
        subplot_i=subplot_i+1;  
            figure(new_fig);                    %focus on the new figure
    		ha_sub=subplot(subplot_n,1,subplot_i);
    		hl_sub=plot([0 0]);
            hli=get(hai,'Children');            %get the handle of line in the current axis
    		ydata=get(hli,'YData');y_label=get(hai,'YLabel');
            h_y_label=get(hai,'YLabel');y_label=get(h_y_label,'String');
            set(hl_sub,'XData',xdata(x1_index:x2_index),'YData',ydata(x1_index:x2_index));
            xlim(ha_sub,xx);                    %change the limits
            ylabel(y_label);
            grid on;
		end
        h_x_label=get(h_axes(1),'XLabel');x_label=get(h_x_label,'String'); xlabel(x_label);     %label the x-axis with the xlabel of the bottom axes
        tzoom gui;
%--------------------------------------------------------------------------    
    case 'marker',
        for hai = h_axes;
            hli=get(hai,'Children'); %get the handle of line in the current axis
            m_old=get(hli,'Marker');
            switch m_old
                case 'none',
                    set(hli,'Marker','o')
                case 'o',
                    set(hli,'Marker','none')
            end;
        end
%--------------------------------------------------------------------------
    case 'pointer',
        pointer = get(hf,'pointer');
        switch pointer
            case 'arrow',
                   set(hf,'pointer','fullcrosshair');
            case 'fullcrosshair',
                   set(hf,'pointer','arrow');
        end
%--------------------------------------------------------------------------                
    case 'gui'
		% Construct GUI
		buttonx      = .89;
		buttonwidth=0.11;
		buttonheight= 0.05;
		spacing=.9;
		hb=gcf;
		pq = uicontrol(hb   ,...                 % Time Zoom Button
             'Style'          , 'pushbutton',...
             'Units'          , 'normalized',...
             'String'         , 'Zoom-Time',...
             'Position'       , [buttonx, 0.05+spacing,buttonwidth,buttonheight],...
             'Callback'       ,'tzoom zoom');
         
		pq = uicontrol(hb   ,...                 % Time Un-Zoom Button
             'Style'          , 'pushbutton',...
             'Units'          , 'normalized',...
             'String'         , 'UnZoom-Time',...
             'Position'       , [.8, 0.05+.9,.11,.05],...
             'Callback'       ,'tzoom unzoom');

		pq = uicontrol(hb   ,...                 % Full Time Button
             'Style'          , 'pushbutton',...
             'Units'          , 'normalized',...
             'String'         , 'Full-Time',...
             'Position'       , [.67, 0.05+.9,.11,.05],...
             'Callback'       ,'tzoom full');         

         pq = uicontrol(hb   ,...                 % Set time-limits Button
             'Style'          , 'pushbutton',...
             'Units'          , 'normalized',...
             'String'         , 'Set Time Scale',...
             'Position'       , [.57, 0.05+.9,.11,.05],...
             'Callback'       ,'tzoom limits');
		         
		pq = uicontrol(hb   ,...                 % crop Button
             'Style'          , 'pushbutton',...
             'Units'          , 'normalized',...
             'String'         , 'Crop Time Scale',...
             'Position'       , [.45, 0.05+.9,.11,.05],...
             'Callback'       ,'tzoom crop');
		
         pq = uicontrol(hb   ,...                 % crop_newfig Button
             'Style'          , 'pushbutton',...
             'Units'          , 'normalized',...
             'String'         , 'Crop to NewFig',...
             'Position'       , [.35, 0.05+.9,.11,.05],...
             'Callback'       ,'tzoom cropnew');
         
		pq = uicontrol(hb   ,...                 % Toggle Marker Button
             'Style'          , 'pushbutton',...
             'Units'          , 'normalized',...
             'String'         , 'Toggle Marker',...
             'Position'       , [.23, 0.05+.9,.11,.05],...
             'Callback'       ,'tzoom marker');
         
		pq = uicontrol(hb   ,...                 % Toggle Pointer Button
             'Style'          , 'pushbutton',...
             'Units'          , 'normalized',...
             'String'         , 'Toggle Pointer',...
             'Position'       , [.13, 0.05+.9,.11,.05],...
             'Callback'       ,'tzoom pointer');
         
        pq = uicontrol(hb   ,...                 % remove GUI Button
             'Style'          , 'pushbutton',...
             'Units'          , 'normalized',...
             'String'         , 'Remove Buttons',...
             'Position'       , [0, 0.05+.9,.11,.05],...
             'Callback'       ,'tzoom remove');
%--------------------------------------------------------------------------                
    case 'remove'
        h_uic=findobj(hf,'Type','uicontrol')';
        delete(h_uic);
%--------------------------------------------------------------------------   
    otherwise,  %if the input to the function is unknown then just break 
        return;
    
end     %end of switch statment
%--------------------------------------------------------------------------

function two_points=ginput2()
    [x,y,button]=ginput(2);                     %get the two time points from the figure using the mouse
    if sum(button==1)~=2;x=[0 0];end;           %if the buttons pressed are not both the left buttons, flag to do nothing
    two_points=[min(x) max(x)];                 %order the two points

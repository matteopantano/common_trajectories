function Trajectories()
% Data is shared between all child functions by declaring the variables
% here (they become global to the function). We keep things tidy by putting
% all GUI stuff in one structure and all data stuff in another. As the app
% grows, we might consider making these objects rather than structures.
data = createData();
gui = createInterface( data.DemoNames );

rpm = 900;
position = 0;
time = 0;

% Now update the GUI with the current data
updateInterface();
redrawDemo();

% Explicitly call the demo display so that it gets included if we deploy
displayEndOfDemoMessage('')

% Helper subfunctions
%-------------------------------------------------------------------------%
    function data = createData()
        % Create the shared data-structure for this application
        demoList = {
            'Cubic polynomial'           'poly3'
            'Seventh degree polynomial'  'poly7'
            'Harmonic'                   'harmonic'
            'Spline'                     'spl3'
            'Poly for points'            'polypoints'
            };
        selectedDemo = 1;
        data = struct( ...
            'DemoNames', {demoList(:,1)'}, ...
            'DemoFunctions', {demoList(:,2)'}, ...
            'SelectedDemo', selectedDemo );
    end % createData

%-------------------------------------------------------------------------%
    function gui = createInterface( demoList )
        % Create the user interface for the application and return a
        % structure of handles for global use.
        gui = struct();
        % Open a window and add some menus
        %figure('units','normalized','outerposition',[0 0 1 1])
        gui.Window = figure( ...
            'Name', 'Gallery browser', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off', ...
            'units', 'normalized', ...
            'outerposition', [0.05 0.075 0.9 0.9]);
       
        % + File menu
        gui.FileMenu = uimenu( gui.Window, 'Label', 'File' );
        uimenu( gui.FileMenu, 'Label', 'Exit', 'Callback', @onExit );
        
        % + View menu
        gui.ViewMenu = uimenu( gui.Window, 'Label', 'View' );
        for ii=1:numel( demoList )
            uimenu( gui.ViewMenu, 'Label', demoList{ii}, 'Callback', @onMenuSelection );
        end
        
        % + Help menu
        helpMenu = uimenu( gui.Window, 'Label', 'Help' );
        uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @onHelp );
         
        % Arrange the main interface
        mainLayout = uix.HBoxFlex( 'Parent', gui.Window, 'Spacing', 1);
        
        % + Create the panels
        controlPanel = uix.BoxPanel( ...
            'Parent', mainLayout, ...
            'Title', 'Select a trajectory' );
        gui.ViewPanel = uix.BoxPanel( ...
            'Parent', mainLayout, ...
            'Title', 'Viewing: ???', ...
            'HelpFcn', @onGenerate );
        gui.ViewContainer = uicontainer( ...
            'Parent', gui.ViewPanel );  
        
        % + Create view panel for FFT
        gui.ViewPanelFFT = uix.BoxPanel( ...
                    'Parent', mainLayout, ...
                    'Title', 'Viewing: ???', ...
                    'HelpFcn', @onGenerate);
        gui.ViewFFTContainer = uicontainer( ...
            'Parent', gui.ViewPanelFFT ); 

        % + Adjust the main layout
        set( mainLayout, 'Widths', [-1,-2, -2]  );
        
        % + Create the controls
        controlLayout = uix.VBox( 'Parent', controlPanel, ...
            'Padding', 1, 'Spacing', 1 );
        gui.ListBox = uicontrol( 'Style', 'list', ...
            'BackgroundColor', 'w', ...
            'Parent', controlLayout, ...
            'String', demoList(:), ...
            'Value', 1, ...
            'Callback', @onListSelection);
        hbox = uix.HButtonBox( 'Parent', controlLayout, 'Padding', 1 );
        gui.GenerateButton = uicontrol( 'Style', 'PushButton', ... 
            'Parent', hbox, ...
            'String', 'Generate', ...
            'Callback', @onGenerate, ...
            'Background', 'g');
        gui.editButton = uicontrol( 'Style', 'edit', ... 
            'Parent', hbox, ...
            'String', 'RPM', ...
            'Callback', @onEdit); 
        gui.ExcelButton = uicontrol( 'Style', 'PushButton', ... 
            'Parent', hbox, ...
            'String', 'Excel', ...
            'Callback', @onExcel); 
        set( controlLayout, 'Heights', [-1 28] ); % Make the list fill the space
 
        % + Create the view
        p = gui.ViewContainer;
        
    end % createInterface

%-------------------------------------------------------------------------%
    function updateInterface()
        % Update various parts of the interface in response to the demo
        % being changed.
        
        % Update the list and menu to show the current demo
        set( gui.ListBox, 'Value', data.SelectedDemo );
        % Update the generate and RPM labels
        demoName = data.DemoNames{ data.SelectedDemo };
        set( gui.GenerateButton, 'String', ['Generate'] );
        set( gui.editButton, 'String', ['RPM'] );
        % Update the view panel title
        set( gui.ViewPanel, 'Title', sprintf( 'Viewing trajectory: %s', demoName ) );
        set( gui.ViewPanelFFT, 'Title', sprintf( 'Viewing FFT: %s', demoName ) );
        % Untick all menus
        menus = get( gui.ViewMenu, 'Children' );
        set( menus, 'Checked', 'off' );
        % Use the name to work out which menu item should be ticked
        whichMenu = strcmpi( demoName, get( menus, 'Label' ) );
        set( menus(whichMenu), 'Checked', 'on' );
    end % updateInterface

%-------------------------------------------------------------------------%
    function redrawDemo()
        % Draw a demo into the axes provided
        
        % objects for the two plots of trajectories
        gui.AxVbox = uiextras.VBox( 'Parent', gui.ViewContainer, ...
                    'Padding', 3, 'Spacing', 3 );
        gui.ViewAxes1 = axes( 'Parent', gui.AxVbox );
        gui.ViewAxes2 = axes( 'Parent', gui.AxVbox );
        
        % objects for the plot of FFT
        gui.BxVbox = uiextras.VBox( 'Parent', gui.ViewFFTContainer, ...
                    'Padding', 3, 'Spacing', 3 );
        gui.ViewAxesFFT1 = axes( 'Parent', gui.BxVbox );
        %gui.ViewAxesFFT2 = axes( 'Parent', gui.BxVbox );
        
        
        % Sawtooth function having rpm of motor
        % rpm of our motor
        
        Fs = 10000;
        dt = 1/Fs;
        % period of one round knowing thr rpm of the motor
        T = 60/rpm;
        t = 0:dt:T+dt;

        % Declaration of time for excel saving
        time = t;
        
        % sawtooth in deg that goes from 0 to one period
        x =  180 * sawtooth((rpm/30)*pi*t,1) + 180;
        
        plot(gui.ViewAxes1,t,x)
        gui.ViewAxes1.Title.String = 'Master';
        gui.ViewAxes1.Title.FontWeight = 'normal';

        set(gui.ViewAxes1,'XGrid','on');
        set(gui.ViewAxes1,'YGrid','on');
        
        
        switch(data.SelectedDemo)
            case 1 
                % constraints due to the synchronization between cams
                t0=0; t1=T+dt;

                % pol evaluation (boarder limitations) 
                q0=0; q1=360; v0=3; v1=-10;
                a0 = q0;
                a1 = v0;
                a2 = -(3*q0 - 3*q1 - 2*t0*v0 - t0*v1 + 2*t1*v0 + t1*v1)/(t0 - t1)^2;
                a3 = -(2*q0 - 2*q1 - t0*v0 - t0*v1 + t1*v0 + t1*v1)/((t0 - t1)*(t0^2 - 2*t0*t1 + t1^2));
                p_coeffB = [a3 a2 a1 a0];

                % position
                positionB = polyval(p_coeffB, t);
                plot(gui.ViewAxes2,t, positionB);
                gui.ViewAxes2.Title.String = 'Slave #1';
                gui.ViewAxes2.Title.FontWeight = 'normal';

                set(gui.ViewAxes2,'XGrid','on');
                set(gui.ViewAxes2,'YGrid','on');

                % fourier transform
                Y = fft(positionB,((T+dt)/dt));
                
                Pyy = Y.*conj(Y)/((T+dt)/dt);
                f = 1000/((T+dt)/dt)*(0:20);
                plot(gui.ViewAxesFFT1,f(1:21),Pyy(1:21));
                gui.ViewAxesFFT1.Title.String = 'Power spectral density';
                gui.ViewAxesFFT1.XLabel.String = 'Frequency (Hz)';
                
                set(gui.ViewAxesFFT1,'XGrid','on');
                set(gui.ViewAxesFFT1,'YGrid','on');
                
                % Decalaration of global position for Excel saving
                position = positionB;
                
            case 2 
                % constraints due to the synchronization between cams
                t0=0; t1=T+dt;
                
                % Pol evaluation (boarder limitations)
                q0=0; q1=360; v0=2; v1=0; a0=3; a1=4; j0=2; j1=5;
                a0 = q0;
                a1 = v0;
                a2 = a0/2;
                a3 = j0/6;
                a4 = -(210*q0 - 210*q1 - 120*t0*v0 - 90*t0*v1 + 120*t1*v0 + 90*t1*v1 + 30*a0*t0^2 + 30*a0*t1^2 - 15*a1*t0^2 - 15*a1*t1^2 - 4*j0*t0^3 + 4*j0*t1^3 - j1*t0^3 + j1*t1^3 - 12*j0*t0*t1^2 + 12*j0*t0^2*t1 - 3*j1*t0*t1^2 + 3*j1*t0^2*t1 - 60*a0*t0*t1 + 30*a1*t0*t1)/(6*(t0 - t1)^4);
                a5 = -(168*q0 - 168*q1 - 90*t0*v0 - 78*t0*v1 + 90*t1*v0 + 78*t1*v1 + 20*a0*t0^2 + 20*a0*t1^2 - 14*a1*t0^2 - 14*a1*t1^2 - 2*j0*t0^3 + 2*j0*t1^3 - j1*t0^3 + j1*t1^3 - 6*j0*t0*t1^2 + 6*j0*t0^2*t1 - 3*j1*t0*t1^2 + 3*j1*t0^2*t1 - 40*a0*t0*t1 + 28*a1*t0*t1)/(2*(t0 - t1)^5);
                a6 = -(420*q0 - 420*q1 - 216*t0*v0 - 204*t0*v1 + 216*t1*v0 + 204*t1*v1 + 45*a0*t0^2 + 45*a0*t1^2 - 39*a1*t0^2 - 39*a1*t1^2 - 4*j0*t0^3 + 4*j0*t1^3 - 3*j1*t0^3 + 3*j1*t1^3 - 12*j0*t0*t1^2 + 12*j0*t0^2*t1 - 9*j1*t0*t1^2 + 9*j1*t0^2*t1 - 90*a0*t0*t1 + 78*a1*t0*t1)/(6*(t0 - t1)^6);
                a7 = -(120*q0 - 120*q1 - 60*t0*v0 - 60*t0*v1 + 60*t1*v0 + 60*t1*v1 + 12*a0*t0^2 + 12*a0*t1^2 - 12*a1*t0^2 - 12*a1*t1^2 - j0*t0^3 + j0*t1^3 - j1*t0^3 + j1*t1^3 - 3*j0*t0*t1^2 + 3*j0*t0^2*t1 - 3*j1*t0*t1^2 + 3*j1*t0^2*t1 - 24*a0*t0*t1 + 24*a1*t0*t1)/(6*(t0 - t1)^3*(t0^4 - 4*t0^3*t1 + 6*t0^2*t1^2 - 4*t0*t1^3 + t1^4));
                p_coeffB = [a7 a6 a5 a4 a3 a2 a1 a0];
                
                % position
                positionB = polyval(p_coeffB, t);
                plot(gui.ViewAxes2,t, positionB);
                gui.ViewAxes2.Title.String = 'Slave #1';
                gui.ViewAxes2.Title.FontWeight = 'normal';

                set(gui.ViewAxes2,'XGrid','on');
                set(gui.ViewAxes2,'YGrid','on');
                
                % fourier transform
                Y = fft(positionB,((T+dt)/dt));
                
                Pyy = Y.*conj(Y)/((T+dt)/dt);
                f = 1000/((T+dt)/dt)*(0:20);
                plot(gui.ViewAxesFFT1,f(1:21),Pyy(1:21));
                gui.ViewAxesFFT1.Title.String = 'Power spectral density';
                gui.ViewAxesFFT1.XLabel.String = 'Frequency (Hz)';
                
                set(gui.ViewAxesFFT1,'XGrid','on');
                set(gui.ViewAxesFFT1,'YGrid','on');
                
                % Decalaration of global position for Excel saving
                position = positionB;
                
            case 3 
                % constraints due to the synchronization between cams
                t0=0; t1=T+dt;
                
                % Pol evaluation (boarder limitations)
                q0=0; q1=360; Th=8;
                h = 2*(q1-q0)/(1-cos((pi*(t1-t0))/Th));

                % Trigonometric
                q = h/2* (1-cos((pi*(t-t0))/Th)) + q0;
                plot(gui.ViewAxes2,t, q);
                gui.ViewAxes2.Title.String = 'Slave #1';
                gui.ViewAxes2.Title.FontWeight = 'normal';

                set(gui.ViewAxes2,'XGrid','on');
                set(gui.ViewAxes2,'YGrid','on');
                
                % fourier transform
                Y = fft(q,((T+dt)/dt));
                
                Pyy = Y.*conj(Y)/((T+dt)/dt);
                f = 1000/((T+dt)/dt)*(0:20);
                plot(gui.ViewAxesFFT1,f(1:21),Pyy(1:21));
                gui.ViewAxesFFT1.Title.String = 'Power spectral density';
                gui.ViewAxesFFT1.XLabel.String = 'Frequency (Hz)';
                
                set(gui.ViewAxesFFT1,'XGrid','on');
                set(gui.ViewAxesFFT1,'YGrid','on');
                
                % Decalaration of global position for Excel saving
                position = q;
                                
            case 4
                x = [0 0.05 0.07 T]; 
                y = [0 -90 175 360]; 
                xq1 = 0:.001:T;
                s = spline(x,y,xq1);
                plot(gui.ViewAxes2,xq1,s,'-',x,y,'o');
                gui.ViewAxes2.Title.String = 'Slave #1';
                gui.ViewAxes2.Title.FontWeight = 'normal';

                set(gui.ViewAxes2,'XGrid','on');
                set(gui.ViewAxes2,'YGrid','on');
                
                % fourier transform
                Y = fft(s,((T+dt)/dt));
                
                Pyy = Y.*conj(Y)/((T+dt)/dt);
                f = 1000/((T+dt)/dt)*(0:50);
                plot(gui.ViewAxesFFT1,f(1:51),Pyy(1:51));
                gui.ViewAxesFFT1.Title.String = 'Power spectral density';
                gui.ViewAxesFFT1.XLabel.String = 'Frequency (Hz)';
                
                set(gui.ViewAxesFFT1,'XGrid','on');
                set(gui.ViewAxesFFT1,'YGrid','on');
                
                % Decalaration of global position for Excel saving
                position = s;
                time = xq1;
                
            case 5
                % constraints due to the synchronization between cams
                t0=0; t4=T+dt;
                
                % Pol evaluation (boarder limitations)
                p0=0; p1=200; p2=-100; p3=100; p4=360; t1=0.02; t2=0.06; t3=0.07;
                a0 = -(p4*t0^4*t1^3*t2^2*t3 - p3*t0^4*t1^3*t2^2*t4 - p4*t0^4*t1^3*t2*t3^2 + p3*t0^4*t1^3*t2*t4^2 + p2*t0^4*t1^3*t3^2*t4 - p2*t0^4*t1^3*t3*t4^2 - p4*t0^4*t1^2*t2^3*t3 + p3*t0^4*t1^2*t2^3*t4 + p4*t0^4*t1^2*t2*t3^3 - p3*t0^4*t1^2*t2*t4^3 - p2*t0^4*t1^2*t3^3*t4 + p2*t0^4*t1^2*t3*t4^3 + p4*t0^4*t1*t2^3*t3^2 - p3*t0^4*t1*t2^3*t4^2 - p4*t0^4*t1*t2^2*t3^3 + p3*t0^4*t1*t2^2*t4^3 + p2*t0^4*t1*t3^3*t4^2 - p2*t0^4*t1*t3^2*t4^3 - p1*t0^4*t2^3*t3^2*t4 + p1*t0^4*t2^3*t3*t4^2 + p1*t0^4*t2^2*t3^3*t4 - p1*t0^4*t2^2*t3*t4^3 - p1*t0^4*t2*t3^3*t4^2 + p1*t0^4*t2*t3^2*t4^3 - p4*t0^3*t1^4*t2^2*t3 + p3*t0^3*t1^4*t2^2*t4 + p4*t0^3*t1^4*t2*t3^2 - p3*t0^3*t1^4*t2*t4^2 - p2*t0^3*t1^4*t3^2*t4 + p2*t0^3*t1^4*t3*t4^2 + p4*t0^3*t1^2*t2^4*t3 - p3*t0^3*t1^2*t2^4*t4 - p4*t0^3*t1^2*t2*t3^4 + p3*t0^3*t1^2*t2*t4^4 + p2*t0^3*t1^2*t3^4*t4 - p2*t0^3*t1^2*t3*t4^4 - p4*t0^3*t1*t2^4*t3^2 + p3*t0^3*t1*t2^4*t4^2 + p4*t0^3*t1*t2^2*t3^4 - p3*t0^3*t1*t2^2*t4^4 - p2*t0^3*t1*t3^4*t4^2 + p2*t0^3*t1*t3^2*t4^4 + p1*t0^3*t2^4*t3^2*t4 - p1*t0^3*t2^4*t3*t4^2 - p1*t0^3*t2^2*t3^4*t4 + p1*t0^3*t2^2*t3*t4^4 + p1*t0^3*t2*t3^4*t4^2 - p1*t0^3*t2*t3^2*t4^4 + p4*t0^2*t1^4*t2^3*t3 - p3*t0^2*t1^4*t2^3*t4 - p4*t0^2*t1^4*t2*t3^3 + p3*t0^2*t1^4*t2*t4^3 + p2*t0^2*t1^4*t3^3*t4 - p2*t0^2*t1^4*t3*t4^3 - p4*t0^2*t1^3*t2^4*t3 + p3*t0^2*t1^3*t2^4*t4 + p4*t0^2*t1^3*t2*t3^4 - p3*t0^2*t1^3*t2*t4^4 - p2*t0^2*t1^3*t3^4*t4 + p2*t0^2*t1^3*t3*t4^4 + p4*t0^2*t1*t2^4*t3^3 - p3*t0^2*t1*t2^4*t4^3 - p4*t0^2*t1*t2^3*t3^4 + p3*t0^2*t1*t2^3*t4^4 + p2*t0^2*t1*t3^4*t4^3 - p2*t0^2*t1*t3^3*t4^4 - p1*t0^2*t2^4*t3^3*t4 + p1*t0^2*t2^4*t3*t4^3 + p1*t0^2*t2^3*t3^4*t4 - p1*t0^2*t2^3*t3*t4^4 - p1*t0^2*t2*t3^4*t4^3 + p1*t0^2*t2*t3^3*t4^4 - p4*t0*t1^4*t2^3*t3^2 + p3*t0*t1^4*t2^3*t4^2 + p4*t0*t1^4*t2^2*t3^3 - p3*t0*t1^4*t2^2*t4^3 - p2*t0*t1^4*t3^3*t4^2 + p2*t0*t1^4*t3^2*t4^3 + p4*t0*t1^3*t2^4*t3^2 - p3*t0*t1^3*t2^4*t4^2 - p4*t0*t1^3*t2^2*t3^4 + p3*t0*t1^3*t2^2*t4^4 + p2*t0*t1^3*t3^4*t4^2 - p2*t0*t1^3*t3^2*t4^4 - p4*t0*t1^2*t2^4*t3^3 + p3*t0*t1^2*t2^4*t4^3 + p4*t0*t1^2*t2^3*t3^4 - p3*t0*t1^2*t2^3*t4^4 - p2*t0*t1^2*t3^4*t4^3 + p2*t0*t1^2*t3^3*t4^4 + p1*t0*t2^4*t3^3*t4^2 - p1*t0*t2^4*t3^2*t4^3 - p1*t0*t2^3*t3^4*t4^2 + p1*t0*t2^3*t3^2*t4^4 + p1*t0*t2^2*t3^4*t4^3 - p1*t0*t2^2*t3^3*t4^4 + p0*t1^4*t2^3*t3^2*t4 - p0*t1^4*t2^3*t3*t4^2 - p0*t1^4*t2^2*t3^3*t4 + p0*t1^4*t2^2*t3*t4^3 + p0*t1^4*t2*t3^3*t4^2 - p0*t1^4*t2*t3^2*t4^3 - p0*t1^3*t2^4*t3^2*t4 + p0*t1^3*t2^4*t3*t4^2 + p0*t1^3*t2^2*t3^4*t4 - p0*t1^3*t2^2*t3*t4^4 - p0*t1^3*t2*t3^4*t4^2 + p0*t1^3*t2*t3^2*t4^4 + p0*t1^2*t2^4*t3^3*t4 - p0*t1^2*t2^4*t3*t4^3 - p0*t1^2*t2^3*t3^4*t4 + p0*t1^2*t2^3*t3*t4^4 + p0*t1^2*t2*t3^4*t4^3 - p0*t1^2*t2*t3^3*t4^4 - p0*t1*t2^4*t3^3*t4^2 + p0*t1*t2^4*t3^2*t4^3 + p0*t1*t2^3*t3^4*t4^2 - p0*t1*t2^3*t3^2*t4^4 - p0*t1*t2^2*t3^4*t4^3 + p0*t1*t2^2*t3^3*t4^4)/((t0 - t1)*(t0*t1 - t0*t2 - t1*t2 + t2^2)*(t0*t3^2 + t1*t3^2 + t2*t3^2 - t3^3 + t0*t1*t2 - t0*t1*t3 - t0*t2*t3 - t1*t2*t3)*(t0*t4^3 + t1*t4^3 + t2*t4^3 + t3*t4^3 - t4^4 - t0*t1*t4^2 - t0*t2*t4^2 - t0*t3*t4^2 - t1*t2*t4^2 - t1*t3*t4^2 - t2*t3*t4^2 - t0*t1*t2*t3 + t0*t1*t2*t4 + t0*t1*t3*t4 + t0*t2*t3*t4 + t1*t2*t3*t4));
                a1 = -(p0*t1^2*t2^3*t3^4 - p0*t1^2*t2^4*t3^3 - p0*t1^3*t2^2*t3^4 + p0*t1^3*t2^4*t3^2 + p0*t1^4*t2^2*t3^3 - p0*t1^4*t2^3*t3^2 - p1*t0^2*t2^3*t3^4 + p1*t0^2*t2^4*t3^3 + p1*t0^3*t2^2*t3^4 - p1*t0^3*t2^4*t3^2 - p1*t0^4*t2^2*t3^3 + p1*t0^4*t2^3*t3^2 + p2*t0^2*t1^3*t3^4 - p2*t0^2*t1^4*t3^3 - p2*t0^3*t1^2*t3^4 + p2*t0^3*t1^4*t3^2 + p2*t0^4*t1^2*t3^3 - p2*t0^4*t1^3*t3^2 - p3*t0^2*t1^3*t2^4 + p3*t0^2*t1^4*t2^3 + p3*t0^3*t1^2*t2^4 - p3*t0^3*t1^4*t2^2 - p3*t0^4*t1^2*t2^3 + p3*t0^4*t1^3*t2^2 - p0*t1^2*t2^3*t4^4 + p0*t1^2*t2^4*t4^3 + p0*t1^3*t2^2*t4^4 - p0*t1^3*t2^4*t4^2 - p0*t1^4*t2^2*t4^3 + p0*t1^4*t2^3*t4^2 + p1*t0^2*t2^3*t4^4 - p1*t0^2*t2^4*t4^3 - p1*t0^3*t2^2*t4^4 + p1*t0^3*t2^4*t4^2 + p1*t0^4*t2^2*t4^3 - p1*t0^4*t2^3*t4^2 - p2*t0^2*t1^3*t4^4 + p2*t0^2*t1^4*t4^3 + p2*t0^3*t1^2*t4^4 - p2*t0^3*t1^4*t4^2 - p2*t0^4*t1^2*t4^3 + p2*t0^4*t1^3*t4^2 + p4*t0^2*t1^3*t2^4 - p4*t0^2*t1^4*t2^3 - p4*t0^3*t1^2*t2^4 + p4*t0^3*t1^4*t2^2 + p4*t0^4*t1^2*t2^3 - p4*t0^4*t1^3*t2^2 + p0*t1^2*t3^3*t4^4 - p0*t1^2*t3^4*t4^3 - p0*t1^3*t3^2*t4^4 + p0*t1^3*t3^4*t4^2 + p0*t1^4*t3^2*t4^3 - p0*t1^4*t3^3*t4^2 - p1*t0^2*t3^3*t4^4 + p1*t0^2*t3^4*t4^3 + p1*t0^3*t3^2*t4^4 - p1*t0^3*t3^4*t4^2 - p1*t0^4*t3^2*t4^3 + p1*t0^4*t3^3*t4^2 + p3*t0^2*t1^3*t4^4 - p3*t0^2*t1^4*t4^3 - p3*t0^3*t1^2*t4^4 + p3*t0^3*t1^4*t4^2 + p3*t0^4*t1^2*t4^3 - p3*t0^4*t1^3*t4^2 - p4*t0^2*t1^3*t3^4 + p4*t0^2*t1^4*t3^3 + p4*t0^3*t1^2*t3^4 - p4*t0^3*t1^4*t3^2 - p4*t0^4*t1^2*t3^3 + p4*t0^4*t1^3*t3^2 - p0*t2^2*t3^3*t4^4 + p0*t2^2*t3^4*t4^3 + p0*t2^3*t3^2*t4^4 - p0*t2^3*t3^4*t4^2 - p0*t2^4*t3^2*t4^3 + p0*t2^4*t3^3*t4^2 + p2*t0^2*t3^3*t4^4 - p2*t0^2*t3^4*t4^3 - p2*t0^3*t3^2*t4^4 + p2*t0^3*t3^4*t4^2 + p2*t0^4*t3^2*t4^3 - p2*t0^4*t3^3*t4^2 - p3*t0^2*t2^3*t4^4 + p3*t0^2*t2^4*t4^3 + p3*t0^3*t2^2*t4^4 - p3*t0^3*t2^4*t4^2 - p3*t0^4*t2^2*t4^3 + p3*t0^4*t2^3*t4^2 + p4*t0^2*t2^3*t3^4 - p4*t0^2*t2^4*t3^3 - p4*t0^3*t2^2*t3^4 + p4*t0^3*t2^4*t3^2 + p4*t0^4*t2^2*t3^3 - p4*t0^4*t2^3*t3^2 + p1*t2^2*t3^3*t4^4 - p1*t2^2*t3^4*t4^3 - p1*t2^3*t3^2*t4^4 + p1*t2^3*t3^4*t4^2 + p1*t2^4*t3^2*t4^3 - p1*t2^4*t3^3*t4^2 - p2*t1^2*t3^3*t4^4 + p2*t1^2*t3^4*t4^3 + p2*t1^3*t3^2*t4^4 - p2*t1^3*t3^4*t4^2 - p2*t1^4*t3^2*t4^3 + p2*t1^4*t3^3*t4^2 + p3*t1^2*t2^3*t4^4 - p3*t1^2*t2^4*t4^3 - p3*t1^3*t2^2*t4^4 + p3*t1^3*t2^4*t4^2 + p3*t1^4*t2^2*t4^3 - p3*t1^4*t2^3*t4^2 - p4*t1^2*t2^3*t3^4 + p4*t1^2*t2^4*t3^3 + p4*t1^3*t2^2*t3^4 - p4*t1^3*t2^4*t3^2 - p4*t1^4*t2^2*t3^3 + p4*t1^4*t2^3*t3^2)/((t0 - t1)*(t0*t1 - t0*t2 - t1*t2 + t2^2)*(t0*t3^2 + t1*t3^2 + t2*t3^2 - t3^3 + t0*t1*t2 - t0*t1*t3 - t0*t2*t3 - t1*t2*t3)*(t0*t4^3 + t1*t4^3 + t2*t4^3 + t3*t4^3 - t4^4 - t0*t1*t4^2 - t0*t2*t4^2 - t0*t3*t4^2 - t1*t2*t4^2 - t1*t3*t4^2 - t2*t3*t4^2 - t0*t1*t2*t3 + t0*t1*t2*t4 + t0*t1*t3*t4 + t0*t2*t3*t4 + t1*t2*t3*t4));
                a2 = (p0*t1*t2^3*t3^4 - p0*t1*t2^4*t3^3 - p0*t1^3*t2*t3^4 + p0*t1^3*t2^4*t3 + p0*t1^4*t2*t3^3 - p0*t1^4*t2^3*t3 - p1*t0*t2^3*t3^4 + p1*t0*t2^4*t3^3 + p1*t0^3*t2*t3^4 - p1*t0^3*t2^4*t3 - p1*t0^4*t2*t3^3 + p1*t0^4*t2^3*t3 + p2*t0*t1^3*t3^4 - p2*t0*t1^4*t3^3 - p2*t0^3*t1*t3^4 + p2*t0^3*t1^4*t3 + p2*t0^4*t1*t3^3 - p2*t0^4*t1^3*t3 - p3*t0*t1^3*t2^4 + p3*t0*t1^4*t2^3 + p3*t0^3*t1*t2^4 - p3*t0^3*t1^4*t2 - p3*t0^4*t1*t2^3 + p3*t0^4*t1^3*t2 - p0*t1*t2^3*t4^4 + p0*t1*t2^4*t4^3 + p0*t1^3*t2*t4^4 - p0*t1^3*t2^4*t4 - p0*t1^4*t2*t4^3 + p0*t1^4*t2^3*t4 + p1*t0*t2^3*t4^4 - p1*t0*t2^4*t4^3 - p1*t0^3*t2*t4^4 + p1*t0^3*t2^4*t4 + p1*t0^4*t2*t4^3 - p1*t0^4*t2^3*t4 - p2*t0*t1^3*t4^4 + p2*t0*t1^4*t4^3 + p2*t0^3*t1*t4^4 - p2*t0^3*t1^4*t4 - p2*t0^4*t1*t4^3 + p2*t0^4*t1^3*t4 + p4*t0*t1^3*t2^4 - p4*t0*t1^4*t2^3 - p4*t0^3*t1*t2^4 + p4*t0^3*t1^4*t2 + p4*t0^4*t1*t2^3 - p4*t0^4*t1^3*t2 + p0*t1*t3^3*t4^4 - p0*t1*t3^4*t4^3 - p0*t1^3*t3*t4^4 + p0*t1^3*t3^4*t4 + p0*t1^4*t3*t4^3 - p0*t1^4*t3^3*t4 - p1*t0*t3^3*t4^4 + p1*t0*t3^4*t4^3 + p1*t0^3*t3*t4^4 - p1*t0^3*t3^4*t4 - p1*t0^4*t3*t4^3 + p1*t0^4*t3^3*t4 + p3*t0*t1^3*t4^4 - p3*t0*t1^4*t4^3 - p3*t0^3*t1*t4^4 + p3*t0^3*t1^4*t4 + p3*t0^4*t1*t4^3 - p3*t0^4*t1^3*t4 - p4*t0*t1^3*t3^4 + p4*t0*t1^4*t3^3 + p4*t0^3*t1*t3^4 - p4*t0^3*t1^4*t3 - p4*t0^4*t1*t3^3 + p4*t0^4*t1^3*t3 - p0*t2*t3^3*t4^4 + p0*t2*t3^4*t4^3 + p0*t2^3*t3*t4^4 - p0*t2^3*t3^4*t4 - p0*t2^4*t3*t4^3 + p0*t2^4*t3^3*t4 + p2*t0*t3^3*t4^4 - p2*t0*t3^4*t4^3 - p2*t0^3*t3*t4^4 + p2*t0^3*t3^4*t4 + p2*t0^4*t3*t4^3 - p2*t0^4*t3^3*t4 - p3*t0*t2^3*t4^4 + p3*t0*t2^4*t4^3 + p3*t0^3*t2*t4^4 - p3*t0^3*t2^4*t4 - p3*t0^4*t2*t4^3 + p3*t0^4*t2^3*t4 + p4*t0*t2^3*t3^4 - p4*t0*t2^4*t3^3 - p4*t0^3*t2*t3^4 + p4*t0^3*t2^4*t3 + p4*t0^4*t2*t3^3 - p4*t0^4*t2^3*t3 + p1*t2*t3^3*t4^4 - p1*t2*t3^4*t4^3 - p1*t2^3*t3*t4^4 + p1*t2^3*t3^4*t4 + p1*t2^4*t3*t4^3 - p1*t2^4*t3^3*t4 - p2*t1*t3^3*t4^4 + p2*t1*t3^4*t4^3 + p2*t1^3*t3*t4^4 - p2*t1^3*t3^4*t4 - p2*t1^4*t3*t4^3 + p2*t1^4*t3^3*t4 + p3*t1*t2^3*t4^4 - p3*t1*t2^4*t4^3 - p3*t1^3*t2*t4^4 + p3*t1^3*t2^4*t4 + p3*t1^4*t2*t4^3 - p3*t1^4*t2^3*t4 - p4*t1*t2^3*t3^4 + p4*t1*t2^4*t3^3 + p4*t1^3*t2*t3^4 - p4*t1^3*t2^4*t3 - p4*t1^4*t2*t3^3 + p4*t1^4*t2^3*t3)/((t0 - t1)*(t0*t1 - t0*t2 - t1*t2 + t2^2)*(t0*t3^2 + t1*t3^2 + t2*t3^2 - t3^3 + t0*t1*t2 - t0*t1*t3 - t0*t2*t3 - t1*t2*t3)*(t0*t4^3 + t1*t4^3 + t2*t4^3 + t3*t4^3 - t4^4 - t0*t1*t4^2 - t0*t2*t4^2 - t0*t3*t4^2 - t1*t2*t4^2 - t1*t3*t4^2 - t2*t3*t4^2 - t0*t1*t2*t3 + t0*t1*t2*t4 + t0*t1*t3*t4 + t0*t2*t3*t4 + t1*t2*t3*t4));
                a3 = -(p0*t1*t2^2*t3^4 - p0*t1*t2^4*t3^2 - p0*t1^2*t2*t3^4 + p0*t1^2*t2^4*t3 + p0*t1^4*t2*t3^2 - p0*t1^4*t2^2*t3 - p1*t0*t2^2*t3^4 + p1*t0*t2^4*t3^2 + p1*t0^2*t2*t3^4 - p1*t0^2*t2^4*t3 - p1*t0^4*t2*t3^2 + p1*t0^4*t2^2*t3 + p2*t0*t1^2*t3^4 - p2*t0*t1^4*t3^2 - p2*t0^2*t1*t3^4 + p2*t0^2*t1^4*t3 + p2*t0^4*t1*t3^2 - p2*t0^4*t1^2*t3 - p3*t0*t1^2*t2^4 + p3*t0*t1^4*t2^2 + p3*t0^2*t1*t2^4 - p3*t0^2*t1^4*t2 - p3*t0^4*t1*t2^2 + p3*t0^4*t1^2*t2 - p0*t1*t2^2*t4^4 + p0*t1*t2^4*t4^2 + p0*t1^2*t2*t4^4 - p0*t1^2*t2^4*t4 - p0*t1^4*t2*t4^2 + p0*t1^4*t2^2*t4 + p1*t0*t2^2*t4^4 - p1*t0*t2^4*t4^2 - p1*t0^2*t2*t4^4 + p1*t0^2*t2^4*t4 + p1*t0^4*t2*t4^2 - p1*t0^4*t2^2*t4 - p2*t0*t1^2*t4^4 + p2*t0*t1^4*t4^2 + p2*t0^2*t1*t4^4 - p2*t0^2*t1^4*t4 - p2*t0^4*t1*t4^2 + p2*t0^4*t1^2*t4 + p4*t0*t1^2*t2^4 - p4*t0*t1^4*t2^2 - p4*t0^2*t1*t2^4 + p4*t0^2*t1^4*t2 + p4*t0^4*t1*t2^2 - p4*t0^4*t1^2*t2 + p0*t1*t3^2*t4^4 - p0*t1*t3^4*t4^2 - p0*t1^2*t3*t4^4 + p0*t1^2*t3^4*t4 + p0*t1^4*t3*t4^2 - p0*t1^4*t3^2*t4 - p1*t0*t3^2*t4^4 + p1*t0*t3^4*t4^2 + p1*t0^2*t3*t4^4 - p1*t0^2*t3^4*t4 - p1*t0^4*t3*t4^2 + p1*t0^4*t3^2*t4 + p3*t0*t1^2*t4^4 - p3*t0*t1^4*t4^2 - p3*t0^2*t1*t4^4 + p3*t0^2*t1^4*t4 + p3*t0^4*t1*t4^2 - p3*t0^4*t1^2*t4 - p4*t0*t1^2*t3^4 + p4*t0*t1^4*t3^2 + p4*t0^2*t1*t3^4 - p4*t0^2*t1^4*t3 - p4*t0^4*t1*t3^2 + p4*t0^4*t1^2*t3 - p0*t2*t3^2*t4^4 + p0*t2*t3^4*t4^2 + p0*t2^2*t3*t4^4 - p0*t2^2*t3^4*t4 - p0*t2^4*t3*t4^2 + p0*t2^4*t3^2*t4 + p2*t0*t3^2*t4^4 - p2*t0*t3^4*t4^2 - p2*t0^2*t3*t4^4 + p2*t0^2*t3^4*t4 + p2*t0^4*t3*t4^2 - p2*t0^4*t3^2*t4 - p3*t0*t2^2*t4^4 + p3*t0*t2^4*t4^2 + p3*t0^2*t2*t4^4 - p3*t0^2*t2^4*t4 - p3*t0^4*t2*t4^2 + p3*t0^4*t2^2*t4 + p4*t0*t2^2*t3^4 - p4*t0*t2^4*t3^2 - p4*t0^2*t2*t3^4 + p4*t0^2*t2^4*t3 + p4*t0^4*t2*t3^2 - p4*t0^4*t2^2*t3 + p1*t2*t3^2*t4^4 - p1*t2*t3^4*t4^2 - p1*t2^2*t3*t4^4 + p1*t2^2*t3^4*t4 + p1*t2^4*t3*t4^2 - p1*t2^4*t3^2*t4 - p2*t1*t3^2*t4^4 + p2*t1*t3^4*t4^2 + p2*t1^2*t3*t4^4 - p2*t1^2*t3^4*t4 - p2*t1^4*t3*t4^2 + p2*t1^4*t3^2*t4 + p3*t1*t2^2*t4^4 - p3*t1*t2^4*t4^2 - p3*t1^2*t2*t4^4 + p3*t1^2*t2^4*t4 + p3*t1^4*t2*t4^2 - p3*t1^4*t2^2*t4 - p4*t1*t2^2*t3^4 + p4*t1*t2^4*t3^2 + p4*t1^2*t2*t3^4 - p4*t1^2*t2^4*t3 - p4*t1^4*t2*t3^2 + p4*t1^4*t2^2*t3)/((t0 - t1)*(t0*t1 - t0*t2 - t1*t2 + t2^2)*(t0*t3^2 + t1*t3^2 + t2*t3^2 - t3^3 + t0*t1*t2 - t0*t1*t3 - t0*t2*t3 - t1*t2*t3)*(t0*t4^3 + t1*t4^3 + t2*t4^3 + t3*t4^3 - t4^4 - t0*t1*t4^2 - t0*t2*t4^2 - t0*t3*t4^2 - t1*t2*t4^2 - t1*t3*t4^2 - t2*t3*t4^2 - t0*t1*t2*t3 + t0*t1*t2*t4 + t0*t1*t3*t4 + t0*t2*t3*t4 + t1*t2*t3*t4));
                a4 = (p0*t1*t2^2*t3^3 - p0*t1*t2^3*t3^2 - p0*t1^2*t2*t3^3 + p0*t1^2*t2^3*t3 + p0*t1^3*t2*t3^2 - p0*t1^3*t2^2*t3 - p1*t0*t2^2*t3^3 + p1*t0*t2^3*t3^2 + p1*t0^2*t2*t3^3 - p1*t0^2*t2^3*t3 - p1*t0^3*t2*t3^2 + p1*t0^3*t2^2*t3 + p2*t0*t1^2*t3^3 - p2*t0*t1^3*t3^2 - p2*t0^2*t1*t3^3 + p2*t0^2*t1^3*t3 + p2*t0^3*t1*t3^2 - p2*t0^3*t1^2*t3 - p3*t0*t1^2*t2^3 + p3*t0*t1^3*t2^2 + p3*t0^2*t1*t2^3 - p3*t0^2*t1^3*t2 - p3*t0^3*t1*t2^2 + p3*t0^3*t1^2*t2 - p0*t1*t2^2*t4^3 + p0*t1*t2^3*t4^2 + p0*t1^2*t2*t4^3 - p0*t1^2*t2^3*t4 - p0*t1^3*t2*t4^2 + p0*t1^3*t2^2*t4 + p1*t0*t2^2*t4^3 - p1*t0*t2^3*t4^2 - p1*t0^2*t2*t4^3 + p1*t0^2*t2^3*t4 + p1*t0^3*t2*t4^2 - p1*t0^3*t2^2*t4 - p2*t0*t1^2*t4^3 + p2*t0*t1^3*t4^2 + p2*t0^2*t1*t4^3 - p2*t0^2*t1^3*t4 - p2*t0^3*t1*t4^2 + p2*t0^3*t1^2*t4 + p4*t0*t1^2*t2^3 - p4*t0*t1^3*t2^2 - p4*t0^2*t1*t2^3 + p4*t0^2*t1^3*t2 + p4*t0^3*t1*t2^2 - p4*t0^3*t1^2*t2 + p0*t1*t3^2*t4^3 - p0*t1*t3^3*t4^2 - p0*t1^2*t3*t4^3 + p0*t1^2*t3^3*t4 + p0*t1^3*t3*t4^2 - p0*t1^3*t3^2*t4 - p1*t0*t3^2*t4^3 + p1*t0*t3^3*t4^2 + p1*t0^2*t3*t4^3 - p1*t0^2*t3^3*t4 - p1*t0^3*t3*t4^2 + p1*t0^3*t3^2*t4 + p3*t0*t1^2*t4^3 - p3*t0*t1^3*t4^2 - p3*t0^2*t1*t4^3 + p3*t0^2*t1^3*t4 + p3*t0^3*t1*t4^2 - p3*t0^3*t1^2*t4 - p4*t0*t1^2*t3^3 + p4*t0*t1^3*t3^2 + p4*t0^2*t1*t3^3 - p4*t0^2*t1^3*t3 - p4*t0^3*t1*t3^2 + p4*t0^3*t1^2*t3 - p0*t2*t3^2*t4^3 + p0*t2*t3^3*t4^2 + p0*t2^2*t3*t4^3 - p0*t2^2*t3^3*t4 - p0*t2^3*t3*t4^2 + p0*t2^3*t3^2*t4 + p2*t0*t3^2*t4^3 - p2*t0*t3^3*t4^2 - p2*t0^2*t3*t4^3 + p2*t0^2*t3^3*t4 + p2*t0^3*t3*t4^2 - p2*t0^3*t3^2*t4 - p3*t0*t2^2*t4^3 + p3*t0*t2^3*t4^2 + p3*t0^2*t2*t4^3 - p3*t0^2*t2^3*t4 - p3*t0^3*t2*t4^2 + p3*t0^3*t2^2*t4 + p4*t0*t2^2*t3^3 - p4*t0*t2^3*t3^2 - p4*t0^2*t2*t3^3 + p4*t0^2*t2^3*t3 + p4*t0^3*t2*t3^2 - p4*t0^3*t2^2*t3 + p1*t2*t3^2*t4^3 - p1*t2*t3^3*t4^2 - p1*t2^2*t3*t4^3 + p1*t2^2*t3^3*t4 + p1*t2^3*t3*t4^2 - p1*t2^3*t3^2*t4 - p2*t1*t3^2*t4^3 + p2*t1*t3^3*t4^2 + p2*t1^2*t3*t4^3 - p2*t1^2*t3^3*t4 - p2*t1^3*t3*t4^2 + p2*t1^3*t3^2*t4 + p3*t1*t2^2*t4^3 - p3*t1*t2^3*t4^2 - p3*t1^2*t2*t4^3 + p3*t1^2*t2^3*t4 + p3*t1^3*t2*t4^2 - p3*t1^3*t2^2*t4 - p4*t1*t2^2*t3^3 + p4*t1*t2^3*t3^2 + p4*t1^2*t2*t3^3 - p4*t1^2*t2^3*t3 - p4*t1^3*t2*t3^2 + p4*t1^3*t2^2*t3)/((t0 - t1)*(t0*t1 - t0*t2 - t1*t2 + t2^2)*(t0*t3^2 + t1*t3^2 + t2*t3^2 - t3^3 + t0*t1*t2 - t0*t1*t3 - t0*t2*t3 - t1*t2*t3)*(t0*t4^3 + t1*t4^3 + t2*t4^3 + t3*t4^3 - t4^4 - t0*t1*t4^2 - t0*t2*t4^2 - t0*t3*t4^2 - t1*t2*t4^2 - t1*t3*t4^2 - t2*t3*t4^2 - t0*t1*t2*t3 + t0*t1*t2*t4 + t0*t1*t3*t4 + t0*t2*t3*t4 + t1*t2*t3*t4));
                p_coeffB = [a4 a3 a2 a1 a0];
                
                % position
                positionB = polyval(p_coeffB, t);
                plot(gui.ViewAxes2,t, positionB);
                gui.ViewAxes2.Title.String = 'Slave #1';
                gui.ViewAxes2.Title.FontWeight = 'normal';

                set(gui.ViewAxes2,'XGrid','on');
                set(gui.ViewAxes2,'YGrid','on');
                
                % fourier transform
                Y = fft(positionB,((T+dt)/dt));
                
                Pyy = Y.*conj(Y)/((T+dt)/dt);
                f = 1000/((T+dt)/dt)*(0:20);
                plot(gui.ViewAxesFFT1,f(1:21),Pyy(1:21));
                gui.ViewAxesFFT1.Title.String = 'Power spectral density';
                gui.ViewAxesFFT1.XLabel.String = 'Frequency (Hz)';
                
                set(gui.ViewAxesFFT1,'XGrid','on');
                set(gui.ViewAxesFFT1,'YGrid','on');
                
                % Decalaration of global position for Excel saving
                position = positionB;

            otherwise
                fprintf('--WRONG--\n' );
        end
  
    end % redrawDemo


% Callback subfunctions
%-------------------------------------------------------------------------%
    function onListSelection( src, ~ )
        % User selected a demo from the list - update "data" and refresh
        data.SelectedDemo = get( src, 'Value' );
    end % onListSelection

%-------------------------------------------------------------------------%
    function onMenuSelection( src, ~ )
        % User selected a demo from the menu - work out which one
        demoName = get( src, 'Label' );
        data.SelectedDemo = find( strcmpi( demoName, data.DemoNames ), 1, 'first' );
        updateInterface();
        redrawDemo();
    end % onMenuSelection


%-------------------------------------------------------------------------%
    function onHelp( ~, ~ )
        % User has asked for the documentation
        doc layout
    end % onHelp

%-------------------------------------------------------------------------%
    function onGenerate( ~, ~ )
        % User wants the generation
        updateInterface();
        redrawDemo();
    end % onGenerate

%-------------------------------------------------------------------------%
    function onExcel( ~, ~ )        
        % User wants the saving of positions into an Excel file
        filename = 'Trajectory_POSITION.xlsx';
        sheet = 1;
        xlswrite(filename,position,sheet,'A1')
        xlswrite(filename,time,sheet,'A2')
    end % onExcel

%-------------------------------------------------------------------------%
    function onEdit( src, ~ )
        % User wants to put number of RPM
        val = get(src, 'String');
        rpm = str2double(val);        
    end % onEdit

%-------------------------------------------------------------------------%
    function onExit( ~, ~ )
        % User wants to quit out of the application
        delete( gui.Window );
    end % onExit

end % EOF

function varargout = metagui(varargin)
% METAGUI MATLAB code for metagui.fig
%      METAGUI, by itself, creates a new METAGUI or raises the existing
%      singleton*.
%
%      H = METAGUI returns the handle to a new METAGUI or the handle to
%      the existing singleton*.
%
%      METAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in METAGUI.M with the given input arguments.
%
%      METAGUI('Property','Value',...) creates a new METAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before metagui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to metagui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help metagui

% Last Modified by GUIDE v2.5 27-May-2019 16:11:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @metagui_OpeningFcn, ...
                   'gui_OutputFcn',  @metagui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before metagui is made visible.
function metagui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to metagui (see VARARGIN)

% Choose default command line output for metagui
handles.output = hObject;
%arduino com port
port = 'COM11'
s = serial(port);
fopen(s);
disp("successful connection estd.")
%set comm parameters
s.BaudRate = 9600;
s.DataBits = 8;
s.Parity = 'none';
s.StopBits = 1;
s.Terminator = 'CR';
s.flowcontrol = 'none';
handles.s = s

%NEW FOCUS p.g. COM PORT: PASSED AS VARARGIN
handles.ser = varargin{1}

set(handles.freedom1,'String',varargin{2})
set(handles.freedom2,'String',varargin{2})

handles.signal = []
handles.time = []
% Update handles structure
guidata(hObject, handles);
set(get(handles.axes1,'xlabel'),'string','Time, s')
set(get(handles.axes1,'ylabel'),'string','Signal, mV')


% UIWAIT makes metagui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = metagui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sample.
function sample_Callback(hObject, eventdata, handles)
% hObject    handle to sample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp(handles.time);
[time,signal]=getdata(hObject,handles);
cla(handles.axes1)
plot(handles.axes1,time,signal)
xlabel(handles.axes1,'Time, s');
ylabel(handles.axes1,'Signal, mV');

function [time,signal]=getdata(hObject,handles)
boxcar = 1;
signal = repelem(readValue(handles),boxcar);
time = [];
avsig = [];
tic
while toc<1000
    pause(0.1)
    signal=[signal,readValue(handles)];
    avsig = [avsig,mean(signal((length(signal)-boxcar):length(signal)))];
    time = [time,toc];
    cla(handles.axes1)
    plot(handles.axes1,time,avsig)
    %plot(handles.axes1,time,signal(3:end))
    title(handles.axes1,'Signal vs. Time')
    xlabel(handles.axes1,'Time, s');
    ylabel(handles.axes1,'Signal, mV');
end

% --- Executes on button press in optimize.
function optimize_Callback(hObject, eventdata, handles)
%The freedom(1,2) get methods return the values of the picomotors which are currently selected in
%the listboxes freedom1 and freedom2. It is an array of numbers, that
%correspond to the index of the selected values (1 is first element of the
%listbox, etc...
deg1 = get(handles.freedom1,'Value');
deg2 = get(handles.freedom2,'Value');
%prepare an array to contain the string form of the picomotrs, in the "123"
%format where 1:slot 1, 2:connector 2, and 3:picomotor 3
mot1 = ["" ""];
mot2 = ["" ""];
if (length(deg1)==2 && length(deg2)==2)
    for i = [1 2]
        %sorry this looks confusing! It is just converting from the number
        %returned from freedom 2, which will be from 1 to 48 (48 total
        %picomotors), to the '123' format mentioned above. Would be nicer
        %to look at, but I can't just use mod since I want picomotor 3
        %mapped to 3, not zero (as happens with modular arithemtic)
        conn1 = ceil(deg1(i)/3);
        conn2 = ceil(deg2(i)/3);
        mot1(i) = strcat(num2str(ceil(conn1/4)),num2str(conn1-floor((conn1-1)/4)*4),num2str(deg1(i)-floor((deg1(i)-1)/3)*3));
        mot2(i) = strcat(num2str(ceil(ceil(deg2(i)/3)/4)),num2str(conn2-floor((conn2-1)/4)*4),num2str(deg2(i)-floor((deg2(i)-1)/3)*3));
    end
    %now we have the motors for optimization, it is time to start
    %optimizing!!!
    %as an arbitrary convention, let us use a CW rotation for positive 'x',
    %where x is the picomotor position, the independent variable and y is
    %the signal from the arduino, or y, which is what we are tying to
    %maximize using a process called gradient descent (technically
    %ascending here though).
    title(handles.axes3,'Optimized Signal vs. Time');
    xlabel(handles.axes3,'Time, s');
    ylabel(handles.axes3,'Signal, mV');
    time = [];
    signal = [];
    pausetime = 0.2; 
    boxcar = 10;
    delta = 25;
    alpha = 350;
    grad = 50;
    tic
    y_0 = boxcarValue(handles,boxcar);
    time = [toc];
    signal = [y_0];
    y_1 = 0;
    %keep optimizing until the slope(gradient) is small, corresponding to a
    %local maximum
    while(abs(grad) > 0.005)
        %move in the direction of the gradient. The first step is always
        %arbitrarily positive (CW) 50
        if(delta>0)
            channelpulse(handles.ser,mot1(2),delta,"CW");
        else
            channelpulse(handles.ser,mot1(2),abs(delta),"CCW");
        end
        pause(pausetime)
        %find new y value and calculate gradient. Use the gradient to
        %specify the next step size;
        %the arguments are:the motor,how many values to boxcar average,the
        %initial step size,the alpha (important: usually this represents
        %how 'coarse and quick' the gradient descent is: smaller alpha
        %means smaller but more precise steps. However, I have found that
        %due to the measurement error of the arduino, smaller alphas can
        %actually be less consistent; better have larger),initial
        %gradient(doesn't change anything, just to make sure loop doesn't
        %cancel),and the gradient requirement; must be below a certain
        %value (closeness to local max) to pass
        y_1 = optimize(handles,mot1(1),13,50,300,50,0.035);
        time = [time,toc];
        signal = [signal,y_1];
        plot(handles.axes3,time,signal);
        title(handles.axes3,'Signal vs. Time');
        xlabel(handles.axes3,'Time, s');
        ylabel(handles.axes3,'Signal, mV');
        grad = (y_1-y_0)/delta;
        fprintf("delta is : %f",delta);
        fprintf("gradient is: %f",grad);
        delta = grad*alpha;
        fprintf("new delta is: %f",delta);
        %make this y_1 the new old y:
        y_0 = y_1
    end
    
else
    disp("Both selections must have exactly two degrees of freedom selected")
end
    

function optval = optimize(handles,motor,boxcar,delta,alpha,grad,tolerance)
cla(handles.axes2)
title(handles.axes2,'Signal vs. Time');
xlabel(handles.axes2,'Time, s');
ylabel(handles.axes2,'Signal, mV');
time = [];
signal = [];
pausetime = 0.2; 
%use this tic if not made in the overarching loop
%tic
y_0 = boxcarValue(handles,boxcar);
time = [toc];
signal = [y_0];
y_1 = 0;
%keep optimizing until the slope(gradient) is small, corresponding to a
%local maximum
while(abs(grad) > tolerance)
    %move in the direction of the gradient. The first step is always
    %arbitrarily positive (CW) 50
    if(delta>0)
        channelpulse(handles.ser,motor,delta,"CW");
    else
        channelpulse(handles.ser,motor,abs(delta),"CCW");
    end
    pause(pausetime)
    %find new y value and calculate gradient. Use the gradient to
    %specify the next step size;
    y_1 = boxcarValue(handles,boxcar);
    time = [time,toc];
    signal = [signal,y_1];
    plot(handles.axes2,time,signal);
    title(handles.axes2,'Signal vs. Time');
    xlabel(handles.axes2,'Time, s');
    ylabel(handles.axes2,'Signal, mV');
    grad = (y_1-y_0)/delta;
    %fprintf("delta is : %f",delta);
    %fprintf("gradient is: %f",grad);
    delta = grad*alpha;
    %fprintf("new delta is: %f",delta);
    %make this y_1 the new old y:
    y_0 = y_1;
end
fprintf("Optimal value: %f",y_1);
disp("DONE SUBOPT")
optval = y_1;


%executes when user tries to close the GUI (figure1 is parent window)
function figure1_CloseRequestFcn(hObject, eventdata, handles)
selection = questdlg('Close meta GUI?',...
                     'Close Request Function',...
                     'Yes','No','Yes');
switch selection
case 'Yes'
delete(hObject);
fclose(handles.s);
case 'No'
    return
end

function value=boxcarValue(handles,boxcar)
values = zeros(1,boxcar);
for i = 1:boxcar
    values(i) = readValue(handles);
end
value = mean(values);

function value=readValue(handles)
%the Arduino is programmed to return the voltage of the photodiode when it
%recieves a line feed character. Therefore, to get the value matlab first
%sends a line feed character serially and then reads the resulting serial
%data. 
    fwrite(handles.s,10);               % write a line feed
    value=fscanf(handles.s);            % read it
    value(end)=[];              % Get rid of lf charcter
    value=str2double(value);    % Convert to number
    value = (value/4095.0)*3300.0; %convert to mV
    
function channelpulse(s,chan,delta,dir)
gotochannum(s,chan);
setdir(s,dir);
pulse(s,delta);
function out = query(s)
stringy = "@IDN?";
fprintf(s,stringy);
out = fscanf(s) %#ok<*NOPRT>
function out = getchannum(s)
stringy = '@:instrument:nselect?';
fprintf(s,stringy);
out = fscanf(s)
function out = getchanname(s)
stringy = '@:instrument:select?';
fprintf(s,stringy);
out = fscanf(s)
function out = gotochannum(s,channel)
%channel is channel number as a string
% eg: "123" (SLOT 1, CONNECTOR 2, MOTOR 3)
stringy = sprintf('@:instrument:nselect %s',channel);
fprintf(s,stringy);
out = fscanf(s);
function out = gotochanname(s,channel)
%channel should be the name of the motor, not the number
% eg: "TC Mirror Mount"
stringy = sprintf('@:instrument:select "%s"',channel);
fprintf(s,stringy);
out = fscanf(s)
function out = namechan(s,channel,name)
%set the channel logical name, given a channel number
% eg: "123" (SLOT 1, CONNECTOR 2, MOTOR 3)
stringy = sprintf('@:instrument:define "%s",%s',name,channel);
fprintf(s,stringy);
out = fscanf(s)
function out = getlogicalname(s,channel)
stringy = sprintf('@:instrument:catalog? %s',channel);
fprintf(s,stringy);
out=fscanf(s)
function out = pulse(s,number)
%sends a number of pulses out the current channel
%direction and channel must be set separately...
stringy = sprintf('@:source:pulse:count %f', number);
fprintf(s,stringy);
out = fscanf(s);
function out = getperiod(s)
%gets the pulse period on the current channel
stringy = sprintf('@:source:pulse:period?');
fprintf(s,stringy);
out = fscanf(s)
function out = setperiod(s,per)
%sets the period of the pulses ON THE CURRENT CHANNEL. Note that the argument must be given as a
%string: number with units EG: number = "10 S" or "34 MS"
%use "min" to select the minimum, and "max" to select the maximum
%note that even though the minimum period is 670 us, the picomotor will
%only accept units of ms and s. (i.e. put minimum value as ".67 ms"
%MINIMUM PERIOD: 670 us MAXIMUM PERIOD: 44 s
%allowed periods are integer multiples of the minimum. any input will be
%rounded to the nearest one of this value
stringy = sprintf('@:source:pulse:period %s', per);
fprintf(s,stringy);
out = fscanf(s)
function out = getfreq(s)
%gets the pulse frequency on the current channel
stringy = sprintf('@:source:pulse:frequency?');
fprintf(s,stringy);
out = fscanf(s)
function out = setfreq(s,freq)
%sets the frequency of the pulses ON THE CURRENT CHANNEL. Note that the argument must be given as a
%string: number with units EG: number = "10 HZ" or "34 KHZ"
% "max" will set to 1.5kHz "min" will set to .023 Hz
%any input will be rounded to integer dividens of the maximum
%get freq will return this actual frequency, not the unrounded argument of
%this function
stringy = sprintf('@:source:pulse:frequency %s', freq);
fprintf(s,stringy);
out = fscanf(s)
function out = getdir(s)
%gets the pulse direction on the current channel
stringy = sprintf('@:source:direction?');
fprintf(s,stringy);
out = fscanf(s)
function out = setdir(s,dir)
%sets the direction of rotation on the CURRENT CHANNEL.
%arguments are::: dir = "CW" or dir = "CCW"
%note that "CW" move the screw IN and "CCW" moves the screw OUT
stringy = sprintf('@:source:direction %s', dir);
fprintf(s,stringy);
out = fscanf(s);


% --- Executes on selection change in freedom1.
function freedom1_Callback(hObject, eventdata, handles)
% hObject    handle to freedom1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns freedom1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from freedom1

% --- Executes during object creation, after setting all properties.
function freedom1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freedom1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in freedom2.
function freedom2_Callback(hObject, eventdata, handles)
% hObject    handle to freedom2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns freedom2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from freedom2


% --- Executes during object creation, after setting all properties.
function freedom2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freedom2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

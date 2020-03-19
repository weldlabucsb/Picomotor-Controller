%% 
%% 
%% 

%{
\New Focus 8732 Picomotor Driver GUI
Author: Max Prichard
Date: 1/12/2019

The purpose of this program is to emulate the GUI that is provided with the
new New Focus/Newport picomotor drivers...
Find your serial ports — Display a list of serial ports on your system using the seriallist function.
Create a serial port object — Create a serial port object for a specific serial port using the serial creation function.
Configure properties during object creation if necessary. In particular, you might want to configure properties associated with
 serial port communications such as the baud rate, the number of data bits, and so on.
Connect to the device — Connect the serial port object to the device using the fopen function.
After the object is connected, alter the necessary device settings by configuring property values, read data, and write data.
Configure properties — To establish the desired serial port object behavior, assign values to properties using the set function or dot notation.
In practice, you can configure many of the properties at any time including during, or just after, object creation.
 Conversely, depending on your device settings and the requirements of your serial port application, you might be able to accept the default property values and skip this step.
Write and read data — Write data to the device using the fprintf or fwrite function, and read data from the device using the fgetl, fgets, fread, fscanf, or readasync function.
The serial port object behaves according to the previously configured or default property values.
Disconnectand remove it from the MATLAB® workspace using the clear command.
For my own and others' future use.
%}

%If matlab gives you errors, suppress 'em. -Max
%#ok<*DEFNU,*INUSL>

function varargout = NewFocusPicomotorGUI(varargin)
% NewFocusPicomotorGUI MATLAB code for NewFocusPicomotorGUI.fig
%      NewFocusPicomotorGUI, by itself, creates a new NewFocusPicomotorGUI or raises the existing
%      singleton*.
%
%      H = NewFocusPicomotorGUI returns the handle to a new NewFocusPicomotorGUI or the handle to
%      the existing singleton*.
%
%      NewFocusPicomotorGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NewFocusPicomotorGUI.M with the given input arguments.
%
%      NewFocusPicomotorGUI('Property','Value',...) creates a new NewFocusPicomotorGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NewFocusPicomotorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NewFocusPicomotorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NewFocusPicomotorGUI

% Last Modified by GUIDE v2.5 03-Jun-2019 11:33:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NewFocusPicomotorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @NewFocusPicomotorGUI_OutputFcn, ...
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
% --- Executes just before NewFocusPicomotorGUI is made visible.
function NewFocusPicomotorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NewFocusPicomotorGUI (see VARARGIN)

serial_devices = seriallist;
disp(serial_devices)
prompt = 'what COM port is the New Focus attached to...?'
port = input(prompt);
ser = serial(port);
fopen(ser);
disp("successful connection estd.")
%set comm parameters
ser.BaudRate = 9600;
ser.DataBits = 8;
ser.Parity = 'none';
ser.StopBits = 1;
ser.Terminator = 'CR';
ser.flowcontrol = 'none';
% Choose default command line output for NewFocusPicomotorGUI
handles.output = hObject;
%important: any necessarily global variables for the GUI must be
%instantiated and updated into the handles (GUIDATA) structure
handles.ser = ser;
%these are the numerical codes that correspond to each jack on the output
%of the newfocus. Order is left to right then top to bottom (eg 11 is top
%left and 23 is second column and third jack down
handles.conns = {'11';'12';'13';'14';'21';'22';'23';'24';'31';'32';'33';'34';'41';'42';'43';'44'};
%There has to be an inex specifying which connector is currently selected.
%connectorxsloty methods set this parameter. Default is 1 (slot 1 conn 1)
handles.connindex = 1;
%Note that the newfocus can store the direction and names independently
%for EACH picomotor. Keep these stored even after switching the connector. 
direction(1:3,1:16) = "CW";
stepsize(1:3,1:16) = "500";
names(1:3,1:16) = "";
channelnames(1:16) = "";
descriptions(1:3,1:16) = "";
positions(1:3,1:16) = "0";
for i = 1:16
    channelnames(i) = getlogicalname(ser,handles.conns{i});
    for j = 1:3
        names(j,i) = getlogicalname(ser,strcat(handles.conns{i},string(j)));
        gotochannum(ser,strcat(handles.conns{i},string(j)));
        direction(j,i) = getdir(ser);
    end
end
handles.direction = direction;
handles.stepsize = stepsize;
handles.names = names;
handles.channelnames = channelnames;
handles.descriptions = descriptions;
handles.positions = positions;
% Update handles structure
guidata(hObject, handles);
loadState(hObject,handles)
% UIWAIT makes NewFocusPicomotorGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% --- Outputs from this function are returned to the command line.
function varargout = NewFocusPicomotorGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;

function update(handles)
%this function will update everything for the current channel
%when one of the connection buttons are pushed or when the direction
%is changed.
set(handles.channelname,'String',handles.channelnames(handles.connindex))
set(handles.pico1stepsize,'String',handles.stepsize(1,handles.connindex))
set(handles.pico2stepsize,'String',handles.stepsize(2,handles.connindex))
set(handles.pico3stepsize,'String',handles.stepsize(3,handles.connindex))
set(handles.pico1direction,'String',handles.direction(1,handles.connindex))
set(handles.pico2direction,'String',handles.direction(2,handles.connindex))
set(handles.pico3direction,'String',handles.direction(3,handles.connindex))
set(handles.pico1name,'String',handles.names(1,handles.connindex))
set(handles.pico2name,'String',handles.names(2,handles.connindex))
set(handles.pico3name,'String',handles.names(3,handles.connindex))
set(handles.pico1description,'String',handles.descriptions(1,handles.connindex))
set(handles.pico2description,'String',handles.descriptions(2,handles.connindex))
set(handles.pico3description,'String',handles.descriptions(3,handles.connindex))
set(handles.motor1pos,'String',handles.positions(1,handles.connindex))
set(handles.motor2pos,'String',handles.positions(2,handles.connindex))
set(handles.motor3pos,'String',handles.positions(3,handles.connindex))

%Instead of using tabs, I created a set of buttons that change which
%connector the driver is currently controlling. It's a bit cluncky, but
%looks simple and works well.

    
function connector1slot1_Callback(hObject, eventdata, handles)
% hObject    handle to connector1slot1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Please don't be confused about what is going on here! To make the data
%avilable to every callback (button, pull-down menu etc..) you need to save it to
%handles. That is the first line. However, assignment must be updated
%before the function terminates, and that is what guidata does. hObject refers
%to the object whose call is executing (in this case the button
%connector1slot1.) This means I don't have to specify
%the object each time, just whichever one called it. 
handles.connindex = 1;
guidata(hObject,handles);
update(handles);

function connector2slot1_Callback(hObject, eventdata, handles) 
handles.connindex = 2;
guidata(hObject,handles);
update(handles);

function connector3slot1_Callback(hObject, eventdata, handles)
handles.connindex = 3;
guidata(hObject,handles);
update(handles);

function connector4slot1_Callback(hObject, eventdata, handles)
handles.connindex = 4;
guidata(hObject,handles);
update(handles);

function connector1slot2_Callback(hObject, eventdata, handles)
handles.connindex = 5;
guidata(hObject,handles);
update(handles);

function connector2slot2_Callback(hObject, eventdata, handles)
handles.connindex = 6;
guidata(hObject,handles);
update(handles);

function connector3slot2_Callback(hObject, eventdata, handles)
handles.connindex = 7;
guidata(hObject,handles);
update(handles);

function connector4slot2_Callback(hObject, eventdata, handles)
handles.connindex = 8;
guidata(hObject,handles);
update(handles);

function connector1slot3_Callback(hObject, eventdata, handles)
handles.connindex = 9;
guidata(hObject,handles);
update(handles);

function connector2slot3_Callback(hObject, eventdata, handles)
handles.connindex = 10;
guidata(hObject,handles);
update(handles);

function connector3slot3_Callback(hObject, eventdata, handles)
handles.connindex = 11;
guidata(hObject,handles);
update(handles);

function connector4slot3_Callback(hObject, eventdata, handles)
handles.connindex = 12;
guidata(hObject,handles);
update(handles);

function connector1slot4_Callback(hObject, eventdata, handles)
handles.connindex = 13;
guidata(hObject,handles);
update(handles);

function connector2slot4_Callback(hObject, eventdata, handles)
handles.connindex = 14;
guidata(hObject,handles);
update(handles);

function connector3slot4_Callback(hObject, eventdata, handles)
handles.connindex = 15;
guidata(hObject,handles);
update(handles);

function connector4slot4_Callback(hObject, eventdata, handles)
handles.connindex = 16;
guidata(hObject,handles);
update(handles);

%these three functions use the piconame fields in the GUI to change the
%name of the picomotor in the matlab state file (See the function saveState:
% it saves the current handles structure and when the program
%is next run it re-loads the settings at time of shutdown)and the driver
function pico1name_Callback(hObject, eventdata, handles) %#ok<*INUSD>
newname = get(hObject,'String');
currchannel = strcat(handles.conns{handles.connindex},"1");
namechan(handles.ser,currchannel,newname);
handles.names(1,handles.connindex)=newname;
guidata(hObject,handles);

function pico2name_Callback(hObject, eventdata, handles)
newname = get(hObject,'String');
currchannel = strcat(handles.conns{handles.connindex},"2");
namechan(handles.ser,currchannel,newname)
handles.names(2,handles.connindex)=newname;
guidata(hObject,handles);

function pico3name_Callback(hObject, eventdata, handles)
newname = get(hObject,'String');
currchannel = strcat(handles.conns{handles.connindex},"3");
namechan(handles.ser,currchannel,newname)
handles.names(3,handles.connindex)=newname;
guidata(hObject,handles);

%This function behaves like the picomotor name functions, only this one
%changes the channel name. This is also stored in both the matlab state
%(see: saveState) file and the dirver's memory.

function channelname_Callback(hObject, eventdata, handles)
newname = get(hObject,'String');
currchannel = handles.conns{handles.connindex};
namechan(handles.ser,currchannel,newname)
handles.channelnames(handles.connindex)=newname;
guidata(hObject,handles);

%Change direction of the motors. This might be stored in the driver, but I
%am not sure. It is saved in the state file, anyways.

function changedirmotor1_Callback(hObject, eventdata, handles)
gotochannum(handles.ser,strcat(handles.conns{handles.connindex},'1'));
dir = splitlines(getdir(handles.ser));
dir = dir{1};
if dir == "CW"
    setdir(handles.ser,"CCW");
    handles.direction(1,handles.connindex) = "CCW";
else
    setdir(handles.ser,"CW");
    handles.direction(1,handles.connindex) = "CW";
end
guidata(hObject,handles);
update(handles);
set(handles.pico1direction,'String',handles.direction(1,handles.connindex));

  
function changedirmotor3_Callback(hObject, eventdata, handles)
gotochannum(handles.ser,strcat(handles.conns{handles.connindex},'3'));
dir = splitlines(getdir(handles.ser));
dir = dir{1};
if dir == "CW"
    setdir(handles.ser,"CCW");
    handles.direction(3,handles.connindex) = "CCW";
else
    setdir(handles.ser,"CW");
    handles.direction(3,handles.connindex) = "CW";
end
guidata(hObject,handles);
update(handles);
set(handles.pico3direction,'String',handles.direction(3,handles.connindex));


function changedirmotor2_Callback(hObject, eventdata, handles)
gotochannum(handles.ser,strcat(handles.conns{handles.connindex},'2'));
dir = splitlines(getdir(handles.ser));
dir = dir{1};
if dir == "CW"
    setdir(handles.ser,"CCW");
    handles.direction(2,handles.connindex) = "CCW";
else
    setdir(handles.ser,"CW");
    handles.direction(2,handles.connindex) = "CW";
end
guidata(hObject,handles);
update(handles);
set(handles.pico2direction,'String',handles.direction(2,handles.connindex));

%This changes the step size. Checks that entry in numeric

function pico1stepsize_Callback(hObject, eventdata, handles)
newstep = str2double(get(hObject,'String'));
if isnan(newstep)
    errordlg('You must enter a number.','Invalid Input','modal')
    uicontrol(hObject);
    return
else
    handles.stepsize(1,handles.connindex) = newstep;
    guidata(hObject,handles);
end

function pico2stepsize_Callback(hObject, eventdata, handles)
newstep = str2double(get(hObject,'String'));
if isnan(newstep)
    errordlg('You must enter a number.','Invalid Input','modal')
    uicontrol(hObject);
    return
else
    handles.stepsize(2,handles.connindex) = newstep;
    guidata(hObject,handles);
end

function pico3stepsize_Callback(hObject, eventdata, handles)
newstep = str2double(get(hObject,'String'));
if isnan(newstep)
    errordlg('You must enter a number.','Invalid Input','modal')
    uicontrol(hObject);
    return
else
    handles.stepsize(3,handles.connindex) = newstep;
    guidata(hObject,handles);
end

%Perhaps the most important function, the step motor button! This moves the
%motor and also updates the position.

function stepmotorone_Callback(hObject, eventdata, handles)
currchannel = strcat(handles.conns{handles.connindex},"1");
gotochannum(handles.ser,currchannel)
pulse(handles.ser,handles.stepsize(1,handles.connindex))
currpos = get(handles.motor1pos,'String')
if handles.direction(1,handles.connindex) == "CW"
    newpos = num2str(str2double(currpos)+str2double(handles.stepsize(1,handles.connindex)))
else
    newpos = num2str(str2double(currpos)-str2double(handles.stepsize(1,handles.connindex)))
end
handles.positions(1,handles.connindex) = string(newpos);
set(handles.motor1pos,'String',newpos)
guidata(hObject,handles);

function stepmotortwo_Callback(hObject, eventdata, handles)
currchannel = strcat(handles.conns{handles.connindex},"2");
gotochannum(handles.ser,currchannel)
pulse(handles.ser,handles.stepsize(2,handles.connindex))
currpos = get(handles.motor2pos,'String')
if handles.direction(2,handles.connindex) == "CW"
    newpos = num2str(str2double(currpos)+str2double(handles.stepsize(2,handles.connindex)))
else
    newpos = num2str(str2double(currpos)-str2double(handles.stepsize(2,handles.connindex)))
end
handles.positions(2,handles.connindex) = string(newpos);
set(handles.motor2pos,'String',newpos)
guidata(hObject,handles);

function stepmotorthree_Callback(hObject, eventdata, handles)
currchannel = strcat(handles.conns{handles.connindex},"3");
gotochannum(handles.ser,currchannel)
pulse(handles.ser,handles.stepsize(3,handles.connindex))
currpos = get(handles.motor3pos,'String')
if handles.direction(3,handles.connindex) == "CW"
    newpos = string(str2double(currpos)+str2double(handles.stepsize(3,handles.connindex)))
else
    newpos = num2str(str2double(currpos)+str2double(handles.stepsize(3,handles.connindex)))
end
handles.positions(3,handles.connindex) = string(newpos);
set(handles.motor3pos,'String',newpos)
guidata(hObject,handles);

%These functions zero the positions of the respective motors

function motor1zero_Callback(hObject, eventdata, handles)
handles.positions(1,handles.connindex) = "0"
set(handles.motor1pos,'String',"0")
guidata(hObject,handles);

function motor2zero_Callback(hObject, eventdata, handles)
handles.positions(2,handles.connindex) = "0"
set(handles.motor2pos,'String',"0")
guidata(hObject,handles);

function motor3zero_Callback(hObject, eventdata, handles)
handles.positions(3,handles.connindex) = "0"
set(handles.motor3pos,'String',"0")
guidata(hObject,handles);

%The description is purely for the user; it is not utilized or stored in
%the picomotor driver. 

function pico1description_Callback(hObject, eventdata, handles)
    handles.descriptions(1,handles.connindex) = get(hObject,'String');
    guidata(hObject,handles);
function pico2description_Callback(hObject, eventdata, handles)
    handles.descriptions(2,handles.connindex) = get(hObject,'String');
    guidata(hObject,handles);
function pico3description_Callback(hObject, eventdata, handles)
    handles.descriptions(3,handles.connindex) = get(hObject,'String');
    guidata(hObject,handles);
    
% --- Executes on button press in entermetamode.
%USED TO ENTER THE MOST META MODE: MACHINE LEARNING CONVOLUTION SUBLAYER
%OPTICAL POWER OPTIMIZATION (just kidding)
function entermetamode_Callback(hObject, eventdata, handles)
% hObject    handle to entermetamode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
metagui(handles.ser,handles.names)
    

%This is the famous saveState function. It takes the parts of handles
%(the thing that stores all of the data for the user
%input elements, remember?) that aren't stored in the Picomotor Driver's
%non-volatile memory and saves them in a matlab file. Then, when the
%program is next turned on if there exists a file called state.mat in the
%working directory, then the program will use the saved handles entries.
%Simple, but effective.
function saveState(handles)
state.descriptions = handles.descriptions;
state.stepsize = handles.stepsize;
state.positions = handles.positions; %#ok<STRNU>
save('state.mat','state')

function loadState(hObject,handles)
if exist('state.mat','file')
    load('state.mat')
    handles.descriptions = state.descriptions
    handles.stepsize = state.stepsize
    handles.positions = state.positions
    guidata(hObject,handles)
    delete('state.mat')
end

%A function to double check close request
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg('Close New Focus Picomotor GUI?',...
                     'Close Request Function',...
                     'Yes','No','Yes');
switch selection
case 'Yes'
saveState(handles)
fclose(handles.ser);
delete(hObject);
case 'No'
    return
end
    
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
out = fscanf(s)
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
out = fscanf(s)
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
out = fscanf(s)



 
 function pico3name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pico2stepsize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pico1stepsize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pico3stepsize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pico3description_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pico2description_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pico1name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pico1description_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pico2name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function channelname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function motor1pos_Callback(hObject, eventdata, handles)
% hObject    handle to motor1pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of motor1pos as text
%        str2double(get(hObject,'String')) returns contents of motor1pos as a double


% --- Executes during object creation, after setting all properties.
function motor1pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to motor1pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function motor3pos_Callback(hObject, eventdata, handles)
% hObject    handle to motor3pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of motor3pos as text
%        str2double(get(hObject,'String')) returns contents of motor3pos as a double


% --- Executes during object creation, after setting all properties.
function motor3pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to motor3pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function motor2pos_Callback(hObject, eventdata, handles)
% hObject    handle to motor2pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of motor2pos as text
%        str2double(get(hObject,'String')) returns contents of motor2pos as a double


% --- Executes during object creation, after setting all properties.
function motor2pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to motor2pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

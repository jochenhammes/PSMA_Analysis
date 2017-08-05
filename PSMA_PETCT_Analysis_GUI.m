function varargout = PSMA_PETCT_Analysis_GUI(varargin)
% PSMA_PETCT_ANALYSIS_GUI MATLAB code for PSMA_PETCT_Analysis_GUI.fig
%      PSMA_PETCT_ANALYSIS_GUI, by itself, creates a new PSMA_PETCT_ANALYSIS_GUI or raises the existing
%      singleton*.
%
%      H = PSMA_PETCT_ANALYSIS_GUI returns the handle to a new PSMA_PETCT_ANALYSIS_GUI or the handle to
%      the existing singleton*.
%
%      PSMA_PETCT_ANALYSIS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PSMA_PETCT_ANALYSIS_GUI.M with the given input arguments.
%
%      PSMA_PETCT_ANALYSIS_GUI('Property','Value',...) creates a new PSMA_PETCT_ANALYSIS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PSMA_PETCT_Analysis_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PSMA_PETCT_Analysis_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PSMA_PETCT_Analysis_GUI

% Last Modified by GUIDE v2.5 04-Aug-2017 18:03:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PSMA_PETCT_Analysis_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PSMA_PETCT_Analysis_GUI_OutputFcn, ...
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


% --- Executes just before PSMA_PETCT_Analysis_GUI is made visible.
function PSMA_PETCT_Analysis_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PSMA_PETCT_Analysis_GUI (see VARARGIN)

% Choose default command line output for PSMA_PETCT_Analysis_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PSMA_PETCT_Analysis_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PSMA_PETCT_Analysis_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function txtInputFolder_Callback(hObject, eventdata, handles)
% hObject    handle to txtInputFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtInputFolder as text
%        str2double(get(hObject,'String')) returns contents of txtInputFolder as a double


% --- Executes during object creation, after setting all properties.
function txtInputFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtInputFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnFolderSelect.
function btnFolderSelect_Callback(hObject, eventdata, handles)
% hObject    handle to btnFolderSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder_path = uigetdir(get(handles.txtInputFolder, 'String'), 'asdf');
set(handles.txtInputFolder, 'String', [folder_path filesep])



% --- Executes on button press in btnRun.
function btnRun_Callback(hObject, eventdata, handles)
% hObject    handle to btnRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function txtHUThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to txtHUThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtHUThreshold as text
%        str2double(get(hObject,'String')) returns contents of txtHUThreshold as a double


% --- Executes during object creation, after setting all properties.
function txtHUThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtHUThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtSUVThresholds_Callback(hObject, eventdata, handles)
% hObject    handle to txtSUVThresholds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSUVThresholds as text
%        str2double(get(hObject,'String')) returns contents of txtSUVThresholds as a double


% --- Executes during object creation, after setting all properties.
function txtSUVThresholds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSUVThresholds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_meanSUV_Callback(hObject, eventdata, handles)
% hObject    handle to txt_meanSUV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_meanSUV as text
%        str2double(get(hObject,'String')) returns contents of txt_meanSUV as a double


% --- Executes during object creation, after setting all properties.
function txt_meanSUV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_meanSUV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtStdSUV_Callback(hObject, eventdata, handles)
% hObject    handle to txtStdSUV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtStdSUV as text
%        str2double(get(hObject,'String')) returns contents of txtStdSUV as a double


% --- Executes during object creation, after setting all properties.
function txtStdSUV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtStdSUV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnRunAnalysis.
function btnRunAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to btnRunAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pathInputFolder = get(handles.txtInputFolder, 'String')
HUThreshold  = eval(get(handles.txtHUThreshold, 'String'))
SUVThreshold  = eval(get(handles.txtSUVThresholds, 'String'))
voxelVolumePET  = eval(get(handles.txtVoxelVolume, 'String'))
hc_meanSUV  = eval(get(handles.txt_meanSUV, 'String'))
hc_StdSUV  = eval(get(handles.txtStdSUV, 'String'))
performClusterAnalysis  = get(handles.chkPerformClusterAnalysis, 'Value')
metastasisVolThreshold  = eval(get(handles.txtMetastasisVolThreshold, 'String'))
createVisualOuput  = get(handles.chkCreateVisualOuput, 'Value')


[ImageProperties, Bloblist, petAboveThreshold, ctBoneMask] = analyzePETCT(pathInputFolder, HUThreshold, SUVThreshold, hc_meanSUV, hc_StdSUV, voxelVolumePET, performClusterAnalysis, metastasisVolThreshold);

if createVisualOuput
    %Create MIP in coronal viewing plane
    petMIP = flipdim(squeeze(max(petAboveThreshold.img, [], 2))',1);
    ctBoneMaskMIP = flipdim(squeeze(max(ctBoneMask, [], 2))',1);
end



function txtVoxelVolume_Callback(hObject, eventdata, handles)
% hObject    handle to txtVoxelVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtVoxelVolume as text
%        str2double(get(hObject,'String')) returns contents of txtVoxelVolume as a double


% --- Executes during object creation, after setting all properties.
function txtVoxelVolume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtVoxelVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkPerformClusterAnalysis.
function chkPerformClusterAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to chkPerformClusterAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkPerformClusterAnalysis



function txtMetastasisVolThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to txtMetastasisVolThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtMetastasisVolThreshold as text
%        str2double(get(hObject,'String')) returns contents of txtMetastasisVolThreshold as a double


% --- Executes during object creation, after setting all properties.
function txtMetastasisVolThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtMetastasisVolThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkCreateVisualOuput.
function chkCreateVisualOuput_Callback(hObject, eventdata, handles)
% hObject    handle to chkCreateVisualOuput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkCreateVisualOuput

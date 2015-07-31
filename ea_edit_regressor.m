function varargout = ea_edit_regressor(varargin)
% EA_EDIT_REGRESSOR MATLAB code for ea_edit_regressor.fig
%      EA_EDIT_REGRESSOR, by itself, creates a new EA_EDIT_REGRESSOR or raises the existing
%      singleton*.
%
%      H = EA_EDIT_REGRESSOR returns the handle to a new EA_EDIT_REGRESSOR or the handle to
%      the existing singleton*.
%
%      EA_EDIT_REGRESSOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EA_EDIT_REGRESSOR.M with the given input arguments.
%
%      EA_EDIT_REGRESSOR('Property','Value',...) creates a new EA_EDIT_REGRESSOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ea_edit_regressor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ea_edit_regressor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ea_edit_regressor

% Last Modified by GUIDE v2.5 12-Jul-2015 10:16:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ea_edit_regressor_OpeningFcn, ...
    'gui_OutputFcn',  @ea_edit_regressor_OutputFcn, ...
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


% --- Executes just before ea_edit_regressor is made visible.
function ea_edit_regressor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ea_edit_regressor (see VARARGIN)

% Choose default command line output for ea_edit_regressor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);



M=varargin{1};

[~,ptnames]=cellfun(@fileparts,M.patient.list,'UniformOutput',0);
set(handles.datatable,'RowName',ptnames);

try
regressor=M.clinical.vars{M.ui.clinicallist};
catch % new variable
    regressor=nan(length(ptnames),1);
end

if iscell(regressor)
   regressor=cell2mat(regressor); 
end

set(handles.datatable,'Data',regressor);
set(handles.datatable,'ColumnEditable',true(1,size(regressor,2)));
if isperpatient(regressor)
    switchperpatient(handles);
elseif ispercontactpair(regressor)
    switchpercontactpair(handles);
elseif ispercontact(regressor)
    switchpercontact(handles);
end

try
set(handles.varname,'String',M.clinical.labels{M.ui.clinicallist});
end

% UIWAIT makes ea_edit_regressor wait for user response (see UIRESUME)
uiwait(hObject);

function switchperpatient(handles)
reg=get(handles.datatable,'Data');
if ~isempty(reg)
   if ~isperpatient(reg)
       answ=questdlg('Warning: switching variable type will delete/modify variable! Are you sure you want this?','Warning','Yes','No','No');
   switch answ
       case 'No'
           set(handles.perpatient,'Value',0);
           return
   end
   end
end
set(handles.perpatient,'Value',1);
set(handles.percontact,'Value',0);
set(handles.percontactpair,'Value',0);
set(handles.datatable,'ColumnName',{'Value'});

reg=reg(1:size(reg,1),1);
set(handles.datatable,'Data',reg);
set(handles.datatable,'ColumnEditable',true(1,1));


function switchpercontact(handles)
reg=get(handles.datatable,'Data');
if ~isempty(reg)
   if ~ispercontact(reg)
       answ=questdlg('Warning: switching variable type will delete/modify variable! Are you sure you want this?','Warning','Yes','No','No');
   switch answ
       case 'No'
           set(handles.percontact,'Value',0);
           return
   end
   end
end
set(handles.perpatient,'Value',0);
set(handles.percontact,'Value',1);
set(handles.percontactpair,'Value',0);
set(handles.datatable,'ColumnName',{'K0','K1','K2','K3','K8','K9','K10','K11'});

nreg=nan(size(reg,1),8);
nreg(1:size(reg,1),1:size(reg,2))=reg;

reg=nreg; clear('nreg');
set(handles.datatable,'Data',reg);
set(handles.datatable,'ColumnEditable',true(1,8));


function switchpercontactpair(handles)
reg=get(handles.datatable,'Data');
if ~isempty(reg)
   if ~ispercontactpair(reg)
       answ=questdlg('Warning: switching variable type will delete/modify variable! Are you sure you want this?','Warning','Yes','No','No');
   switch answ
       case 'No'
           set(handles.percontactpair,'Value',0);
           return
   end
   end
end
set(handles.perpatient,'Value',0);
set(handles.percontact,'Value',0);
set(handles.percontactpair,'Value',1);
set(handles.datatable,'ColumnName',{'K1-2','K2-3','K3-4','K8-9','K9-10','K10-11'});

nreg=nan(size(reg,1),6);
try
nreg(1:size(reg,1),1:size(nreg,2))=reg(1:size(reg,1),1:size(nreg,2));
catch
nreg(1:size(reg,1),1:size(reg,2))=reg(1:size(reg,1),1:size(reg,2)); 
end
reg=nreg; clear('nreg');
set(handles.datatable,'Data',reg);
set(handles.datatable,'ColumnEditable',true(1,6));


function yn=ispercontactpair(regressor)
yn=(iscell(regressor) && size(regressor{1},2)==3) || (~iscell(regressor) && size(regressor,2)==6);
function yn=ispercontact(regressor)
yn=(iscell(regressor) && size(regressor{1},2)==4) || (~iscell(regressor) && size(regressor,2)==8);
function yn=isperpatient(regressor)
yn=~iscell(regressor) && size(regressor,2)==1;

% --- Outputs from this function are returned to the command line.
function varargout = ea_edit_regressor_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

if getappdata(gcf,'save')
    varargout{1} = get(handles.datatable,'Data');
    varargout{2}=get(handles.varname,'String');
else
    varargout{1}=[];
    varargout{2}=[];
end

delete(hObject);

% --- Executes on button press in perpatient.
function perpatient_Callback(hObject, eventdata, handles)
% hObject    handle to perpatient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of perpatient
switchperpatient(handles);

% --- Executes on button press in percontact.
function percontact_Callback(hObject, eventdata, handles)
% hObject    handle to percontact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switchpercontact(handles);
% Hint: get(hObject,'Value') returns toggle state of percontact


% --- Executes on button press in percontactpair.
function percontactpair_Callback(hObject, eventdata, handles)
% hObject    handle to percontactpair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of percontactpair
switchpercontactpair(handles);

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(gcf,'save',1);
close(gcf);

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(gcf,'save',0);
close(gcf);


% --- Executes when user attempts to close editregressor.
function editregressor_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to editregressor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%delete(hObject);
uiresume(hObject);



function varname_Callback(hObject, eventdata, handles)
% hObject    handle to varname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of varname as text
%        str2double(get(hObject,'String')) returns contents of varname as a double


% --- Executes during object creation, after setting all properties.
function varname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
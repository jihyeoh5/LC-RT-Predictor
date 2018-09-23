function varargout = LCRT_prediction_gui(varargin)
% RT_PREDICTION_GUI3 MATLAB code for RT_prediction_gui3.fig
%      RT_PREDICTION_GUI3, by itself, creates a new RT_PREDICTION_GUI3 or raises the existing
%      singleton*.
%
%      H = RT_PREDICTION_GUI3 returns the handle to a new RT_PREDICTION_GUI3 or the handle to
%      the existing singleton*.
%
%      RT_PREDICTION_GUI3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RT_PREDICTION_GUI3.M with the given input arguments.
%
%      RT_PREDICTION_GUI3('Property','Value',...) creates a new RT_PREDICTION_GUI3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RT_prediction_gui3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RT_prediction_gui3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RT_prediction_gui3

% Last Modified by GUIDE v2.5 31-Aug-2018 16:22:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LCRT_prediction_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @LCRT_prediction_gui_OutputFcn, ...
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
end

% --- Executes just before RT_prediction_gui3 is made visible.
function LCRT_prediction_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RT_prediction_gui3 (see VARARGIN)

% Choose default command line output for RT_prediction_gui3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RT_prediction_gui3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%Set up tabs and clear variable names & scatter plot
global filename
tabgp = uitabgroup;
mlrtab = uitab(tabgp,'Title','Multilinear Regression');
anntab = uitab(tabgp,'Title','Artificial Neural Network');
set(handles.uipanel1,'Parent',mlrtab);
set(handles.uipanel2,'Parent',anntab);
clearvars MLReqn displaytable filename measuredexternalRT externalRT measuredmodelRT modelRT R2 totalrows maxR2 descriptornumber combinationnumber bestfiteqn
axes(handles.axes1);
cla reset;
set(handles.edit1,'String','0.98');
set(handles.edit2,'String','60/100');
set(handles.edit3,'String','20/100');
set(handles.edit4,'String','20/100');
set(handles.edit5,'String','10');
set(handles.text42,'String','1.0');
set(handles.text28,'String','Levelberg-Marquardt');
end

% --- Outputs from this function are returned to the command line.
function varargout = LCRT_prediction_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global savefilename
filename = uigetfile('*.csv');
if filename ~= 0
    savefilename = filename;
    set(handles.MLRSelectedFile,'String',savefilename);
end
if filename==0
    filename = [];
    return
end
guidata(hObject,handles);

end

% --- Executes on button press in submitbutton.
function submitbutton_Callback(hObject, eventdata, handles)
% hObject    handle to submitbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global savefilename saveinputfilename
%Read the selected file, extract key information
[spreadsheet,descriptors] = xlsread(savefilename);
property = cell2mat(descriptors(1,end));
[totalrows,descriptornumber] = size(spreadsheet);
set(handles.text18,'String',totalrows);
totalindex = 1:totalrows;
RT = spreadsheet(:,length(descriptornumber));
descriptornumber = descriptornumber-2; %Number of descriptors = number of columns - first and last columns
set(handles.text14,'String',descriptornumber);
IDtable = spreadsheet(:,1)';
spreadsheet = spreadsheet(:,2:end);
externalnumber = round(0.2*totalrows); %Paper specifies that the external set should be 20% of all data
set(handles.text8,'String','8:2');
modelnumber = totalrows - externalnumber;
modelindex = 1:modelnumber;

[inputspreadsheet,inputdescriptors] = xlsread(saveinputfilename);
descriptorsmat = cell2mat(descriptors);
inputdescriptorsmat = cell2mat(inputdescriptors);
inputdescriptorsmat = [inputdescriptorsmat property];
if strcmp(descriptorsmat,inputdescriptorsmat) ~= 1
    error = 'The input file format is incorrect.';
    errorwindow = msgbox(error);
    set(handles.text4,'String','PLEASE SELECT A CORRECTLY FORMATTED INPUT FILE');
    return
end

externalcombinations = nchoosek(totalindex,externalnumber);
%externalcombinations = [41 21 28 14 12 39 15 8; 42 18 25 35 9 16 27 33];
combinationnumber = size(externalcombinations,1);
set(handles.text19,'String',combinationnumber);

%Initialize matrices
modelcombinations = zeros(combinationnumber,modelnumber);
R2list = zeros(1,combinationnumber);
blist = zeros(combinationnumber,descriptornumber+1);
modelRTlist = zeros(modelnumber,combinationnumber);
for i=1:combinationnumber
    modelspreadsheet = zeros(modelnumber,descriptornumber+1);
    row = externalcombinations(i,:); 
    correspondingmodel = setdiff(totalindex,row); 
    modelcombinations(i,:) = correspondingmodel;
    %Grab row in spreadsheet based on MOl_ID from correspondingmodel values
    for j=1:length(correspondingmodel)
        modelspreadsheet(j,:) = spreadsheet(correspondingmodel(j),:);
    end
    RT = modelspreadsheet(:,end);
    modelRTlist(:,i) = RT;
    modelspreadsheet = modelspreadsheet(:,1:end-1);
    X = [ones(modelnumber,1) modelspreadsheet];
    [b,~,~,~,stats] = regress(RT,X);
    R2list(i) = stats(1);
    for k=1:length(b)
        blist(i,k) = b(k);
    end
end

%Display MLR equation
maxR2 = max(R2list); 
set(handles.text10,'String',maxR2);
maxR2index = find(R2list==maxR2);
i = maxR2index;
b = blist(i,:);
MLReqnpt1 = ['RT = '];
MLReqn = [num2str(b(1))];
for j = 2:length(b)
    MLReqn = [MLReqn ' + ' num2str(b(j)) '*' descriptors{j}];
end
set(handles.modeleqn,'String',[MLReqnpt1 MLReqn]);

%Get external & model spreadsheets
molIDrow = externalcombinations(i,:);
externalspreadsheet = zeros(externalnumber,descriptornumber+1);
for j=1:length(molIDrow)
    externalspreadsheet(j,:) = spreadsheet(molIDrow(j),:);
end
measuredexternalRT = externalspreadsheet(:,end);
externalspreadsheet = externalspreadsheet(:,1:end-1);
row = modelcombinations(i,:);
modelspreadsheet = zeros(modelnumber,descriptornumber+1);
for j=1:length(row)
    modelspreadsheet(j,:) = spreadsheet(row(j),:);
end
measuredmodelRT = modelspreadsheet(:,end);
modelspreadsheet = modelspreadsheet(:,1:end-1);

%Obtain predicted RT to display in table & graph
coefficients = b(2:end);
externalRT = zeros(1,externalnumber);
for k=1:externalnumber
    externalRT(k) = sum(coefficients.*externalspreadsheet(k,:))+b(1);
end
modelRT = zeros(1,modelnumber);
for k=1:modelnumber
    modelRT(k) = sum(coefficients.*modelspreadsheet(k,:))+b(1);
end
displaytable = [molIDrow' externalRT'];
axes(handles.axes1);
caxes = handles.axes1;
scatter(caxes,measuredexternalRT',externalRT,'filled','o','blue');
caxes.XLabel.String = 'Experimental RT (min)';
caxes.YLabel.String = 'Predicted RT (min)';
hold on
scatter(measuredmodelRT',modelRT,'filled','d','red');
[p,S] = polyfit(measuredmodelRT',modelRT,1);
bestfiteqn = ['y = ' num2str(p(1)) 'x ' '- ' num2str(p(2))];
maxx = max(max(measuredexternalRT),max(measuredmodelRT));
x = 1:maxx;
y = p(1).*x + p(2);
plot(x,y,'black');
lgd = legend('External test set','Modeling set',bestfiteqn);
c = lgd.Position;
lgd.Position = [0.6 0.59 0 0];

predictions = p(1).*measuredmodelRT + p(2);
yR2 = modelRT;
R2 = (1 - sum((yR2-sum(predictions,2)').^2) / sum((yR2-mean(yR2)).^2));
R2 = ['R^2 = ' num2str(R2)];

%Predict input mol's RT and display
[inputtotalrows,inputdescriptornumber] = size(inputspreadsheet);
inputdescriptornumber = inputdescriptornumber-1;
inputID = inputspreadsheet(:,1);
inputspreadsheet = inputspreadsheet(:,2:end);
inputRT = zeros(1,length(inputID));
for k=1:length(inputID)
    inputRT(k) = sum(coefficients.*inputspreadsheet(k,:))+b(1);
end
displaytable = [inputID inputRT'];
set(handles.uitable1,'Data',displaytable);
set(handles.uitable1,'ColumnName',{'MOL ID' property});
guidata(hObject,handles);
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA
global saveinputfilename
inputfilename = uigetfile('*.csv');
if inputfilename ~= 0
    saveinputfilename = inputfilename;
    set(handles.text4,'String',saveinputfilename);
end
if inputfilename==0
    inputfilename = [];
    return
end
guidata(hObject,handles);
end

function axes1_CreateFcn(hObject, eventdata, handles)
end

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global saveANNfilename
ANNfilename = uigetfile('*.csv');
if ANNfilename ~= 0
    saveANNfilename = ANNfilename;
    set(handles.text22,'String',saveANNfilename);
end
if ANNfilename==0
    ANNfilename = [];
    return
end
guidata(hObject,handles);
end

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global trainFcn hiddenLayerSize net R2cv y saveANNfilename saveANNinputfilename
submittedsum = str2double(get(handles.text42,'String'));
if submittedsum ~= 1
    set(handles.text42,'BackgroundColor','red');
    return
end
trainFcn = 'trainlm'; %Levelberg-Marquardt
hiddenLayerSize = str2double(get(handles.edit5,'String'));
net.divideParam.trainRatio = str2num(get(handles.edit2,'String'));
net.divideParam.valRatio = str2num(get(handles.edit3,'String'));
net.divideParam.testRatio = str2num(get(handles.edit4,'String'));
targetR2 = str2double(get(handles.edit1,'String'));
R2cv = 0;
[ANNspreadsheet,ANNdescriptors] = xlsread(saveANNfilename);
ANNproperty = cell2mat(ANNdescriptors(1,end));
[n,ANNdescriptornumber] = size(ANNspreadsheet);
ANNdescriptornumber = ANNdescriptornumber-2;
set(handles.text34,'String',n);
set(handles.text36,'String',ANNdescriptornumber);
x = ANNspreadsheet(:,2:end-1)';
t = ANNspreadsheet(:,end)';


[ANNinputspreadsheet, ANNinputdescriptors] = xlsread(saveANNinputfilename);
ANNdescriptorsmat = cell2mat(ANNdescriptors);
ANNinputdescriptorsmat = cell2mat(ANNinputdescriptors);
ANNinputdescriptorsmat = [ANNinputdescriptorsmat ANNproperty];
if strcmp(ANNdescriptorsmat,ANNinputdescriptorsmat) ~= 1
    ANNerror = 'The input file format is incorrect.';
    ANNerrorwindow = msgbox(ANNerror);
    set(handles.text23,'String','PLEASE SELECT A CORRECTLY FORMATTED INPUT FILE');
    return
end

while R2cv<targetR2
        y = getnet(x,t);
    R2cv = crossvalidationR2(x,n,y);
    set(handles.text38,'String',num2str(round(R2cv,4)));
end
ANNpredicted = net(x)';
axes(handles.axes2);
ANNcaxes = handles.axes2;
scatter(ANNcaxes,t',ANNpredicted,'filled','d','red');
ANNcaxes.XLabel.String = 'Experimental RT (min)';
ANNcaxes.YLabel.String = 'Predicted RT (min)';
title(ANNcaxes,'Measured vs Predicted RT');
set(handles.text38,'String',num2str(round(R2cv,4)));



[ANNinputrownumber,ANNinputcolnumber] = size(ANNinputspreadsheet);
ANNinputDC = ANNinputspreadsheet(:,2:end);
ANNinputID = ANNinputspreadsheet(:,1);
ANNinputRT = zeros(ANNinputrownumber,1);
for i = 1:ANNinputrownumber
    inputx = ANNinputDC(i,:)';
    ANNinputRT(i,1) = net(inputx);
end

ANNdisplaytable = [ANNinputID ANNinputRT];
set(handles.uitable2,'Data',ANNdisplaytable);
set(handles.uitable2,'ColumnName',{'MOL ID' ANNproperty});

    function y=getnet(x,t)
        %global trainFcn hiddenLayerSize net
        net = fitnet(hiddenLayerSize,trainFcn);
        [net,tr] = train(net,x,t);
        y = net(x);
        %e = gsubtract(t,y);
        %performance = perform(net,t,y);
    end

    function R2cv=crossvalidationR2(x,n,y)
        % perform leave-one-out cross-validation
        predictions = zeros(n,11);  
        for p=1:n
          % figure out indices
          trainix = setdiff(1:n, p);
          testix = p';
          % train the model
          X = [x(:,trainix)' ones(length(trainix),1)];  % construct regressor matrix
          h = inv(X'*X)*X'*y(trainix)';               % estimate parameters
          % test the model by computing the prediction for the left-out data point
          predictions(p,:) = [x(:,testix)' ones(length(testix),1)].*h';
        end
        R2cv = (1 - sum((y-sum(predictions,2)').^2) / sum((y-mean(y)).^2));
    end
guidata(hObject,handles);


end

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA

global saveANNinputfilename
ANNinputfilename = uigetfile('*.csv');
if ANNinputfilename ~= 0
    saveANNinputfilename = ANNinputfilename;
    set(handles.text23,'String',saveANNinputfilename);
end
if ANNinputfilename==0
    ANNinputfilename = [];
    return
end
guidata(hObject,handles);

end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
end

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
str1 = get(handles.edit2,'String');
str2 = get(handles.edit3,'String');
str3 = get(handles.edit4,'String');
num1 = regexp(str1,'[0-9]+','match');
num2 = regexp(str2,'[0-9]+','match');
num3 = regexp(str3,'[0-9]+','match');
frac1 = str2double(num1{1})/str2double(num1{2});
frac2 = str2double(num2{1})/str2double(num2{2});
frac3 = str2double(num3{1})/str2double(num3{2});
sum = num2str(frac1+frac2+frac3);
set(handles.text42,'String',sum);
if sum == '1'
    set(handles.text42,'BackgroundColor','[0.8 0.8 0.8]');
end
end

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
str1 = get(handles.edit2,'String');
str2 = get(handles.edit3,'String');
str3 = get(handles.edit4,'String');
num1 = regexp(str1,'[0-9]+','match');
num2 = regexp(str2,'[0-9]+','match');
num3 = regexp(str3,'[0-9]+','match');
frac1 = str2double(num1{1})/str2double(num1{2});
frac2 = str2double(num2{1})/str2double(num2{2});
frac3 = str2double(num3{1})/str2double(num3{2});
sum = num2str(frac1+frac2+frac3);
set(handles.text42,'String',sum);
if sum == '1'
    set(handles.text42,'BackgroundColor','[0.8 0.8 0.8]');
end
end

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
str1 = get(handles.edit2,'String');
str2 = get(handles.edit3,'String');
str3 = get(handles.edit4,'String');
num1 = regexp(str1,'[0-9]+','match');
num2 = regexp(str2,'[0-9]+','match');
num3 = regexp(str3,'[0-9]+','match');
frac1 = str2double(num1{1})/str2double(num1{2});
frac2 = str2double(num2{1})/str2double(num2{2});
frac3 = str2double(num3{1})/str2double(num3{2});
sum = num2str(frac1+frac2+frac3);
set(handles.text42,'String',sum);
if sum == '1'
    set(handles.text42,'BackgroundColor','[0.8 0.8 0.8]');
end
end

% --- Executes during object creation, after setting all properties.


function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
end

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

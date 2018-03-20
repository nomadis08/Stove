unit StoveInterface;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, Buttons, BCPort, StoveUnit, ComCtrls, ExtCtrls,
  TeEngine, Series, TeeProcs, Chart;
type
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    GroupBox1: TGroupBox;
    ComPorts: TComboBox;
    ComSpeed: TComboBox;
    Button2: TButton;
    Button3: TButton;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    FactorsGrid: TStringGrid;
    ProfilesGrid: TStringGrid;
    PresetsGrid: TStringGrid;
    BitBtn1: TBitBtn;
    Memo1: TMemo;
    BComPort1: TBComPort;
    CheckBox1: TCheckBox;
    Timer1: TTimer;
    Button4: TButton;
    Chart1: TChart;
    Series1: TLineSeries;
    Button7: TButton;
    GroupBox3: TGroupBox;
    Label4: TLabel;
    edtError: TEdit;
    edtResist: TEdit;
    Label5: TLabel;
    Button6: TButton;
    btnLoadFromDevice: TButton;
    Button1: TButton;
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure DataGridKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ComSpeedChange(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure BComPort1RxChar(Sender: TObject; Count: Integer);
    procedure btnLoadFromDeviceClick(Sender: TObject);
    procedure edtKeyPress(Sender: TObject; var Key: Char);
    procedure Button6Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure ProfilesGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  tmpStr:string;
  tmpTimeBegin: TTimeStamp;

implementation
{$R *.dfm}
function verStoveIsWorking():boolean;
var tmpStr:string;
begin
 //Проверим, если что-нибудь в буфере,если да-печь работает, приём невозможен
 result:=False;
 tmpStr:='';
 //Form1.BComPort1.ClearBuffer(True,True);
 if Form1.BComPort1.InBufCount>0 then result:=True;
 Form1.BComPort1.ClearBuffer(True,False);
 //ShowMessage(tmpStr);
end;

procedure enabledControls(value:boolean);
begin
 with Form1 do
 begin
  FactorsGrid.Enabled:=value;
  ProfilesGrid.Enabled:=value;
  PresetsGrid.Enabled:=value;
  btnLoadFromDevice.Enabled:=value;
  Button6.Enabled:=value;
  Button1.Enabled:=value;
  if value=False then edtError.ReadOnly:=True else edtError.ReadOnly:=False;
  BitBtn1.Enabled:=value;
  CheckBox1.Enabled:=value;
 end;
end;

procedure freeCommandStack();
var depth,i:integer;
    tmpObj:TStoveCommand;
begin
  depth:=StoveUnit.commandsStack.Count;
  if depth=0 then exit;
  for i:=0 to depth-1 do
  begin
   tmpObj:=StoveUnit.commandsStack[0];
   tmpObj.Free;
   StoveUnit.commandsStack.Delete(0);
  end;
  StoveUnit.commandsStack.Clear;
end;

function sendCommand(value:TStoveCommand;flag:boolean):string;
var commandName,commandText:string;
begin
 result:='';
 commandName:=value.getCommandName();
 commandText:=value.getCommandText();
 if flag=True then commandText:=commandText+#13;
 Form1.Memo1.Lines.Add('Посылаю '+commandName);
 //exit;
 if Form1.BComPort1.Connected
 then
 begin
  Form1.BComPort1.WriteStr(commandText);
 end;
 sleep(100);
end;

procedure reloadStoveParamsError();
begin
 Form1.edtError.Text:=StoveUnit.stoveParams.getErrorValue.getValueString();
end;

procedure reloadStoveParamsResist();
begin
 Form1.edtResist.Text:=StoveUnit.stoveParams.getResistValue.getValueString();
end;

procedure reloadTableFactors();
var i,tableRows:integer;
    objFactors:TStoveDataFactors;
begin
 tableRows:=StoveUnit.tableFactors.getList().Count;
 for i:=1 to tableRows do
 begin
  objFactors:=(StoveUnit.tableFactors.getObject(i-1) as TStoveDataFactors);
  Form1.FactorsGrid.Cells[0,i]:=objFactors.getTemperature().getValueString();
  Form1.FactorsGrid.Cells[1,i]:=objFactors.getPropFactor().getValueString();
  Form1.FactorsGrid.Cells[2,i]:=objFactors.getIntFactor().getValueString();
 end;
end;

procedure reloadTableProfiles();
var i,tableRows:integer;
    objProfiles:TStoveDataProfiles;
begin
 tableRows:=StoveUnit.tableProfiles.getList().Count;
 for i:=1 to tableRows do
 begin
  objProfiles:=(StoveUnit.tableProfiles.getObject(i-1) as TStoveDataProfiles);
  Form1.ProfilesGrid.Cells[0,i]:=objProfiles.getForce().getValueString();
  Form1.ProfilesGrid.Cells[1,i]:=objProfiles.getTimeMinutes().getValueString();
  Form1.ProfilesGrid.Cells[2,i]:=objProfiles.getTimeSec().getValueString();
 end;
end;

procedure reloadTablePresets();
var i,tableRows:integer;
    objPresets:TStoveDataPresets;
begin
 tableRows:=StoveUnit.tablePresets.getList().Count;
 for i:=1 to tableRows do
 begin
  objPresets:=(StoveUnit.tablePresets.getObject(i-1) as TStoveDataPresets);
  Form1.PresetsGrid.Cells[0,i]:=objPresets.getTemperature().getValueString();
  Form1.PresetsGrid.Cells[1,i]:=objPresets.getTimeMinutes().getValueString();
 end;
end;

procedure reloadAll();
begin
 reloadTableFactors();
 reloadTableProfiles();
 reloadTablePresets();
 reloadStoveParamsError();
 reloadStoveParamsResist();
end;

procedure TForm1.FormShow(Sender: TObject);
begin
 StoveUnit.startInit();
 with FactorsGrid do
 begin
  Cells[0,0]:='Темп.';
  Cells[1,0]:='Проп.';
  Cells[2,0]:='Инт.';
  RowCount:=StoveUnit.tableFactors.getDepth+1;
  reloadTableFactors();
 end;
 with ProfilesGrid do
 begin
  Cells[0,0]:='Сила';
  Cells[1,0]:='Время мин.';
  Cells[2,0]:='Время сек.';
  RowCount:=StoveUnit.tableProfiles.getDepth+1;
  reloadTableProfiles();
 end;
 with PresetsGrid do
 begin
  Cells[0,0]:='Темп.';
  Cells[1,0]:='Время мин.';
  RowCount:=StoveUnit.tablePresets.getDepth+1;
  reloadTablePresets();
 end;
 reloadStoveParamsError();
 reloadStoveParamsResist();
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
 reloadAll();
end;

procedure setParamsError(value:integer);
begin
 StoveUnit.stoveParams.setErrorValue(value);
end;

procedure setParamsResist(value:integer);
begin
 StoveUnit.stoveParams.setResistValue(value);
end;

//Ввод значения в таблицу коэфициентов
procedure setCellTableFactors(curRow,curCol,newValue:integer);
var objFactors:TStoveDataFactors;
    error:string;
begin
 objFactors:=(StoveUnit.tableFactors.getObject(curRow-1) as TStoveDataFactors);
 case curCol of
  0: error:=objFactors.setTemperature(newValue);
  1: error:=objFactors.setPropFactor(newValue);
  2: error:=objFactors.setIntFactor(newValue);
 else error:='Неизвестный параметр.';
 end;

 if error<>'' then
 begin
  MessageDlg(error,mtError,[mbOK],0);
  reloadTableFactors();
 end;
end;

//Ввод значения в таблицу пресетов
procedure setCellTablePresets(curRow,curCol,newValue:integer);
var objFactors:TStoveDataPresets;
    error:string;
begin
 objFactors:=(StoveUnit.tablePresets.getObject(curRow-1) as TStoveDataPresets);
 case curCol of
  0: error:=objFactors.setTemperature(newValue);
  1: error:=objFactors.setTimeMinutes(newValue);
 else error:='Неизвестный параметр.';
 end;

 if error<>'' then
 begin
  MessageDlg(error,mtError,[mbOK],0);
  reloadTablePresets();
 end;
end;

//Ввод значения в таблицу профилей
procedure setCellTableProfiles(curRow,curCol,newValue:integer);
var objFactors:TStoveDataProfiles;
    error:string;
begin
 objFactors:=(StoveUnit.tableProfiles.getObject(curRow-1) as TStoveDataProfiles);
 case curCol of
  0: error:=objFactors.setForce(newValue);
  1: error:=objFactors.setTimeMinutes(newValue);
  2: error:=objFactors.setTimeSec(newValue);
 else error:='Неизвестный параметр.';
 end;

 if error<>'' then
 begin
  MessageDlg(error,mtError,[mbOK],0);
  reloadTableProfiles();
 end;
end;

procedure TForm1.DataGridKeyPress(Sender: TObject; var Key: Char);
var curCol,curRow,newValue:integer;
    newValueStr:string;
begin
 //Только цифры
 //if (not (Key in digits))and(Key<>#13) then begin Key:=#0;exit;end;
 if Key=#13 then
 begin
  curCol:=(Sender as TStringGrid).Col;
  curRow:=(Sender as TStringGrid).Row;
  newValueStr:=(Sender as TStringGrid).Cells[curCol,curRow];
  try
   newValue:=StrToInt(newValueStr);
  except
   exit;
  end;

  if (Sender as TStringGrid).Name='FactorsGrid' then setCellTableFactors(curRow,curCol,newValue);
  if (Sender as TStringGrid).Name='PresetsGrid' then setCellTablePresets(curRow,curCol,newValue);
  if (Sender as TStringGrid).Name='ProfilesGrid' then setCellTableProfiles(curRow,curCol,newValue);

 end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var tmpMsg:string;
    tmpObj:TStoveCommand;
    tmpStr:string;
begin
 //Проверим, если что-нибудь в буфере,если да-печь работает, приём невозможен
 if verStoveIsWorking()=True then
 begin
  MessageDlg('Возможно, устройство в режиме нагрева.Сейчас передача и чтение данных невозможна!',mtError,[mbOk],0);
  exit;
 end;

 tmpMsg:='Вы действительно хотите записать данные в постоянную память устройства?';
 tmpMsg:=tmpMsg+'Это действие нельзя отменить!';
 if MessageDlg(tmpMsg,mtWarning,[mbYes,mbNo],0)=mrNo then exit;
 MessageDlg('Нажмите ОК что-бы продолжить.',mtConfirmation,[mbOk],0);

  //Запись всех параметров в устройсво
 freeCommandStack();
 tmpObj:=TStoveCommand.Create(WriteError);
 commandsStack.Add(tmpObj);
 tmpObj:=TStoveCommand.Create(WriteFactors);
 commandsStack.Add(tmpObj);
 tmpObj:=TStoveCommand.Create(WritePresets);
 commandsStack.Add(tmpObj);
 tmpObj:=TStoveCommand.Create(WriteProfiles);
 commandsStack.Add(tmpObj);
 tmpObj:=TStoveCommand.Create(WriteROM);
 commandsStack.Add(tmpObj);

 tmpObj:=commandsStack.Items[0];
 sendCommand(tmpObj,True);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 //список COM портов
 EnumComPorts(ComPorts.Items);
 ComPorts.ItemIndex:=0;
 ComSpeed.ItemIndex:=9;
 Button3.Enabled:=False;
 commandsStack:=TList.Create;
 tmpStr:='';
 enabledControls(False);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 BComPort1.Port:=ComPorts.Text;
 BComPort1.BaudRate:=TBaudRate(ComSpeed.ItemIndex);
 //BComPort1.Timeouts.ReadTotalConstant := 2000;
 if BComPort1.Open then
 begin
  ComPorts.Enabled:=False;
  Button2.Enabled:=False;
  Button3.Enabled:=True;
  CheckBox1.Checked:=False;
  enabledControls(True);
 end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
 if BComPort1.Close then
 begin
  ComPorts.Enabled:=True;
  Button2.Enabled:=True;
  Button3.Enabled:=False;
  CheckBox1.Checked:=False;
  Timer1.Enabled:=False;
  enabledControls(False);
 end;
end;

procedure TForm1.ComSpeedChange(Sender: TObject);
begin
 BComPort1.BaudRate:=TBaudRate(ComSpeed.ItemIndex);
 BComPort1.EndUpdate;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
 Memo1.Clear;
end;

procedure TForm1.BComPort1RxChar(Sender: TObject; Count: Integer);
var
  S: String;
  curCommand:TStoveCommand;
  depth:integer;
  error:string;
begin
  depth:=StoveUnit.commandsStack.Count;
  if depth=0 then exit;
  BComPort1.ReadStr(S, Count);
  curCommand:=StoveUnit.commandsStack[0];
  error:='';
  error:=curCommand.executeCommand(curCommand.getCommand(),Trim(S));
  Memo1.Lines.Add('..Результат '+error);
  Memo1.Lines.Add('..Принято '+curCommand.getCommandName()+' '+S);
  curCommand.Free;
  StoveUnit.commandsStack.Delete(0);
  depth:=StoveUnit.commandsStack.Count;
  if depth=0 then begin reloadAll();exit;end;
  sendCommand(StoveUnit.commandsStack[0],True);
end;

procedure TForm1.btnLoadFromDeviceClick(Sender: TObject);
var tmpObj:TStoveCommand;
    tmpStr:string;
begin
 //Проверим, если что-нибудь в буфере,если да-печь работает, приём невозможен
 if verStoveIsWorking()=True then
 begin
  MessageDlg('Возможно, устройство в режиме нагрева.Сейчас передача и чтение данных невозможна!',mtError,[mbOk],0);
  exit;
 end;
 //Чтение всех параметров из устройсва
 freeCommandStack();
 tmpObj:=TStoveCommand.Create(ReadError);
 commandsStack.Add(tmpObj);
 tmpObj:=TStoveCommand.Create(ReadResist);
 commandsStack.Add(tmpObj);
 tmpObj:=TStoveCommand.Create(ReadFactors);
 commandsStack.Add(tmpObj);
 tmpObj:=TStoveCommand.Create(ReadPresets);
 commandsStack.Add(tmpObj);
 tmpObj:=TStoveCommand.Create(ReadProfiles);
 commandsStack.Add(tmpObj);

 tmpObj:=commandsStack.Items[0];
 sendCommand(tmpObj,True);
end;

procedure TForm1.edtKeyPress(Sender: TObject; var Key: Char);
var newValueStr:string;
    newValue:integer;
begin
 if Key=#13 then
 begin
  newValueStr:=(Sender as TEdit).Text;
  try
   newValue:=StrToInt(newValueStr);
  except
   exit;
  end;

  if (Sender as TEdit).Name='edtError'
  then
  begin
   setParamsError(newValue);
   reloadStoveParamsResist();
  end;
  if (Sender as TEdit).Name='edtResist'
  then
  begin
   setParamsResist(newValue);
  end;
 end;
end;

procedure TForm1.Button6Click(Sender: TObject);
var tmpObj:TStoveCommand;
begin
 if verStoveIsWorking()=True then
 begin
  MessageDlg('Возможно, устройство в режиме нагрева.Сейчас передача и чтение данных невозможна!',mtError,[mbOk],0);
  exit;
 end;

 //Запись всех параметров в устройсво
 freeCommandStack();
 tmpObj:=TStoveCommand.Create(WriteError);
 commandsStack.Add(tmpObj);
 tmpObj:=TStoveCommand.Create(WriteFactors);
 commandsStack.Add(tmpObj);
 tmpObj:=TStoveCommand.Create(WritePresets);
 commandsStack.Add(tmpObj);
 tmpObj:=TStoveCommand.Create(WriteProfiles);
 commandsStack.Add(tmpObj);

 tmpObj:=commandsStack.Items[0];
 sendCommand(tmpObj,True);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var str:string;
    tmpValue:integer;
    tmpTimeEnd:TTimeStamp;
    tmpTimeWork:Longint;
begin
 //Читаем данные с включённой печи.
 BComPort1.ReadStr(str, 22);
 if str='' then exit;
 Memo1.Lines.Add('На входе '+str);
 StoveUnit.stoveResponse.setDataStr(Trim(str));
 tmpValue:=StoveUnit.stoveResponse.getTemperature().getValue();
 tmpTimeEnd := DateTimeToTimeStamp(Now);
 tmpTimeWork:=Round((tmpTimeEnd.Time - tmpTimeBegin.Time)/1000);
 Form1.Series1.AddXY(tmpTimeWork,tmpValue);
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
 if CheckBox1.Checked then
 begin
  Timer1.Enabled:=True;
  StoveInterface.tmpTimeBegin:=DateTimeToTimeStamp(Now);
 end
 else Timer1.Enabled:=False;
end;

procedure TForm1.Button5Click(Sender: TObject);
var str:string;
    tmp:TDateTime;
    Total: LongWord;
begin
 ShowMessage(IntToStr(Round(1.45)));
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
 Form1.Series1.Clear;
end;

procedure TForm1.ProfilesGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
 with Sender as TStringGrid do
 begin
  if ARow>5 then
  begin
   Canvas.FillRect(Rect);
   Canvas.Brush.Color:=clOlive;
  end;
 end;
end;

end.

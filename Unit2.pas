//� ���� ������ ����������� ��� ������ �������� ������
unit Unit2;
interface
 uses Classes,SysUtils;
 type
 //*************************
 //������� ����� ���� ������
 TStoveValue=class(TObject)
 private
  _error:string;
  //����� ��������. �� ������� ������� ���������� ������.
  _mask:string;
 public
 end;

 //����� ��� ����� ��������
 TStoveValueInt=class(TStoveValue)
 private
  _minValue:integer;
  _maxValue:integer;
  _value:integer;
 public
  constructor Create;overload;
  constructor Create(min,max:integer;mask:string);overload;
  //��������� ��������� ��������.���������� ����� ������.
  function setValue(value:integer):string;
  function getValue():integer;
  function getValueString():string;
  function getValueStringExt():string;
  //��������� �������� min/max
  function getMinValue():integer;
  function getMaxValue():integer;
 end;

 //*************************
 //������� ����� ��� �������� ������ � �������
 TStoveData=class(TObject)
 private
  //������������ ������� ������� ��� ������� ����
  _maxDepth:integer;
 public
  procedure setMaxDepth(value:integer);
  function getMaxDepth():integer;
 end;

 //�������, ���������� ������ ������� ������������
 //�����������(60-241) ����������������(0-99) �������(0-99)
 TStoveDataFactors=class(TStoveData)
 private
  //�����������
  _temperature:TStoveValueInt;
  //����������� ������������������
  _propFactor:TStoveValueInt;
  //������������ �����������
  _intFactor:TStoveValueInt;
 public
  constructor Create;overload;
  function setTemperature(value:integer):string;
  function setPropFactor(value:integer):string;
  function setIntFactor(value:integer):string;

  function getTemperature():TStoveValue;
  function getPropFactor():TStoveValue;
  function getIntFactor():TStoveValue;
 end;

 //�������, ���������� ������ ������� �������������
 //�����������(0-100) ����� � �������(0-99) �������(0-59)
 TStoveDataProfiles=class(TStoveData)
 private
  //���� �����������
  _force:TStoveValueInt;
  //����� � �������
  _timeMinutes:TStoveValueInt;
  //����� � ��������
  _timeSec:TStoveValueInt;
 public
  constructor Create;overload;
  function setForce(value:integer):string;
  function setTimeMinutes(value:integer):string;
  function setTimeSec(value:integer):string;

  function getForce():integer;
  function getTimeMinutes():integer;
  function getTimeSec():integer;
 end;

 //�������, ���������� ������ ������� ��������
 //�����������(60-241) ����� � �������(0-99)
 TStoveDataPresets=class(TStoveData)
 private
  //�����������
  _temperature:TStoveValueInt;
  //����� � �������
  _timeMinutes:TStoveValueInt;
 public
  constructor Create;overload;
  function setTemperature(value:integer):string;
  function setTimeMinutes(value:integer):string;

  function getTemperature():integer;
  function getTimeMinutes():integer;
 end;

 //*******************************
 //����� ��� �������� ������ ������
 //������������
 //��������
 //������������
 TStoveTable=class(TObject)
 private
  //����, ��� ���������� ������ TStoveData
  _data:TList;
  //�������� �����
  function getStoveData(dataType:byte):TStoveData;
 public
  //dataType ��� ������, �������� ����������� ����
  //0 TStoveDataFactors
  //1 TStoveDataProfiles
  //2 TStoveDataPresets
  function initTable(dataType:byte):string;
  function getList():TList;
  function getObject(value:integer):TStoveData;
 end;

var
  tableFactors:TStoveTable;
  tablePresets:TStoveTable;
  tableProfiles:TStoveTable;

  procedure startInit();

implementation

 //{���������� ��������� ������.
 //function TStoveValue.getValue():integer;
 //begin
 // result:=0;
 //end;

 constructor TStoveValueInt.Create;
 begin
  _minValue:=0;
  _maxValue:=260;
  _value:=0;
  _error:='';
 end;
 constructor TStoveValueInt.Create(min,max:integer;mask:string);
 begin
  _minValue:=min;
  _maxValue:=max;
  _value:=0;
  _mask:=mask;
  _error:='';
 end;

 function TStoveValueInt.getMinValue():integer;
 begin
  result:=Self._minValue;
 end;

 function TStoveValueInt.getMaxValue():integer;
 begin
  result:=Self._maxValue;
 end;

 function TStoveValueInt.setValue(value:integer):string;
 var
  minValue:integer;
  maxValue:integer;
 begin
  result:='';//����� ����� ������, ���� ��� �� �� ���
  minValue:=Self.getMinValue;
  maxValue:=Self.getMaxValue;
  if value<minValue then result:='�������� ����� ��������� �� ����� ���� ������ '+IntToStr(minValue)+'!';
  if value>maxValue then result:='�������� ����� ��������� �� ����� ���� ������ '+IntToStr(maxValue)+'!';
 end;

 function TStoveValueInt.getValue():integer;
 begin
  result:=Self._value;
 end;

 function TStoveValueInt.getValueString():string;
 begin
  result:=IntToStr(Self._value);
 end;

 function TStoveValueInt.getValueStringExt():string;
 begin
  result:=IntToStr(Self._value);
 end;
 //}���������� ��������� ������.

 //{������������ ����� ������
 //������������� ������������ ������� ������� ��� ����
 procedure TStoveData.setMaxDepth(value:integer);
 begin
  Self._maxDepth:=value;
 end;
 //�������� ������������ ������� �������
 function TStoveData.getMaxDepth():integer;
 begin
  result:=Self._maxDepth;
 end;
 //{���������� ������ ������� ������������
 constructor TStoveDataFactors.Create;
 begin
  Self.setMaxDepth(10);
  _temperature:=TStoveValueInt.Create(60,241,'000');
  _propFactor:=TStoveValueInt.Create(0,99,'00');
  _intFactor:=TStoveValueInt.Create(0,99,'00');
 end;
 //�������
 function TStoveDataFactors.setTemperature(value:integer):string;
 begin
  //�������� ����� ������
  result:=Self._temperature.setValue(value);
 end;
 function TStoveDataFactors.setPropFactor(value:integer):string;
 begin
  //�������� ����� ������
  result:=Self._propFactor.setValue(value);
 end;
 function TStoveDataFactors.setIntFactor(value:integer):string;
 begin
  //�������� ����� ������
  result:=Self._intFactor.setValue(value);
 end;
 //�������
 function TStoveDataFactors.getTemperature():TStoveValue;
 begin
  result:=Self._temperature;
 end;
 function TStoveDataFactors.getPropFactor():TStoveValue;
 begin
  result:=Self._propFactor;
 end;
  function TStoveDataFactors.getIntFactor():TStoveValue;
 begin
  result:=Self._intFactor;
 end;
 //}���������� ������ ������� ������������

 //{���������� ������ ������� �������������
 constructor TStoveDataProfiles.Create;
 begin
  Self.setMaxDepth(5);
  _force:=TStoveValueInt.Create(0,100,'000');
  _timeMinutes:=TStoveValueInt.Create(0,99,'00');
  _timeSec:=TStoveValueInt.Create(0,59,'00');
 end;
 //�������
 function TStoveDataProfiles.setForce(value:integer):string;
 begin
  //�������� ����� ������
  result:=Self._force.setValue(value);
 end;
 function TStoveDataProfiles.setTimeMinutes(value:integer):string;
 begin
  //�������� ����� ������
  result:=Self._timeMinutes.setValue(value);
 end;
 function TStoveDataProfiles.setTimeSec(value:integer):string;
 begin
  //�������� ����� ������
  result:=Self._timeSec.setValue(value);
 end;
 //�������
 function TStoveDataProfiles.getForce():integer;
 begin
  //�������� ����� ������
  result:=Self._force.getValue();
 end;
 function TStoveDataProfiles.getTimeMinutes():integer;
 begin
  //�������� ����� ������
  result:=Self._timeMinutes.getValue();
 end;
 function TStoveDataProfiles.getTimeSec():integer;
 begin
  //�������� ����� ������
  result:=Self._timeSec.getValue();
 end;
 //{���������� ������ ������� �������������

 //{���������� ������ ������� ��������
 constructor TStoveDataPresets.Create;
 begin
  Self.setMaxDepth(8);
  _temperature:=TStoveValueInt.Create(60,241,'000');
  _timeMinutes:=TStoveValueInt.Create(0,99,'00');
 end;
 //�������
 function TStoveDataPresets.setTemperature(value:integer):string;
 begin
  //�������� ����� ������
  result:=Self._temperature.setValue(value);
 end;
 function TStoveDataPresets.setTimeMinutes(value:integer):string;
 begin
  //�������� ����� ������
  result:=Self._timeMinutes.setValue(value);
 end;
 //�������
 function TStoveDataPresets.getTemperature():integer;
 begin
  //�������� ����� ������
  result:=Self._temperature.getValue();
 end;
 function TStoveDataPresets.getTimeMinutes():integer;
 begin
  //�������� ����� ������
  result:=Self._timeMinutes.getValue;
 end;
 //}���������� ������ ������� ��������

 //{������� ������
 //dataType ��� ������, �������� ����������� ����
 //0 TStoveDataFactors � ������� 10 �����
 //1 TStoveDataProfiles           5 �����
 //2 TStoveDataPresets            8 �����
 //�������� �����
 function TStoveTable.getStoveData(dataType:byte):TStoveData;
 begin
  result:=nil;
  if dataType=0 then begin result:=TStoveDataFactors.Create;end;
  if dataType=1 then begin result:=TStoveDataProfiles.Create;end;
  if dataType=2 then begin result:=TStoveDataPresets.Create;end;
 end;

 function TStoveTable.initTable(dataType:byte):string;
 var i:byte;
     maxLength:integer;
     tmp:TStoveData;
 begin
  result:='';
  tmp:=Self.getStoveData(dataType);
  maxLength:=tmp.getMaxDepth;
  tmp.Free;
  //��������� ���� ������� ���������� ���� TStoveData
  Self._data:=TList.Create;
  //� ������������� �������� ������ ��������
  for i:=1 to maxLength do
  begin
   Self._data.Add(Self.getStoveData(dataType))
  end;
 end;

 function TStoveTable.getList():TList;
 begin
  result:=Self._data;
 end;

 function TStoveTable.getObject(value:integer):TStoveData;
 var tmpObj:TStoveData;
 begin
  tmpObj:=Self._data.Items[value];
  //if tmpObj is TStoveDataFactors then result:=(tmpObj as TStoveDataFactors)
  result:=tmpObj;
 end;
 //}������� ������


 //*****************************************************************************
 //��������� �����
 procedure startInit();
 begin
  //������������� ������ � �������
  tableFactors:=TStoveTable.Create;
  tablePresets:=TStoveTable.Create;
  tableProfiles:=TStoveTable.Create;

  tableFactors.initTable(0);
  tablePresets.initTable(1);
  tableProfiles.initTable(2);
 end;
end.
 
//В этом модуле реализованы все классы хранения данных
unit Unit2;
interface
 uses Classes,SysUtils;
 type
 //*************************
 //Базовый класс типа данных
 TStoveValue=class(TObject)
 private
  _error:string;
  //Маска значения. Не занятые разряды заменяются нулями.
  _mask:string;
 public
 end;

 //Класс для целых значений
 TStoveValueInt=class(TStoveValue)
 private
  _minValue:integer;
  _maxValue:integer;
  _value:integer;
 public
  constructor Create;overload;
  constructor Create(min,max:integer;mask:string);overload;
  //Процедура установки значения.Возвращает текст ошибки.
  function setValue(value:integer):string;
  function getValue():integer;
  function getValueString():string;
  function getValueStringExt():string;
  //Получение пределов min/max
  function getMinValue():integer;
  function getMaxValue():integer;
 end;

 //*************************
 //Базовый класс для создания строки с данными
 TStoveData=class(TObject)
 private
  //Максимальная глубина таблицы для данного типа
  _maxDepth:integer;
 public
  procedure setMaxDepth(value:integer);
  function getMaxDepth():integer;
 end;

 //Потомок, реализация строки таблицы коэффициенты
 //Температура(60-241) ИнтегральныйКоэф(0-99) ДифКоэф(0-99)
 TStoveDataFactors=class(TStoveData)
 private
  //Температура
  _temperature:TStoveValueInt;
  //Коэффициент пропорциональности
  _propFactor:TStoveValueInt;
  //Интегральный коэффициент
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

 //Потомок, реализация строки таблицы термопрофилей
 //Воздействие(0-100) Время в минутах(0-99) Секунды(0-59)
 TStoveDataProfiles=class(TStoveData)
 private
  //Сила воздействия
  _force:TStoveValueInt;
  //Время в минутах
  _timeMinutes:TStoveValueInt;
  //Время в секундах
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

 //Потомок, реализация строки таблицы пресетов
 //Температура(60-241) Время в минутах(0-99)
 TStoveDataPresets=class(TStoveData)
 private
  //Температура
  _temperature:TStoveValueInt;
  //Время в минутах
  _timeMinutes:TStoveValueInt;
 public
  constructor Create;overload;
  function setTemperature(value:integer):string;
  function setTimeMinutes(value:integer):string;

  function getTemperature():integer;
  function getTimeMinutes():integer;
 end;

 //*******************************
 //Класс для хранения данных таблиц
 //Коэффициенты
 //Прессеты
 //Термопрофиль
 TStoveTable=class(TObject)
 private
  //Лист, где содержатся строки TStoveData
  _data:TList;
  //Селектор типов
  function getStoveData(dataType:byte):TStoveData;
 public
  //dataType тип данных, которыми заполняется лист
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

 //{Реализация атомарной записи.
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
  result:='';//Вернём текст ошибки, если что то не так
  minValue:=Self.getMinValue;
  maxValue:=Self.getMaxValue;
  if value<minValue then result:='Значение этого параметра не может быть меньше '+IntToStr(minValue)+'!';
  if value>maxValue then result:='Значение этого параметра не может быть больше '+IntToStr(maxValue)+'!';
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
 //}Реализация атомарной записи.

 //{Родительский класс данных
 //Устанавливает максимальную глубину таблицы для типа
 procedure TStoveData.setMaxDepth(value:integer);
 begin
  Self._maxDepth:=value;
 end;
 //Получает максимальную глубину таблицы
 function TStoveData.getMaxDepth():integer;
 begin
  result:=Self._maxDepth;
 end;
 //{Реализация строки таблицы коэффициенты
 constructor TStoveDataFactors.Create;
 begin
  Self.setMaxDepth(10);
  _temperature:=TStoveValueInt.Create(60,241,'000');
  _propFactor:=TStoveValueInt.Create(0,99,'00');
  _intFactor:=TStoveValueInt.Create(0,99,'00');
 end;
 //сеттеры
 function TStoveDataFactors.setTemperature(value:integer):string;
 begin
  //Выбросим текст ошибки
  result:=Self._temperature.setValue(value);
 end;
 function TStoveDataFactors.setPropFactor(value:integer):string;
 begin
  //Выбросим текст ошибки
  result:=Self._propFactor.setValue(value);
 end;
 function TStoveDataFactors.setIntFactor(value:integer):string;
 begin
  //Выбросим текст ошибки
  result:=Self._intFactor.setValue(value);
 end;
 //геттеры
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
 //}Реализация строки таблицы коэффициенты

 //{Реализация строки таблицы термопрофилей
 constructor TStoveDataProfiles.Create;
 begin
  Self.setMaxDepth(5);
  _force:=TStoveValueInt.Create(0,100,'000');
  _timeMinutes:=TStoveValueInt.Create(0,99,'00');
  _timeSec:=TStoveValueInt.Create(0,59,'00');
 end;
 //сеттеры
 function TStoveDataProfiles.setForce(value:integer):string;
 begin
  //Выбросим текст ошибки
  result:=Self._force.setValue(value);
 end;
 function TStoveDataProfiles.setTimeMinutes(value:integer):string;
 begin
  //Выбросим текст ошибки
  result:=Self._timeMinutes.setValue(value);
 end;
 function TStoveDataProfiles.setTimeSec(value:integer):string;
 begin
  //Выбросим текст ошибки
  result:=Self._timeSec.setValue(value);
 end;
 //геттеры
 function TStoveDataProfiles.getForce():integer;
 begin
  //Выбросим текст ошибки
  result:=Self._force.getValue();
 end;
 function TStoveDataProfiles.getTimeMinutes():integer;
 begin
  //Выбросим текст ошибки
  result:=Self._timeMinutes.getValue();
 end;
 function TStoveDataProfiles.getTimeSec():integer;
 begin
  //Выбросим текст ошибки
  result:=Self._timeSec.getValue();
 end;
 //{Реализация строки таблицы термопрофилей

 //{Реализация строки таблицы пресетов
 constructor TStoveDataPresets.Create;
 begin
  Self.setMaxDepth(8);
  _temperature:=TStoveValueInt.Create(60,241,'000');
  _timeMinutes:=TStoveValueInt.Create(0,99,'00');
 end;
 //Сеттеры
 function TStoveDataPresets.setTemperature(value:integer):string;
 begin
  //Выбросим текст ошибки
  result:=Self._temperature.setValue(value);
 end;
 function TStoveDataPresets.setTimeMinutes(value:integer):string;
 begin
  //Выбросим текст ошибки
  result:=Self._timeMinutes.setValue(value);
 end;
 //геттеры
 function TStoveDataPresets.getTemperature():integer;
 begin
  //Выбросим текст ошибки
  result:=Self._temperature.getValue();
 end;
 function TStoveDataPresets.getTimeMinutes():integer;
 begin
  //Выбросим текст ошибки
  result:=Self._timeMinutes.getValue;
 end;
 //}Реализация строки таблицы пресетов

 //{Таблица данных
 //dataType тип данных, которыми заполняется лист
 //0 TStoveDataFactors в таблице 10 строк
 //1 TStoveDataProfiles           5 строк
 //2 TStoveDataPresets            8 строк
 //селектор типов
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
  //Заполняем лист пустыми значениями типа TStoveData
  Self._data:=TList.Create;
  //В конструкторах задаются пороги значений
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
 //}Таблица данных


 //*****************************************************************************
 //Процедуры юнита
 procedure startInit();
 begin
  //инициализирую классы с данными
  tableFactors:=TStoveTable.Create;
  tablePresets:=TStoveTable.Create;
  tableProfiles:=TStoveTable.Create;

  tableFactors.initTable(0);
  tablePresets.initTable(1);
  tableProfiles.initTable(2);
 end;
end.
 
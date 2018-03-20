//В этом модуле реализованы все классы хранения данных
unit StoveUnit;
interface
 uses Classes,SysUtils;

 type
 TStoveCommands=(WriteROM,Unknown,WriteError,ReadError,ReadResist,WriteFactors,ReadFactors,WritePresets,ReadPresets,WriteProfiles,ReadProfiles);

 TStoveCommand=class(TObject)
 private
 //Название команды
  _command:TStoveCommands;
  //На человеческом
  _commandName:string;
  //Для отсылки на устройство
  _commandText:string;
 public
  constructor Create(value:TStoveCommands);overload;
  function getCommandName():string;
  function getCommandText():string;
  procedure setCommand(value:TStoveCommands);
  function getCommand():TStoveCommands;
  //Действия команды
  //value комнда
  //args аргументы, в нашем случае строка
  //error текст ошибки или успешности выполнения
  //Возвращает статус операции
  function executeCommand(value:TStoveCommands;args:string):string;
 end;

 //Общие методы класса TStove
 TStoveUtils=class(TObject)
 private
 public
  //Функция, возвращает следующий токкен из строки
  class function getToken(var value:string):string;
 end;
 //*************************
 //Базовый класс типа данных
 TStoveValue=class(TObject)
 private
  _error:string;
  //Маска значения. Не занятые разряды заменяются нулями.
  _mask:string;
  function getMask():string;
 public
  //Процедура установки значения.Возвращает текст ошибки.
  function setValue(value:integer):string;virtual;abstract;
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
  function setValue(value:integer):string;override;
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
  //Количество параметров в строке
  _propCount:integer;
 public
  procedure setMaxDepth(value:integer);
  function getMaxDepth():integer;
  //Получение данных в строку
  function getDataStr():string;virtual;abstract;
  //Запись данных из строки
  function setDataStr(value:string):string;virtual;abstract;

  function getPropCount():integer;
  procedure setPropCount(value:integer);

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

  function getTemperature():TStoveValueInt;
  function getPropFactor():TStoveValueInt;
  function getIntFactor():TStoveValueInt;
  //Получение всех параметров в одну строку
  function getDataStr():string;override;
  //Запись данных из строки
  function setDataStr(value:string):string;override;
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

  function getForce():TStoveValueInt;
  function getTimeMinutes():TStoveValueInt;
  function getTimeSec():TStoveValueInt;
  //Получение всех параметров в одну строку
  function getDataStr():string;override;
  //Запись данных из строки
  function setDataStr(value:string):string;override;
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

  function getTemperature():TStoveValueInt;
  function getTimeMinutes():TStoveValueInt;
  //Получение всех параметров в одну строку
  function getDataStr():string;override;
  //Запись данных из строки
  function setDataStr(value:string):string;override;
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
  function getDepth():integer;
  //Таблица в одну строку
  function getTableStr():string;
  //Загрузка в таблицу данных из строки
  //Формат такой же, как при отправке в терминал
  function setTableStr(value:string):string;
 end;

 //Параметры класса
 TStoveParams=class(TObject)
 public
  constructor Create;overload;
  function getErrorValue():TStoveValueInt;
  function setErrorValue(value:integer):string;
  function getResistValue():TStoveValueInt;
  function setResistValue(value:integer):string;
  function setResistValueStr(value:string):string;
  function setErrorValueStr(value:string):string;
 private
  _errorValue:TStoveValueInt;
  _resistValue:TStoveValueInt;
 end;

 TStoveDataResponse=class(TStoveData)
 public
  constructor Create;overload;
  function getTemperature():TStoveValueInt;
  function getForce():TStoveValueInt;
  function getPropFactor():TStoveValueInt;
  function geIntFactor():TStoveValueInt;
  function setTemperture(value:integer):string;
  function setForce(value:integer):string;
  function setPropFactor(value:integer):string;
  function setIntFactor(value:integer):string;
  function setDataStr(value:string):string;
 private
  _temperature:TStoveValueInt;
  _force:TStoveValueInt;
  _propFactor:TStoveValueInt;
  _intFactor:TStoveValueInt;
 end;
var
  tableFactors:TStoveTable;
  tablePresets:TStoveTable;
  tableProfiles:TStoveTable;
  stoveParams:TStoveParams;
  commandsStack:TList;
  stoveResponse:TStoveDataResponse;

  procedure startInit();

implementation
 //{Класс для стэка команд
 constructor TStoveCommand.Create(value:TStoveCommands);
 begin
  Self.setCommand(value);
 end;

 function TStoveCommand.getCommandName():string;
 begin
  result:=_commandName;
 end;

 function TStoveCommand.getCommandText():string;
 begin
  result:=_commandText;
 end;

 procedure TStoveCommand.setCommand(value:TStoveCommands);
 begin
  Self._command:=value;
  case value of
   WriteROM:begin _commandName:='Запись в ROM';_commandText:='s';end;
   WriteError:begin _commandName:='Запись ошибки';_commandText:='1o'+' '+StoveUnit.stoveParams.getErrorValue().getValueString();end;
   ReadError:begin _commandName:='Чтение ошибки';_commandText:='2o';end;
   ReadResist:begin _commandName:='Чтение сопротивления';_commandText:='r';end;
   WriteFactors:begin _commandName:='Запись коэффициентов';_commandText:='1c'+' '+StoveUnit.tableFactors.getTableStr();end;
   ReadFactors:begin _commandName:='Чтение коэффициентов';_commandText:='2c';end;
   WritePresets:begin _commandName:='Запись пресетов';_commandText:='1h'+' '+StoveUnit.tablePresets.getTableStr();end;
   ReadPresets:begin _commandName:='Чтение пресетов';_commandText:='2h';end;
   WriteProfiles:begin _commandName:='Запись термопрофилей';_commandText:='1p'+' '+StoveUnit.tableProfiles.getTableStr();end;
   ReadProfiles:begin _commandName:='Чтение термопрофилей';_commandText:='2p';end;
  end;
 end;
 //}
 //{Реализация атомарной записи.
 function TStoveValue.getMask():string;
 begin
  result:=Self._mask;
 end;

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
  if (value<minValue)and(value<>0) then
  begin
   result:='Значение этого параметра не может быть меньше '+IntToStr(minValue)+'!';
   exit;
  end;

  if value>maxValue then
  begin
   result:='Значение этого параметра не может быть больше '+IntToStr(maxValue)+'!';
   exit;
  end;
  Self._value:=value;
 end;

 function TStoveValueInt.getValue():integer;
 begin
  result:=Self._value;
 end;

 function TStoveValueInt.getValueString():string;
 begin
  result:=IntToStr(Self._value);
 end;

 //Вывод значения строкой с использованием маски.
 //Отсутствующие разряды заменяются знаками из маски
 function TStoveValueInt.getValueStringExt():string;
 var mask,value:string;
     tmp:integer;
 begin
  mask:=Self.getMask();
  value:=Self.getValueString();
  result:=value;
  tmp:=Length(mask)-Length(value);
  if tmp<=0 then exit;
  result:=Copy(mask,1,Length(mask)-Length(value))+value;
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
 //Число параметров в данной строке
 function TStoveData.getPropCount():integer;
 begin
  result:=Self._propCount;
 end;
 procedure TStoveData.setPropCount(value:integer);
 begin
  Self._propCount:=value;
 end;

 //{Реализация строки таблицы коэффициенты
 constructor TStoveDataFactors.Create;
 begin
  Self.setMaxDepth(10);
  Self.setPropCount(3);
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
 function TStoveDataFactors.getTemperature():TStoveValueInt;
 begin
  result:=Self._temperature;
 end;
 function TStoveDataFactors.getPropFactor():TStoveValueInt;
 begin
  result:=Self._propFactor;
 end;
 function TStoveDataFactors.getIntFactor():TStoveValueInt;
 begin
  result:=Self._intFactor;
 end;

  //Получение всех параметров в одну строку
 function TStoveDataFactors.getDataStr():string;
 begin
  result:=Self._temperature.getValueStringExt();
  result:=result+' '+Self._propFactor.getValueStringExt();
  result:=result+' '+Self._intFactor.getValueStringExt();
 end;
 //Данные из строки
 function TStoveDataFactors.setDataStr(value:string):string;
 var tmp1,tmp2,tmp3:integer;
     error:string;
 begin
  result:='';
  tmp1:=0;tmp2:=0;tmp3:=0;
  try
   tmp1:=StrToInt(TStoveUtils.getToken(value));
   tmp2:=StrToInt(TStoveUtils.getToken(value));
   tmp3:=StrToInt(TStoveUtils.getToken(value));
  except
  end;
  error:=Self.setTemperature(tmp1);
  error:=Self.setPropFactor(tmp2);
  error:=Self.setIntFactor(tmp3);
  result:=value;
 end;
 //}Реализация строки таблицы коэффициенты

 //{Реализация строки таблицы термопрофилей
 constructor TStoveDataProfiles.Create;
 begin
  Self.setMaxDepth(10);
  Self.setPropCount(3);
  _force:=TStoveValueInt.Create(0,100,'000');
  _timeMinutes:=TStoveValueInt.Create(-1,99,'00');
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
 function TStoveDataProfiles.getForce():TStoveValueInt;
 begin
  //Выбросим текст ошибки
  result:=Self._force;
 end;
 function TStoveDataProfiles.getTimeMinutes():TStoveValueInt;
 begin
  //Выбросим текст ошибки
  result:=Self._timeMinutes;
 end;
 function TStoveDataProfiles.getTimeSec():TStoveValueInt;
 begin
  //Выбросим текст ошибки
  result:=Self._timeSec;
 end;

  //Получение всех параметров в одну строку
 function TStoveDataProfiles.getDataStr():string;
 begin
  result:=Self._force.getValueStringExt();
  result:=result+' '+Self._timeMinutes.getValueStringExt();
  result:=result+' '+Self._timeSec.getValueStringExt();
 end;

 //Данные из строки
 function TStoveDataProfiles.setDataStr(value:string):string;
 var tmp1,tmp2,tmp3:integer;
     error:string;
 begin
  result:='';
  tmp1:=0;tmp2:=0;tmp3:=0;
  try
   tmp1:=StrToInt(TStoveUtils.getToken(value));
   tmp2:=StrToInt(TStoveUtils.getToken(value));
   tmp3:=StrToInt(TStoveUtils.getToken(value));
  except
  end;
  error:=Self.setForce(tmp1);
  error:=Self.setTimeMinutes(tmp2);
  error:=Self.setTimeSec(tmp3);
  result:=value;
 end;
 //}Реализация строки таблицы термопрофилей

 //{Реализация строки таблицы пресетов
 constructor TStoveDataPresets.Create;
 begin
  Self.setMaxDepth(8);
  Self.setPropCount(2);
  _temperature:=TStoveValueInt.Create(60,241,'000');
  _timeMinutes:=TStoveValueInt.Create(-1,99,'00');
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
 function TStoveDataPresets.getTemperature():TStoveValueInt;
 begin
  //Выбросим текст ошибки
  result:=Self._temperature;
 end;
 function TStoveDataPresets.getTimeMinutes():TStoveValueInt;
 begin
  //Выбросим текст ошибки
  result:=Self._timeMinutes;
 end;
 //Получение всех параметров в одну строку
 function TStoveDataPresets.getDataStr():string;
 begin
  result:=Self._temperature.getValueStringExt();
  result:=result+' '+Self._timeMinutes.getValueStringExt();
 end;

 //Данные из строки
 function TStoveDataPresets.setDataStr(value:string):string;
 var tmp1,tmp2,tmp3:integer;
     error:string;
 begin
  result:='';
  tmp1:=0;tmp2:=0;tmp3:=0;
  try
   tmp1:=StrToInt(TStoveUtils.getToken(value));
   tmp2:=StrToInt(TStoveUtils.getToken(value));
  except
  end;
  error:=Self.setTemperature(tmp1);
  error:=Self.setTimeMinutes(tmp2);
  result:=value;
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

 function TStoveTable.getDepth():integer;
 begin
  result:=Self._data.Count;
 end;

 function TStoveTable.getObject(value:integer):TStoveData;
 var tmpObj:TStoveData;
 begin
  tmpObj:=Self._data.Items[value];
  //if tmpObj is TStoveDataFactors then result:=(tmpObj as TStoveDataFactors)
  result:=tmpObj;
 end;

 //Таблица в одну строку
 function TStoveTable.getTableStr():string;
 var depth,i:integer;
     tmp:string;
     tmpObj:TStoveData;
 begin
  result:='';
  depth:=Self.getDepth();
  if depth=0 then exit;
  tmp:='';
  for i:=0 to depth-1 do
  begin
   tmpObj:=Self.getObject(i);
   tmp:=tmp+tmpObj.getDataStr()+' ';
  end;
  if tmp<>'' then tmp:=Copy(tmp,1,Length(tmp)-1);
  result:=tmp;
 end;

 //Загрузка в таблицу данных из строки
 //Формат такой же, как при отправке в терминал
 function TStoveTable.setTableStr(value:string):string;
 var depth,i:integer;
     tmpObj:TStoveData;
 begin
  //Выбрасывает текст ошибки
  result:='';
  depth:=Self.getDepth();
  for i:=0 to depth-1 do
  begin
   tmpObj:=Self.getObject(i);
   value:=tmpObj.setDataStr(value);
  end;
 end;
 //}Таблица данных
 //{Параметры класса
 constructor TStoveParams.Create;
 begin
  Self._errorValue:=TStoveValueInt.Create(0,10000,'00000');
  Self._resistValue:=TStoveValueInt.Create(0,10000,'00000');
 end;

 function TStoveParams.getErrorValue():TStoveValueInt;
 begin
  result:=Self._errorValue;
 end;

 function TStoveParams.setErrorValue(value:integer):string;
 begin
  result:=Self._errorValue.setValue(value);
 end;

 function TStoveParams.getResistValue():TStoveValueInt;
 begin
  result:=Self._resistValue;
 end;

 function TStoveParams.setResistValue(value:integer):string;
 begin
  result:=Self._resistValue.setValue(value);
 end;

 function TStoveParams.setResistValueStr(value:string):string;
 begin
  try
   result:=Self.setResistValue(StrToInt(value));
  except
   result:='Данные должны иметь числовой тип!';
  end;
 end;

 function TStoveParams.setErrorValueStr(value:string):string;
 begin
  try
   result:=Self.setErrorValue(StrToInt(value));
  except
   result:='Данные должны иметь числовой тип!';
  end;
 end;
 //}

 //{TStoveResponse
 constructor TStoveDataResponse.Create;
 begin
  Self.setMaxDepth(8);
  Self.setPropCount(2);
  Self._temperature:=TStoveValueInt.Create(0,1000,'0000');
  Self._force:=TStoveValueInt.Create(0,1000,'0000');
  Self._propFactor:=TStoveValueInt.Create(-100000,100000,'00000000');
  Self._intFactor:=TStoveValueInt.Create(-100000,100000,'00000000');
 end;

 function TStoveDataResponse.getTemperature():TStoveValueInt;
 begin
  result:=Self._temperature;
 end;

 function TStoveDataResponse.getForce():TStoveValueInt;
 begin
  result:=Self._force;
 end;

 function TStoveDataResponse.getPropFactor():TStoveValueInt;
 begin
  result:=Self._propFactor;
 end;

 function TStoveDataResponse.geIntFactor():TStoveValueInt;
 begin
  result:=Self._intFactor;
 end;

 function TStoveDataResponse.setTemperture(value:integer):string;
 begin
  result:=Self._temperature.setValue(value);
 end;

 function TStoveDataResponse.setForce(value:integer):string;
 begin
  result:=Self._force.setValue(value);
 end;

 function TStoveDataResponse.setPropFactor(value:integer):string;
 begin
  result:=Self._propFactor.setValue(value);
 end;

 function TStoveDataResponse.setIntFactor(value:integer):string;
 begin
  result:=Self._intFactor.setValue(value);
 end;

  //Данные из строки
 function TStoveDataResponse.setDataStr(value:string):string;
 var tmp1,tmp2,tmp3,tmp4:integer;
     error:string;
 begin
  result:='';
  tmp1:=0;tmp2:=0;tmp3:=0;
  try
   tmp1:=StrToInt(TStoveUtils.getToken(value));
   tmp2:=StrToInt(TStoveUtils.getToken(value));
   tmp3:=StrToInt(TStoveUtils.getToken(value));
   tmp4:=StrToInt(TStoveUtils.getToken(value));
  except
  end;
  error:=Self.setTemperture(tmp1);
  error:=Self.setForce(tmp2);
  error:=Self.setPropFactor(tmp3);
  error:=Self.setIntFactor(tmp4);
  result:=value;
 end;
 //}
 //Запуск команды TStoveCommands
 //Действия, которые она выполняет
 function TStoveCommand.executeCommand(value:TStoveCommands;args:string):string;
 begin
  //Результат операции

  case value of
   WriteROM:
    begin
     result:=args;
    end;
   ReadError:
    begin
     result:=stoveParams.setErrorValueStr(args);
    end;
   ReadResist:
    begin
     result:=stoveParams.setResistValueStr(args);
    end;
   ReadFactors:
    begin
     result:=tableFactors.setTableStr(args);
    end;
   ReadPresets:
    begin
     result:=tablePresets.setTableStr(args);
    end;
   ReadProfiles:
    begin
     result:=tableProfiles.setTableStr(args);
    end;
   WriteFactors:
    begin
     result:=args;
    end;
   WritePresets:
    begin
     result:=args;
    end;
   WriteProfiles:
    begin
     result:=args;
    end;
   WriteError:
    begin
     result:=args;
    end;
  end;
  if result='' then result:='Ok';
 end;

 function TStoveCommand.getCommand():TStoveCommands;
 begin
  result:=Self._command;
 end;
 //

 //Утилиты

 //Функция, возвращает следующий токкен из строки
 class function TStoveUtils.getToken(var value:string):string;
 var position:integer;
 begin
  //Первое вхождение разделителя
  position:=AnsiPos(' ',value);
  if position=0 then begin result:=value;exit;end;
  result:=Copy(value,0,position-1);
  value:=Copy(value,position+1,Length(value));
 end;
 //*****************************************************************************
 //Процедуры юнита
 procedure startInit();
 begin
  //инициализирую классы с данными
  tableFactors:=TStoveTable.Create;
  tablePresets:=TStoveTable.Create;
  tableProfiles:=TStoveTable.Create;
  stoveParams:=TStoveParams.Create;
  stoveResponse:=TStoveDataResponse.Create;
  
  tableFactors.initTable(0);
  tableProfiles.initTable(1);
  tablePresets.initTable(2);
 end;
end.
 
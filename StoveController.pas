// ласс контроллер
unit StoveController;
interface
uses Unit2;
var
  tableFactors:TStoveTable;
  tablePresets:TStoveTable;
  tableProfiles:TStoveTable;

  procedure startInit();
implementation

 procedure startInit();
 begin
  //инициализирую классы с данными
  tableFactors:=TStoveTable.Create;
  tableFactors:=TStoveTable.Create;
  tableFactors:=TStoveTable.Create;

  tableFactors.initTable(0);
  tableFactors.initTable(1);
  tableFactors.initTable(2);
 end;
end.

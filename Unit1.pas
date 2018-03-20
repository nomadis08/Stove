unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, Buttons;

type
  TForm1 = class(TForm)
    Button1: TButton;
    StringGrid1: TStringGrid;
    BitBtn1: TBitBtn;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses Unit2;
{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
 Unit2.startInit();
end;

procedure TForm1.FormShow(Sender: TObject);
begin
 Unit2.startInit();
 with StringGrid1 do
 begin
  Cells[0,0]:='Темп.';
  Cells[1,0]:='Проп.';
  Cells[2,0]:='Инт.';
 end;

end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var i,maxLength:integer;
    tmpList:TList;
    s1:string;
    obj:TStoveData;
    obj2:TStoveValueInt;
begin
 //tmpList:=Unit2.tableFactors.getList();
 //maxLength:=tmpList.Count;
 obj:=Unit2.tableFactors.getObject(1);
 //obj2:=(obj.getTemperature() as TStoveValueInt);
 ShowMessage(obj2.getValueString());
 //for i:=1 to maxLength do
 //begin
 //StringGrid1.Cells[0,i]:=Unit2.tableFactors.getList().getTemperature().getValueString();
 //end;
end;

end.

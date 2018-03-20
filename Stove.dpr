program Stove;

uses
  Forms,
  StoveInterface in 'StoveInterface.pas' {Form1},
  StoveUnit in 'StoveUnit.pas',
  StoveController in 'StoveController.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

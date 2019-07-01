program ScannerDemo;

uses
  Forms,
  main in 'main.pas' {MainForm},
  uScanner in 'uScanner.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TMainForm = class(TForm)
    Memo1: TMemo;
    Memo2: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uScanner;

procedure TMainForm.Button1Click(Sender: TObject);
var
  tk: TTokenRec;
  scan: TScanner;
begin
  Memo2.Clear;
  scan.Init(PChar(Memo1.Text));
  while True do begin
    tk := scan.getToken();
    Memo2.Lines.Add(format('%s %.*s', [GetTokenStr(tk.kind), tk.length, tk.start]));
    if (tk.kind = tkERR) then Break;
    if (tk.kind = tkEOS) then Break;
  end;
end;

end.

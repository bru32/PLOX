unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TMainForm = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Memo2: TMemo;
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
  token: TToken;
  scan: TScanner;
begin
  scan.init(PChar(Memo1.Text));
  while True do begin
    token := scan.getToken();
    Memo2.Lines.Add(format('%s %.*s', [GetTokenStr(token.TokenType), token.length, token.start]));
    if (token.TokenType = TOKEN_ERROR) then Break;
    if (token.TokenType = TOKEN_EOF) then Break;
  end;
end;

end.

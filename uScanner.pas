{ ----------------------------------------------------------------------------
  PLOX Scanner (Pascal version of CLOX)
  based on Crafting Interpreters by Robert Nystrom (well worth reading)
  https://www.craftinginterpreters.com/scanning-on-demand.html
  Bruce Wernick
  1 July 2019
  ---------------------------------------------------------------------------- }

unit uScanner;

interface

type
  TTokenKind = (
    // Single-character tokens.
    tkLPAREN, tkRPAREN, tkLBRACE, tkRBRACE,
    tkCOMMA, tkDOT, tkMINUS, tkPLUS, tkSEMICOLON,
    tkSLASH, tkSTAR,

    // One or two character tokens.
    tkBANG, tkBANGEQUAL, tkEQUAL, tkEQUALEQUAL,
    tkGREATER, tkGREATEREQUAL, tkLESS, tkLESSEQUAL,

    // Literals.
    tkIDENT, tkSTRING, tkNUMBER,

    // Keywords.
    tkAND, tkCLASS, tkELSE, tkFALSE, tkFOR, tkFUN,
    tkIF, tkNIL, tkOR, tkPRINT, tkRETURN, tkSUPER,
    tkTHIS, tkTRUE, tkVAR, tkWHILE,

    // Error and End tokens
    tkERR, tkEOS);

type
  TTokenRec = record
    kind: TTokenKind;
    start: pchar;
    length: integer;
    line: integer;
  end;

type
  TScanner = record
  private
    sp: pchar;
    cp: pchar;
    line: integer;
    function isAlpha(c: char): boolean;
    function isDigit(c: char): boolean;
    function atEnd: boolean;
    function step: char;
    function peek: char;
    function spy: char;
    function matchChar(Value: char): boolean;
    function makeToken(Value: TTokenKind): TTokenRec;
    function errToken(Value: pchar): TTokenRec;
    procedure skipWhite;
    function isKeyword(Value: string): boolean;
    function identKind: TTokenKind;
    function getIdent: TTokenRec;
    function getNumber: TTokenRec;
    function getString: TTokenRec;
  public
    procedure Init(source: pchar);
    function getToken: TTokenRec;
  end;

function GetTokenStr(Value: TTokenKind): string;

implementation

uses
  SysUtils, TypInfo;

const
  lo_alpha = 'abcdefghijklmnopqrstuvwxyz';
  hi_alpha = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  alpha = lo_alpha + hi_alpha + '_';
  digits = '0123456789';
  dotChar = '.';
  quoteChar = '"';
  spaceChar = ' ';

  // special symbols
  ssEOS = Char(0);
  ssTAB = Char(9);
  ssLF  = Char(10);
  ssCR  = Char(13);

function GetTokenStr(Value: TTokenKind): string;
{- use Rtti to get string from enum }
begin
  Result := GetEnumName(TypeInfo(TTokenKind), ord(Value))
end;

procedure TScanner.Init(source: pchar);
begin
  self.sp := source;
  self.cp := source;
  self.line := 1
end;

function TScanner.isAlpha(c: char): boolean;
begin
  Result := AnsiPos(c, alpha) > 0
end;

function TScanner.isDigit(c: char): boolean;
begin
  Result := AnsiPos(c, digits) > 0
end;

function TScanner.atEnd: boolean;
begin
  Result := self.cp[0] = ssEOS
end;

function TScanner.peek: char;
begin
  Result := self.cp[0]
end;

function TScanner.step: char;
begin
  Result := peek;
  inc(self.cp)
end;

function TScanner.spy: char;
{- look ahead to next character }
begin
  if atEnd then Exit(ssEOS);
  Result := self.cp[1]
end;

function TScanner.matchChar(Value: char): boolean;
begin
  Result := True;
  if atEnd then Exit(False);
  if self.cp <> Value then Exit(False);
  inc(self.cp)
end;

function TScanner.makeToken(Value: TTokenKind): TTokenRec;
begin
  Result.kind := Value;
  Result.start := self.sp;
  Result.length := self.cp - self.sp;
  Result.line := self.line
end;

function TScanner.errToken(Value: pchar): TTokenRec;
begin
  Result.kind := tkERR;
  Result.start := Value;
  Result.length := length(Value);
  Result.line := self.line
end;

procedure TScanner.skipWhite;
var
  c: char;
begin
  while True do begin
    c := peek;
    case c of
      spaceChar, ssLF, ssTAB: step;
      ssCR: begin
             inc(self.line);
             step;
           end;
      '/': if (spy = '/') then begin
             while ((peek <> ssLF) and not atEnd) do step;
           end;
      else
        Exit;
    end;
  end;
end;

function TScanner.isKeyword(Value: string): boolean;
var
  s: string;
  k: integer;
begin
  k := length(Value);
  SetString(s, self.sp, self.cp-self.sp);
  Result := SameText(s, Value)
end;

function TScanner.identKind: TTokenKind;
begin
  Result := tkIDENT;
  if isKeyword('and') then Exit(tkAND);
  if isKeyword('class') then Exit(tkCLASS);
  if isKeyword('else') then Exit(tkELSE);
  if isKeyword('false') then Exit(tkFALSE);
  if isKeyword('for') then Exit(tkFOR);
  if isKeyword('fun') then Exit(tkFUN);
  if isKeyword('if') then Exit(tkIF);
  if isKeyword('nil') then Exit(tkNIL);
  if isKeyword('or') then Exit(tkOR);
  if isKeyword('print') then Exit(tkPRINT);
  if isKeyword('return') then Exit(tkRETURN);
  if isKeyword('super') then Exit(tkSUPER);
  if isKeyword('this') then Exit(tkTHIS);
  if isKeyword('true') then Exit(tkTRUE);
  if isKeyword('var') then Exit(tkVAR);
  if isKeyword('while') then Exit(tkWHILE);

end;

function TScanner.getIdent: TTokenRec;
begin
  while (isAlpha(peek) or isDigit(peek)) do step;
  Result := makeToken(identKind)
end;

function TScanner.getNumber: TTokenRec;
begin
  while isDigit(peek) do step;
  if (peek = dotChar) and isDigit(spy) then begin
    step;
    while isDigit(peek) do step;
  end;
  Result := makeToken(tkNUMBER);
end;

function TScanner.getString: TTokenRec;
begin
  while (peek <> QuoteChar) and not atEnd do begin
    if (peek = ssLF) then inc(self.line);
    step;
  end;
  if atEnd then Exit(errToken('Un-terminated string!'));
  step;
  Result := makeToken(tkSTRING);
end;

function TScanner.getToken: TTokenRec;
var
  c: char;
begin
  skipWhite();
  self.sp := self.cp;
  if atEnd then Exit(makeToken(tkEOS));
  c := step;
  if isAlpha(c) then Exit(getIdent);
  if isDigit(c) then Exit(getNumber);
  case c of
    '(': Exit(makeToken(tkLPAREN));
    ')': Exit(makeToken(tkRPAREN));
    '{': Exit(makeToken(tkLBRACE));
    '}': Exit(makeToken(tkRBRACE));
    ';': Exit(makeToken(tkSEMICOLON));
    ',': Exit(makeToken(tkCOMMA));
    '.': Exit(makeToken(tkDOT));
    '-': Exit(makeToken(tkMINUS));
    '+': Exit(makeToken(tkPLUS));
    '/': Exit(makeToken(tkSLASH));
    '*': Exit(makeToken(tkSTAR));
    '!': if matchChar('=') then
           Exit(makeToken(tkBANGEQUAL))
         else
           Exit(makeToken(tkBANG));
    '=': if matchChar('=') then
           Exit(makeToken(tkEQUALEQUAL))
         else
           Exit(makeToken(tkEQUAL));
    '<': if matchChar('=') then
           Exit(makeToken(tkLESSEQUAL))
         else
           Exit(makeToken(tkLESS));
    '>': if matchChar('=') then
           Exit(makeToken(tkGREATEREQUAL))
         else
           Exit(makeToken(tkGREATER));
    '"': Exit(getString);
  end;
  Result := errToken('Unexpected character!');
end;

end.

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
  TTokenType = (
    // Single-character tokens.
    TOKEN_LEFT_PAREN, TOKEN_RIGHT_PAREN, TOKEN_LEFT_BRACE, TOKEN_RIGHT_BRACE,
    TOKEN_COMMA, TOKEN_DOT, TOKEN_MINUS, TOKEN_PLUS, TOKEN_SEMICOLON,
    TOKEN_SLASH, TOKEN_STAR,

    // One or two character tokens.
    TOKEN_BANG, TOKEN_BANG_EQUAL, TOKEN_EQUAL, TOKEN_EQUAL_EQUAL,
    TOKEN_GREATER, TOKEN_GREATER_EQUAL, TOKEN_LESS, TOKEN_LESS_EQUAL,

    // Literals.
    TOKEN_IDENTIFIER, TOKEN_STRING, TOKEN_NUMBER,

    // Keywords.
    TOKEN_AND, TOKEN_CLASS, TOKEN_ELSE, TOKEN_FALSE, TOKEN_FOR, TOKEN_FUN,
    TOKEN_IF, TOKEN_NIL, TOKEN_OR, TOKEN_PRINT, TOKEN_RETURN, TOKEN_SUPER,
    TOKEN_THIS, TOKEN_TRUE, TOKEN_VAR, TOKEN_WHILE,

    TOKEN_ERROR, TOKEN_EOF);

type
  TToken = record
    TokenType: TTokenType;
    start: pchar;
    length: integer;
    line: integer;
  end;

type
  TScanner = record
    sp: pchar;
    cp: pchar;
    line: integer;
    procedure Init(source: pchar);
    function isAlpha(c: char): boolean;
    function isDigit(c: char): boolean;
    function isAtEnd: boolean;
    function advance: char;
    function peek: char;
    function peekNext: char;
    function match(expected: char): boolean;
    function makeToken(TokenType: TTokenType): TToken;
    function errorToken(const messageStr: pchar): TToken;
    procedure skipWhitespace;
    function IsText(Value: string): boolean;
    function identifierType: TTokenType;
    function is_identifier: TToken;
    function is_number: TToken;
    function is_string: TToken;
    function getToken: TToken;
  end;

function GetTokenStr(Value: TTokenType): string;

implementation

uses
  SysUtils, TypInfo;

const
  lo_alpha = 'abcdefghijklmnopqrstuvwxyz';
  hi_alpha = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  alpha = lo_alpha + hi_alpha + '_';
  digits = '0123456789';

function GetTokenStr(Value: TTokenType): string;
{- use Rtti to get string from enum }
begin
  Result := GetEnumName(TypeInfo(TTokenType), ord(Value))
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

function TScanner.isAtEnd: boolean;
begin
  Result := self.cp[0] = #0
end;

function TScanner.advance: char;
begin
  Result := self.cp[0];
  inc(self.cp);
end;

function TScanner.peek: char;
begin
  Result := self.cp[0]
end;

function TScanner.peekNext: char;
begin
  if isAtEnd then
    Exit(#0);
  Result := self.cp[1]
end;

function TScanner.match(expected: char): boolean;
begin
  Result := True;
  if isAtEnd then
    Exit(False);
  if self.cp <> expected then
    Exit(False);
  inc(self.cp)
end;

function TScanner.makeToken(TokenType: TTokenType): TToken;
begin
  Result.TokenType := TokenType;
  Result.start := self.sp;
  Result.length := self.cp - self.sp;
  Result.line := self.line
end;

function TScanner.errorToken(const messageStr: pchar): TToken;
begin
  Result.TokenType := TOKEN_ERROR;
  Result.start := messageStr;
  Result.length := length(messageStr);
  Result.line := self.line
end;

procedure TScanner.skipWhitespace;
var
  c: char;
begin
  while True do begin
    c := peek;
    case c of
      ' ', #10, #9: advance();
      #13: begin
             inc(self.line);
             advance;
           end;
      '/': if (peekNext = '/') then begin
             while ((peek <> '\n') and not isAtEnd) do
               advance;
           end;
      else
        Exit;
    end;
  end;
end;

function TScanner.IsText(Value: string): boolean;
var
  s: string;
  k: integer;
begin
  k := length(Value);
  SetString(s, self.cp, k);
  Result := SameText(s, Value)
end;

function TScanner.identifierType: TTokenType;
begin
  Result := TOKEN_IDENTIFIER;
  if IsText('and') then Exit(TOKEN_AND);
  if IsText('class') then Exit(TOKEN_CLASS);
  if IsText('else') then Exit(TOKEN_ELSE);
  if IsText('false') then Exit(TOKEN_FALSE);
  if IsText('for') then Exit(TOKEN_FOR);
  if IsText('fun') then Exit(TOKEN_FUN);
  if IsText('if') then Exit(TOKEN_IF);
  if IsText('nil') then Exit(TOKEN_NIL);
  if IsText('or') then Exit(TOKEN_OR);
  if IsText('print') then Exit(TOKEN_PRINT);
  if IsText('return') then Exit(TOKEN_RETURN);
  if IsText('super') then Exit(TOKEN_SUPER);
  if IsText('this') then Exit(TOKEN_THIS);
  if IsText('true') then Exit(TOKEN_TRUE);
  if IsText('var') then Exit(TOKEN_VAR);
  if IsText('while') then Exit(TOKEN_WHILE);
end;

function TScanner.is_identifier: TToken;
begin
  while (isAlpha(peek) or isDigit(peek)) do
    advance;
  Result := makeToken(identifierType)
end;

function TScanner.is_number: TToken;
begin
  while (isDigit(peek)) do
    advance;
  if (peek = '.') and isDigit(peekNext) then begin
    advance;
    while isDigit(peek) do advance;
  end;
  Result := makeToken(TOKEN_NUMBER);
end;

function TScanner.is_string: TToken;
begin
  while (peek <> '"') and not isAtEnd do begin
    if (peek = '\n') then
      inc(self.line);
    advance();
  end;
  if isAtEnd then
    Exit(errorToken('Unterminated string.'));
  advance();
  Result := makeToken(TOKEN_STRING);
end;

function TScanner.getToken: TToken;
var
  c: char;
begin
  skipWhitespace();
  self.sp := self.cp;
  if isAtEnd then
    Exit(makeToken(TOKEN_EOF));
  c := advance;
  if isAlpha(c) then
    Exit(is_identifier);
  if isDigit(c) then
    Exit(is_number);
  case c of
    '(': Exit(makeToken(TOKEN_LEFT_PAREN));
    ')': Exit(makeToken(TOKEN_RIGHT_PAREN));
    '{': Exit(makeToken(TOKEN_LEFT_BRACE));
    '}': Exit(makeToken(TOKEN_RIGHT_BRACE));
    ';': Exit(makeToken(TOKEN_SEMICOLON));
    ',': Exit(makeToken(TOKEN_COMMA));
    '.': Exit(makeToken(TOKEN_DOT));
    '-': Exit(makeToken(TOKEN_MINUS));
    '+': Exit(makeToken(TOKEN_PLUS));
    '/': Exit(makeToken(TOKEN_SLASH));
    '*': Exit(makeToken(TOKEN_STAR));
    '!': if match('=') then
           Exit(makeToken(TOKEN_BANG_EQUAL))
         else
           Exit(makeToken(TOKEN_BANG));
    '=': if match('=') then
           Exit(makeToken(TOKEN_EQUAL_EQUAL))
         else
           Exit(makeToken(TOKEN_EQUAL));
    '<': if match('=') then
           Exit(makeToken(TOKEN_LESS_EQUAL))
         else
           Exit(makeToken(TOKEN_LESS));
    '>': if match('=') then
           Exit(makeToken(TOKEN_GREATER_EQUAL))
         else
           Exit(makeToken(TOKEN_GREATER));
    '"': Exit(is_string);
  end;
  Result := errorToken('Unexpected character.');
end;

end.

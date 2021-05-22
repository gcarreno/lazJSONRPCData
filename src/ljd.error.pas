{ Implements Error Object

Copyright (c) 2021 Gustavo Carreno <guscarreno@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

}
unit LJD.Error;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, fpjson
;

type
{ EErrorNotAJSONObject }
  EErrorNotAJSONObject = Exception;
{ EErrorEmptyString }
  EErrorEmptyString = Exception;
{ EErrorCannotParse }
  EErrorCannotParse = Exception;
{ EErrorMissingMember }
  EErrorMissingMember = Exception;
{ EErrorWrongMemberType }
  EErrorWrongMemberType = Exception;
{ TError }
  TError = class(TObject)
  private
    FCode: Integer;
    FID: Integer;
    FMessage: TJSONStringType;
    FHasData: Boolean;
    FData: TJSONStringType;

    FCompressedJSON: Boolean;

    procedure SetData(AValue: TJSONStringType);
    procedure setFromJSON(const AJSON: TJSONStringType);
    procedure setFromJSONData(const AJSONData: TJSONData);
    procedure setFromJSONObject(const AJSONObject: TJSONObject);
    procedure setFromStream(const AStream: TStream);

    function getAsJSON: TJSONStringType;
    function getAsJSONData: TJSONData;
    function getAsJSONObject: TJSONObject;
    function getAsStream: TStream;

  protected
  public
    constructor Create;
    constructor Create(const AJSON: TJSONStringType);
    constructor Create(const AJSONData: TJSONData);
    constructor Create(const AJSONObject: TJSONObject);
    constructor Create(const AStream: TStream);

    destructor Destroy; override;

    function FormatJSON(AOptions : TFormatOptions = DefaultFormat;
      AIndentsize : Integer = DefaultIndentSize): TJSONStringType;

    property Code: Integer
      read FCode
      write FID;
    property Message: TJSONStringType
      read FMessage
      write FMessage;
    property Data: TJSONStringType
      read FData
      write SetData;

    property HasData: Boolean
      read FHasData;

    property CompressedJSON: Boolean
      read FCompressedJSON
      write FCompressedJSON;

    property AsJSON: TJSONStringType
      read getAsJSON;
    property AsJSONData: TJSONData
      read getAsJSONData;
    property AsJSONObject: TJSONObject
      read getAsJSONObject;
    property AsStream: TStream
      read getAsStream;

  published
  end;

const
  cjCode = 'code';
  cjMessage = 'message';
  cjData = 'data';

  cJSONRPCCodeParseError     = -32700;
  cJSONRPCCodeInvalidRequest = -32600;
  cJSONRPCCodeMethodNotFound = -32601;
  cJSONRPCCodeInvalidParams  = -32602;
  cJSONRPCCodeInternalError  = -32603;

resourcestring
  rsErrorMessageParseError     = 'Parse error';
  rsErrorMessageInvalidRequest = 'Invalid request';
  rsErrorMessageMethodNotFound = 'Method not found';
  rsErrorMessageInvalidParams  = 'Invalid params';
  rsErrorMessageInternalError  = 'Internal Error';

  rsExceptionNotAJSONObject = 'JSON Data is not an object';
  rsExceptionEmptyString = 'MUST not be and empty string';
  rsExceptionCannotParse = 'Cannot parse: %s';
  rsExceptionMissingMember = 'Missing member: %s';
  rsExceptionWrongMemberType = 'Wrong type in member: %s';

implementation

uses
  LJD.JSON.Utils
;

{ TError }

procedure TError.setFromJSON(const AJSON: TJSONStringType);
var
  jData: TJSONData;
begin
  if trim(AJSON) = EmptyStr then
  begin
    raise EErrorEmptyString.Create(rsExceptionEmptyString);
  end;
  try
    jData:= GetJSONData(AJSON);
  except
    on E: Exception do
    begin
      raise EErrorCannotParse.Create(Format(rsExceptionCannotParse, [E.Message]));
    end;
  end;
  try
    setFromJSONData(jData);
  finally
    jData.Free;
  end;
end;

procedure TError.SetData(AValue: TJSONStringType);
begin
  if FData=AValue then Exit;
  FData:=AValue;
  FHasData:= Trim(AValue) <> EmptyStr;
end;

procedure TError.setFromJSONData(const AJSONData: TJSONData);
begin
  if aJSONData.JSONType <> jtObject then
  begin
    raise EErrorNotAJSONObject.Create(rsExceptionNotAJSONObject);
  end;
  setFromJSONObject(aJSONData as TJSONObject);
end;

procedure TError.setFromJSONObject(const AJSONObject: TJSONObject);
var
  jData: TJSONData;
begin
  // Code
  jData:= AJSONObject.Find(cjCode);
  if Assigned(jData) then
  begin
    if (jData.JSONType = jtNumber) and
      (TJSONNumber(jData).NumberType = ntInteger) then
    begin
      FCode:= AJSONObject.Get(cjCode, FCode);
    end
    else
    begin
      raise EErrorWrongMemberType.Create(Format(rsExceptionWrongMemberType, [cjCode]));
    end;
  end
  else
  begin
    raise EErrorMissingMember.Create(Format(rsExceptionMissingMember,[cjCode]));
  end;
  // Message
  jData:= AJSONObject.Find(cjMessage);
  if Assigned(jData) then
  begin
    if jData.JSONType = jtString then
    begin
      FMessage:= AJSONObject.Get(cjMessage, FMessage);
    end
    else
    begin
      raise EErrorWrongMemberType.Create(Format(rsExceptionWrongMemberType, [cjMessage]));
    end;
  end
  else
  begin
    raise EErrorMissingMember.Create(Format(rsExceptionMissingMember,[cjMessage]));
  end;
  // Data
  jData:= AJSONObject.Find(cjData);
  if Assigned(jData) then
  begin
    if jData.JSONType = jtString then
    begin
      FHasData:= True;
      FData:= AJSONObject.Get(cjData, FData);
    end
    else
    begin
      raise EErrorWrongMemberType.Create(Format(rsExceptionWrongMemberType, [cjData]));
    end;
  end;
end;

procedure TError.setFromStream(const AStream: TStream);
var
  jData: TJSONData;
begin
  if AStream.Size = 0 then
  begin
    raise EErrorEmptyString.Create(rsExceptionEmptyString);
  end;
  try
    jData:= GetJSONData(AStream);
  except
    on E: Exception do
    begin
      raise EErrorCannotParse.Create(Format(rsExceptionCannotParse, [E.Message]));
    end;
  end;
  try
    setFromJSONData(jData);
  finally
    jData.Free;
  end;
end;

function TError.getAsJSON: TJSONStringType;
var
  jObject: TJSONObject;
begin
  Result:= '';
  jObject:= getAsJSONObject;
  jObject.CompressedJSON:= FCompressedJSON;
  Result:= jObject.AsJSON;
end;

function TError.getAsJSONData: TJSONData;
begin
  Result:= getAsJSONObject as TJSONData;
end;

function TError.getAsJSONObject: TJSONObject;
begin
  Result:= TJSONObject.Create;
  Result.Add(cjCode, FCode);
  Result.Add(cjMessage, FMessage);
  if FHasData then
  begin
    Result.Add(cjData, FData);
  end;
end;

function TError.getAsStream: TStream;
begin
  Result:= TStringStream.Create(getAsJSON, TEncoding.UTF8);
end;

constructor TError.Create;
begin
  FCompressedJSON:= True;

  FCode:= 0;
  FMessage:= EmptyStr;
  FData:= EmptyStr;
  FHasData:= False;
end;

constructor TError.Create(const AJSON: TJSONStringType);
begin
  Create;
  setFromJSON(AJSON);
end;

constructor TError.Create(const AJSONData: TJSONData);
begin
  Create;
  setFromJSONData(AJSONData);
end;

constructor TError.Create(const AJSONObject: TJSONObject);
begin
  Create;
  setFromJSONObject(AJSONObject);
end;

constructor TError.Create(const AStream: TStream);
begin
  Create;
  setFromStream(AStream);
end;

destructor TError.Destroy;
begin
  inherited Destroy;
end;

function TError.FormatJSON(AOptions: TFormatOptions;
  AIndentsize: Integer): TJSONStringType;
begin
  Result:= getAsJSONObject.FormatJSON(AOptions, AIndentsize);
end;

end.


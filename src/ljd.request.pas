{ Implement Request Object

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
unit LJD.Request;

{$mode objfpc}{$H+}

interface

uses
  Classes
, SysUtils
, fpjson
;

const
  cjJSONRPCversion = '2.0';

  cjJSONRPC = 'jsonrpc';
  cjMethod = 'method';
  cjParams = 'params';
  cjID = 'ID';

resourcestring
  rsExceptionNotAJSONObject = 'JSON Data is not an object';
  rsExceptionEmptyString = 'MUST not be and empty string';
  rsExceptionCannotParse = 'Cannot parse: %s';
  rsExceptionMissingMember = 'Missing member: %s';

type
{ ERequestNotAJSONObject }
  ERequestNotAJSONObject = Exception;
{ ERequestEmptyString }
  ERequestEmptyString = Exception;
{ ERequestCannotParse }
  ERequestCannotParse = Exception;
{ ERequestMissingMember }
  ERequestMissingMember = Exception;

{ TRequestParamsArray }
  TRequestParamsArray = class(TObject)
  private
    FJSONRPC: TJSONStringType;
    FMethod: TJSONStringType;
    FParams: TJSONArray;
    FID: Int64;
    FNotification: Boolean;

    FCompressedJSON: Boolean;

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

    property JSONRPC: TJSONStringType
      read FJSONRPC;
    property Method: TJSONStringType
      read FMethod
      write FMethod;
    property Params: TJSONArray
      read FParams;
    property ID: Int64
      read FID
      write FID;
    property Notification: Boolean
      read FNotification
      write FNotification;

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

implementation

uses
  LJD.JSON.Utils
, Dialogs
;

{ TMethod }

procedure TRequestParamsArray.setFromJSON(const AJSON: TJSONStringType);
var
  jData: TJSONData;
begin
  if trim(AJSON) = EmptyStr then
    raise ERequestEmptyString.Create(rsExceptionEmptyString);
  try
    jData:= GetJSONData(AJSON);
  except
    on E: Exception do
      raise ERequestCannotParse.Create(Format(rsExceptionCannotParse, [E.Message]));
  end;
  try
    setFromJSONData(jData);
  finally
    jData.Free;
  end;
end;

procedure TRequestParamsArray.setFromJSONData(const AJSONData: TJSONData);
begin
  if aJSONData.JSONType <> jtObject then
  begin
    raise ERequestNotAJSONObject.Create(rsExceptionNotAJSONObject);
  end;
  setFromJSONObject(aJSONData as TJSONObject);
end;

procedure TRequestParamsArray.setFromJSONObject(const AJSONObject: TJSONObject);
var
  jData: TJSONData;
  jParams: TJSONArray;
  index: Integer;
begin
  jData := AJSONObject.Find(cjJSONRPC);
  if Assigned(jData) then
  begin
    FJSONRPC:= AJSONObject.Get(cjJSONRPC, FJSONRPC);
  end
  else
    raise ERequestMissingMember.Create(Format(rsExceptionMissingMember, [cjJSONRPC]));

  jData := AJSONObject.Find(cjMethod);
  if Assigned(jData) then
  begin
    FMethod:= AJSONObject.Get(cjMethod, FMethod);
  end
  else
    raise ERequestMissingMember.Create(Format(rsExceptionMissingMember, [cjMethod]));

  jData:= AJSONObject.Find(cjParams);
  if Assigned(jData) then
  begin
    if jData.JSONType = jtArray then
    begin
      jParams:= TJSONArray(jData);
      FParams.Clear;
      for index:= 0 to Pred(jParams.Count) do
      begin
        FParams.Add(jParams[index]);
      end;
    end;
  end
  else
    raise ERequestMissingMember.Create(Format(rsExceptionMissingMember, [cjParams]));

  jData:= AJSONObject.Find(cjID);
  if Assigned(jData) then
  begin
    FID:= AJSONObject.Get(cjID, FID);
  end
  else
    FNotification:= True;
end;

procedure TRequestParamsArray.setFromStream(const AStream: TStream);
var
  jData: TJSONData;
begin
  if AStream.Size = 0 then
    raise ERequestEmptyString.Create(rsExceptionEmptyString);
  try
    jData:= GetJSONData(AStream);
  except
    on E: Exception do
      raise ERequestCannotParse.Create(Format(rsExceptionCannotParse, [E.Message]));
  end;
  try
    setFromJSONData(jData);
  finally
    jData.Free;
  end;
end;

function TRequestParamsArray.getAsJSON: TJSONStringType;
var
  jObject: TJSONObject;
begin
  Result:= '';
  jObject:= getAsJSONObject;
  jObject.CompressedJSON:= FCompressedJSON;
  Result:= jObject.AsJSON;
end;

function TRequestParamsArray.getAsJSONData: TJSONData;
begin
  Result:= getAsJSONObject as TJSONData;
end;

function TRequestParamsArray.getAsJSONObject: TJSONObject;
begin
  Result:= TJSONObject.Create;
  Result.Add(cjJSONRPC, cjJSONRPCversion);
  Result.Add(cjMethod, FMethod);
  Result.Add(cjParams, FParams);
  if not FNotification then
    Result.Add(cjID, FID);
end;

function TRequestParamsArray.getAsStream: TStream;
begin
  Result:= TStringStream.Create(getAsJSON);
end;

function TRequestParamsArray.FormatJSON(AOptions: TFormatOptions;
  AIndentsize: Integer): TJSONStringType;
begin
  Result:= getAsJSONObject.FormatJSON(AOptions, AIndentsize);
end;

constructor TRequestParamsArray.Create;
begin
  FCompressedJSON:= True;
  FJSONRPC:= cjJSONRPCversion;
  FMethod:= EmptyStr;
  FParams:= TJSONArray.Create;
  FID:= -1;
  FNotification:= False;
end;

constructor TRequestParamsArray.Create(const AJSON: TJSONStringType);
begin
  Create;
  setFromJSON(AJSON);
end;

constructor TRequestParamsArray.Create(const AJSONData: TJSONData);
begin
  Create;
  setFromJSONData(AJSONData);
end;

constructor TRequestParamsArray.Create(const AJSONObject: TJSONObject);
begin
  Create;
  setFromJSONObject(AJSONObject);
end;

constructor TRequestParamsArray.Create(const AStream: TStream);
begin
  Create;
  setFromStream(AStream);
end;

destructor TRequestParamsArray.Destroy;
begin
  inherited Destroy;
end;

end.


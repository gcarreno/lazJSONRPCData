{ Implements Response Object

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
unit LJD.Response;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, fpjson
, jsonparser
, LJD.Error
;

type
{ EResponseNotAJSONObject }
  EResponseNotAJSONObject = Exception;
{ EResponseEmptyString }
  EResponseEmptyString = Exception;
{ EResponseCannotParse }
  EResponseCannotParse = Exception;
{ EResponseMissingMember }
  EResponseMissingMember = Exception;
{ EResponseWrongMemberType }
  EResponseWrongMemberType = Exception;

{ TResponse }
  TResponse = class(TObject)
  private
    FJSONRPC: TJSONStringType;
    FHasResult: Boolean;
    FResult: TJSONData;
    FHasError: Boolean;
    FError: TError;
    FIDIsNull: Boolean;
    FID: Int64;

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

    property JSONRPC: TJSONStringType
      read FJSONRPC;
    property HasResult: Boolean
      read FHasResult;
    property Result: TJSONData
      read FResult;
    property HasError: Boolean
      read FHasError;
    property Error: TError
      read FError;
    property IDIsNull: Boolean
      read FIDIsNull;
    property ID: Int64
      read FID;

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
  cjJSONRPCversion = '2.0';

  cjJSONRPC = 'jsonrpc';
  cjResult = 'result';
  cjError = 'error';
  cjID = 'id';

resourcestring
  rsExceptionNotAJSONObject = 'JSON Data is not an object';
  rsExceptionEmptyString = 'MUST not be and empty string';
  rsExceptionCannotParse = 'Cannot parse: %s';
  rsExceptionMissingMember = 'Missing member: %s';
  rsExceptionWrongMemberType = 'Wrong type in member: %s';
  rsExceptionMissingMemberResultOrError = 'Missing one of: %s or %s';

implementation

{ TResponse }

procedure TResponse.setFromJSON(const AJSON: TJSONStringType);
var
  jData: TJSONData;
begin
  if trim(AJSON) = EmptyStr then
  begin
    raise EResponseEmptyString.Create(rsExceptionEmptyString);
  end;
  try
    jData:= GetJSON(AJSON);
  except
    on E: Exception do
    begin
      raise EResponseCannotParse.Create(Format(rsExceptionCannotParse, [E.Message]));
    end;
  end;
  try
    setFromJSONData(jData);
  finally
    jData.Free;
  end;
end;

procedure TResponse.setFromJSONData(const AJSONData: TJSONData);
begin
  if aJSONData.JSONType <> jtObject then
  begin
    raise EResponseNotAJSONObject.Create(rsExceptionNotAJSONObject);
  end;
  setFromJSONObject(aJSONData as TJSONObject);
end;

procedure TResponse.setFromJSONObject(const AJSONObject: TJSONObject);
var
  jData, jResult, jError: TJSONData;
begin
  // JSONRPC
  jData := AJSONObject.Find(cjJSONRPC);
  if Assigned(jData) then
  begin
    if (jData.JSONType = jtString) and (jData.AsString = cjJSONRPCversion) then
    begin
      FJSONRPC:= AJSONObject.Get(cjJSONRPC, FJSONRPC);
    end
    else
    begin
      raise EResponseWrongMemberType.Create(Format(rsExceptionWrongMemberType, [cjJSONRPC]));
    end;
  end
  else
  begin
    raise EResponseMissingMember.Create(Format(rsExceptionMissingMember, [cjJSONRPC]));
  end;
  // Result OR Error
  jResult:= AJSONObject.Find(cjResult);
  jError:= AJSONObject.Find(cjError);
  if (jResult = nil) and (jError = nil) then
  begin
    raise EResponseMissingMember.Create(Format(rsExceptionMissingMemberResultOrError, [cjResult, cjError]));
  end;
  // Result
  if (jResult <> nil) and (jError = nil) then
  begin
    FResult:= jResult.Clone;
    FHasError:= False;
    FHasResult:= True;
  end;
  if (jResult = nil) and (jError <> nil) then
  begin
    // Result
    if jError.JSONType = jtObject then
    begin
      if Assigned(FError) then
      begin
        FreeAndNil(FError);
      end;
      FError:= TError.Create(jError);
      FHasError:= True;
      FHasResult:= False;
    end
    else
    begin
      raise EResponseWrongMemberType.Create(Format(rsExceptionWrongMemberType, [cjError]));
    end;
  end;
  // ID
  jData := AJSONObject.Find(cjID);
  if Assigned(jData) then
  begin
    if (
      (jData.JSONType = jtNumber) and
      (
        (TJSONNumber(jData).NumberType = ntInteger) or
        (TJSONNumber(jData).NumberType = ntInt64)
      )
    ) or
    (jData.JSONType = jtNull) then
    begin
      if jData.JSONType = jtNumber then
      begin
        FIDIsNull:= False;
        FID:= AJSONObject.Get(cjID, FID);
      end;
      if jData.JSONType = jtNull then
      begin
        FIDIsNull:= True;
        FID:= -1;
      end;
    end
    else
    begin
      raise EResponseWrongMemberType.Create(Format(rsExceptionWrongMemberType, [cjID]));
    end;
  end
  else
  begin
    raise EResponseMissingMember.Create(Format(rsExceptionMissingMember, [cjID]));
  end;
end;

procedure TResponse.setFromStream(const AStream: TStream);
var
  jData: TJSONData;
begin
  if AStream.Size = 0 then
  begin
    raise EResponseEmptyString.Create(rsExceptionEmptyString);
  end;
  try
    jData:= GetJSON(AStream);
  except
    on E: Exception do
    begin
      raise EResponseCannotParse.Create(Format(rsExceptionCannotParse, [E.Message]));
    end;
  end;
  try
    setFromJSONData(jData);
  finally
    jData.Free;
  end;
end;

function TResponse.getAsJSON: TJSONStringType;
var
  jObject: TJSONObject;
begin
  Result:= '';
  jObject:= getAsJSONObject;
  jObject.CompressedJSON:= FCompressedJSON;
  Result:= jObject.AsJSON;
  jObject.Free;
end;

function TResponse.getAsJSONData: TJSONData;
begin
  Result:= getAsJSONObject as TJSONData;
end;

function TResponse.getAsJSONObject: TJSONObject;
begin
  Result:= TJSONObject.Create;
  Result.Add(cjJSONRPC, cjJSONRPCversion);
  if FHasResult then
  begin
    Result.Add(cjResult, FResult.Clone);
  end;
  if FHasError then
  begin
    Result.Add(cjError, FError.AsJSONObject);
  end;
  case FIDIsNull of
    True: Result.Add(cjID, TJSONNull.Create);
    False: Result.Add(cjID, FID);
  end;
end;

function TResponse.getAsStream: TStream;
begin
  Result:= TStringStream.Create(getAsJSON, TEncoding.UTF8);
end;

constructor TResponse.Create;
begin
  FCompressedJSON:= True;

  FJSONRPC:= cjJSONRPCversion;
  FHasResult:= True;
  FResult:= nil;
  FHasError:= False;
  FError:= nil;
  FIDIsNull:= False;
  FID:= -1;
end;

constructor TResponse.Create(const AJSON: TJSONStringType);
begin
  Create;
  setFromJSON(AJSON);
end;

constructor TResponse.Create(const AJSONData: TJSONData);
begin
  Create;
  setFromJSONData(AJSONData);
end;

constructor TResponse.Create(const AJSONObject: TJSONObject);
begin
  Create;
  setFromJSONObject(AJSONObject);
end;

constructor TResponse.Create(const AStream: TStream);
begin
  Create;
  setFromStream(AStream);
end;

destructor TResponse.Destroy;
begin
  if FHasResult then
  begin
    FResult.Free;
  end;
  if FHasError then
  begin
    FError.Free;
  end;
  inherited Destroy;
end;

end.


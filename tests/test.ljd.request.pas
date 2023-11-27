{ Implements Test Request Object

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
unit Test.LJD.Request;

{$mode objfpc}{$H+}

interface

uses
  Classes
, SysUtils
, fpcunit
//, testutils
, testregistry
, LJD.Request
;

type
{ TTestlazJSONRPCRequest }
  TTestlazJSONRPCRequest= class(TTestCase)
  private
    FRequest: TJSONRPCRequest;

    procedure CheckFieldsCreate;
    procedure CheckFieldsCreateNotification;
    procedure CheckFieldsCreateRequestEmpty;
    procedure CheckFieldsCreateWithMethod;
  protected
  public
  published
    procedure TestlazJSONRPCRequestCreate;

    procedure TestlazJSONRPCRequestCreateFromJSONData;
    procedure TestlazJSONRPCRequestCreateFromJSONObject;
    procedure TestlazJSONRPCRequestCreateFromStream;

    procedure TestlazJSONRPCRequestCreateNotification;
    procedure TestlazJSONRPCRequestCreateRequestEmpty;

    procedure TestlazJSONRPCRequestCreateExceptionEmptyString;
    procedure TestlazJSONRPCRequestCreateExceptionCannotParse;
    procedure TestlazJSONRPCRequestCreateExceptionMissingMembers;

    procedure TestlazJSONRPCRequestCreateWithMethod;

    procedure TestlazJSONRPCRequestAsJSON;
    procedure TestlazJSONRPCRequestAsJSONNotification;
    procedure TestlazJSONRPCRequestAsJSONData;
    procedure TestlazJSONRPCRequestAsJSONObject;
    procedure TestlazJSONRPCRequestAsStream;
  end;

implementation

uses
  fpjson
;

const
  cjRequestEmpty: TJSONStringType =
    '{'+
      '"'+ cjJSONRPC +'":"'+cjJSONRPCversion+'",'+
      '"'+ cjMethod +'":"",'+
      '"'+ cjParams +'":[],'+
      '"'+ cjID +'":1'+
    '}'
  ;
  cjRequestMissingJSONRPC: TJSONStringType =
    '{'+
      '"'+ cjMethod +'":"",'+
      '"'+ cjParams +'":[],'+
      '"'+ cjID +'":1'+
    '}'
  ;
  cjRequestMissingMethod: TJSONStringType =
    '{'+
      '"'+ cjJSONRPC +'":"'+cjJSONRPCversion+'",'+
      '"'+ cjParams +'":[],'+
      '"'+ cjID +'":1'+
    '}'
  ;
  cjRequestMissingParams: TJSONStringType =
    '{'+
      '"'+ cjJSONRPC +'":"'+cjJSONRPCversion+'",'+
      '"'+ cjMethod +'":"",'+
      '"'+ cjID +'":1'+
    '}'
  ;
  cjRequestNotification: TJSONStringType =
    '{'+
      '"'+ cjJSONRPC +'":"'+cjJSONRPCversion+'",'+
      '"'+ cjMethod +'":"",'+
      '"'+ cjParams +'":[]'+
    '}'
  ;
  cjRequestWithMethod: TJSONStringType =
    '{'+
      '"'+ cjJSONRPC +'":"'+cjJSONRPCversion+'",'+
      '"'+ cjMethod +'":"echo",'+
      '"'+ cjParams +'":["Hello, World"],'+
      '"'+ cjID +'":1'+
    '}'
  ;

procedure TTestlazJSONRPCRequest.CheckFieldsCreate;
begin
  AssertEquals('Request '+cjJSONRPC+' is '+cjJSONRPCversion, cjJSONRPCversion, FRequest.JSONRPC);
  AssertEquals('Request '+cjMethod+' is Empty', EmptyStr, FRequest.Method);
  AssertEquals('Request '+cjParams+' Type Unknown', Ord(rptUnknown), Ord(FRequest.ParamsType));
  AssertNull('Request '+cjParams+' is null', FRequest.Params);
  AssertEquals('Request '+cjID+' is -1', -1, FRequest.ID);
  AssertFalse('Request is not a notification', FRequest.Notification);
end;

procedure TTestlazJSONRPCRequest.CheckFieldsCreateNotification;
begin
  AssertEquals('Request '+cjJSONRPC+' is '+cjJSONRPCversion, cjJSONRPCversion, FRequest.JSONRPC);
  AssertEquals('Request '+cjMethod+' is Empty', EmptyStr, FRequest.Method);
  AssertNotNull('Request '+cjParams+' is not null', FRequest.Params);
  AssertEquals('Request '+cjParams+' array is empty', 0, FRequest.Params.Count);
  AssertTrue('Request is a notification', FRequest.Notification);
end;

procedure TTestlazJSONRPCRequest.CheckFieldsCreateRequestEmpty;
begin
  AssertEquals('Request '+cjJSONRPC+' is '+cjJSONRPCversion, cjJSONRPCversion, FRequest.JSONRPC);
  AssertEquals('Request '+cjMethod+' is Empty', EmptyStr, FRequest.Method);
  AssertNotNull('Request '+cjParams+' is not null', FRequest.Params);
  AssertEquals('Request '+cjParams+' Type Array', Ord(rptArray), Ord(FRequest.ParamsType));
  AssertEquals('Request '+cjParams+' Type jtArray', Ord(jtArray), Ord(FRequest.Params.JSONType));
  AssertEquals('Request '+cjParams+' array is empty', 0, FRequest.Params.Count);
  AssertEquals('Request '+cjID+' is 1', 1, FRequest.ID);
end;

procedure TTestlazJSONRPCRequest.CheckFieldsCreateWithMethod;
begin
  AssertEquals('Request '+cjJSONRPC+' is '+cjJSONRPCversion, cjJSONRPCversion, FRequest.JSONRPC);
  AssertEquals('Request '+cjMethod+' is echo', 'echo', FRequest.Method);
  AssertNotNull('Request '+cjParams+' is not null', FRequest.Params);
  AssertEquals('Request '+cjParams+' count is 1', 1, FRequest.Params.Count);
  AssertEquals('Request '+cjParams+' item[0] is "Hello, World"', 'Hello, World', TJSONArray(FRequest.Params)[0].AsString);
  AssertEquals('Request '+cjID+' is 1', 1, FRequest.ID);
end;

procedure TTestlazJSONRPCRequest.TestlazJSONRPCRequestCreate;
begin
  FRequest:= TJSONRPCRequest.Create;
  CheckFieldsCreate;
  FRequest.Free;
end;

procedure TTestlazJSONRPCRequest.TestlazJSONRPCRequestCreateFromJSONData;
var
  jData: TJSONData = nil;
begin
  jData:= GetJSON(cjRequestEmpty);
  FRequest:= TJSONRPCRequest.Create(jData);
  jData.Free;
  CheckFieldsCreateRequestEmpty;
  FRequest.Free;
end;

procedure TTestlazJSONRPCRequest.TestlazJSONRPCRequestCreateFromJSONObject;
var
  jData: TJSONData = nil;
begin
  jData:= GetJSON(cjRequestEmpty);
  FRequest:= TJSONRPCRequest.Create(TJSONObject(jData));
  jData.Free;
  CheckFieldsCreateRequestEmpty;
  FRequest.Free;
end;

procedure TTestlazJSONRPCRequest.TestlazJSONRPCRequestCreateFromStream;
var
  ssRequestEmpty: TStringStream = nil;
begin
  ssRequestEmpty:= TStringStream.Create(cjRequestEmpty, TEncoding.UTF8);
  FRequest:= TJSONRPCRequest.Create(ssRequestEmpty);
  ssRequestEmpty.Free;
  CheckFieldsCreateRequestEmpty;
  FRequest.Free;
end;

procedure TTestlazJSONRPCRequest.TestlazJSONRPCRequestCreateNotification;
begin
  FRequest:= TJSONRPCRequest.Create(cjRequestNotification);
  CheckFieldsCreateNotification;
  FRequest.Free;
end;

procedure TTestlazJSONRPCRequest.TestlazJSONRPCRequestCreateRequestEmpty;
begin
  FRequest:= TJSONRPCRequest.Create(cjRequestEmpty);
  CheckFieldsCreateRequestEmpty;
  FRequest.Free;
end;

procedure TTestlazJSONRPCRequest.TestlazJSONRPCRequestCreateExceptionEmptyString;
var
  error: Integer = 0;
begin
  try
    FRequest:= TJSONRPCRequest.Create('');
  except
    on E: ERequestEmptyString do
      error:= -32700;
  end;
  AssertEquals('Request Error Empty String', -32700, error);
end;

procedure TTestlazJSONRPCRequest.TestlazJSONRPCRequestCreateExceptionCannotParse;
var
  error: Integer = 0;
begin
  try
    FRequest:= TJSONRPCRequest.Create('Not Valid JSON');
  except
    on E: ERequestCannotParse do
      error:= -32700;
  end;
  AssertEquals('Request Error Cannot Parse', -32700, error);
end;

procedure TTestlazJSONRPCRequest.TestlazJSONRPCRequestCreateExceptionMissingMembers;
var
  error: Integer;
begin
  // Missing JSON-RPC
  error:= 0;
  try
    FRequest:= TJSONRPCRequest.Create(cjRequestMissingJSONRPC);
  except
    on E: ERequestMissingMember do
      error:= -32600;
  end;
  AssertEquals('Request Error Cannot Parse', -32600, error);
  // Missing Method
  error:= 0;
  try
    FRequest:= TJSONRPCRequest.Create(cjRequestMissingMethod);
  except
    on E: ERequestMissingMember do
      error:= -32600;
  end;
  AssertEquals('Request Error Cannot Parse', -32600, error);
  // Missing Params
  error:= 0;
  try
    FRequest:= TJSONRPCRequest.Create(cjRequestMissingParams);
  except
    on E: ERequestMissingMember do
      error:= -32600;
  end;
  AssertEquals('Request Error Cannot Parse', -32600, error);
end;

procedure TTestlazJSONRPCRequest.TestlazJSONRPCRequestCreateWithMethod;
begin
  FRequest:= TJSONRPCRequest.Create(cjRequestWithMethod);
  CheckFieldsCreateWithMethod;
  FRequest.Free;
end;

procedure TTestlazJSONRPCRequest.TestlazJSONRPCRequestAsJSON;
begin
  FRequest:= TJSONRPCRequest.Create(cjRequestEmpty);
  AssertFalse('Request is not a notification', FRequest.Notification);
  AssertEquals('Request AsJSON matches', cjRequestEmpty, FRequest.AsJSON);
  FRequest.Free;
end;

procedure TTestlazJSONRPCRequest.TestlazJSONRPCRequestAsJSONNotification;
begin
  FRequest:= TJSONRPCRequest.Create(cjRequestNotification);
  AssertTrue('Request is a notification', FRequest.Notification);
  AssertEquals('Request AsJSON Notification matches', cjRequestNotification, FRequest.AsJSON);
  FRequest.Free;
end;

procedure TTestlazJSONRPCRequest.TestlazJSONRPCRequestAsJSONData;
var
  jData: TJSONData = nil;
begin
  FRequest:= TJSONRPCRequest.Create(cjRequestEmpty);
  AssertFalse('Request is not a notification', FRequest.Notification);
  jData:= FRequest.AsJSONData;
  AssertEquals('Request AsJSONData matches', cjRequestEmpty, jData.AsJSON);
  jData.Free;
  FRequest.Free;
end;

procedure TTestlazJSONRPCRequest.TestlazJSONRPCRequestAsJSONObject;
var
  jObject: TJSONObject = nil;
begin
  FRequest:= TJSONRPCRequest.Create(cjRequestEmpty);
  AssertFalse('Request is not a notification', FRequest.Notification);
  jObject:= FRequest.AsJSONObject;
  AssertEquals('Request AsJSONObject matches', cjRequestEmpty, jObject.AsJSON);
  jObject.Free;
  FRequest.Free;
end;

procedure TTestlazJSONRPCRequest.TestlazJSONRPCRequestAsStream;
var
  ssRequestEmpty: TStringStream;
  sRequestEmpty: TStream;
begin
  FRequest:= TJSONRPCRequest.Create(cjRequestEmpty);
  AssertFalse('Request is not a notification', FRequest.Notification);
  ssRequestEmpty:= TStringStream.Create('', TEncoding.UTF8);
  sRequestEmpty:= FRequest.AsStream;
  ssRequestEmpty.LoadFromStream(sRequestEmpty);
  sRequestEmpty.Free;
  AssertEquals('Request AsStream matches', cjRequestEmpty, ssRequestEmpty.DataString);
  ssRequestEmpty.Free;
  FRequest.Free;
end;

initialization
  RegisterTest(TTestlazJSONRPCRequest);
end.


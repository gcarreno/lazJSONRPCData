{ Implement Test Request Object

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
, fpjson
, LJD.Request
;

type

  { TTestNosoPoolStratumJSONRPCRequest }

  TTestNosoPoolStratumJSONRPCRequest= class(TTestCase)
  private
    FRequest: TRequestParamsArray;

    procedure CheckFieldsCreate;
    procedure CheckFieldsCreateNotification;
    procedure CheckFieldsCreateRequestEmpty;
    procedure CheckFieldsCreateWithMethod;
  published
    procedure TestStratumJSONRPCRequestCreate;

    procedure TestStratumJSONRPCRequestCreateFromJSONData;
    procedure TestStratumJSONRPCRequestCreateFromJSONObject;
    procedure TestStratumJSONRPCRequestCreateFromStream;

    procedure TestStratumJSONRPCRequestCreateNotification;
    procedure TestStratumJSONRPCRequestCreateRequestEmpty;
    procedure TestStratumJSONRPCRequestCreateExceptionEmptyString;
    procedure TestStratumJSONRPCRequestCreateExceptionCannotParse;
    procedure TestStratumJSONRPCRequestCreateExceptionMissingMembers;
    procedure TestStratumJSONRPCRequestCreateWithMethod;

    procedure TestStratumJSONRPCRequestCreateAsJSON;
    procedure TestStratumJSONRPCRequestCreateAsJSONNotification;
    procedure TestStratumJSONRPCRequestCreateAsJSONData;
    procedure TestStratumJSONRPCRequestCreateAsJSONObject;
    procedure TestStratumJSONRPCRequestCreateAsStream;
  end;

implementation

uses
  LJD.JSON.Utils
;

const
  cjRequestEmpty : TJSONStringType =
    '{'+
      '"'+ cjJSONRPC +'":"'+cjJSONRPCversion+'",'+
      '"'+ cjMethod +'":"",'+
      '"'+ cjParams +'":[],'+
      '"'+ cjID +'":1'+
    '}'
  ;
  cjRequestMissingJSONRPC : TJSONStringType =
    '{'+
      '"'+ cjMethod +'":"",'+
      '"'+ cjParams +'":[],'+
      '"'+ cjID +'":1'+
    '}'
  ;
  cjRequestMissingMethod : TJSONStringType =
    '{'+
      '"'+ cjJSONRPC +'":"'+cjJSONRPCversion+'",'+
      '"'+ cjParams +'":[],'+
      '"'+ cjID +'":1'+
    '}'
  ;
  cjRequestMissingParams : TJSONStringType =
    '{'+
      '"'+ cjJSONRPC +'":"'+cjJSONRPCversion+'",'+
      '"'+ cjMethod +'":"",'+
      '"'+ cjID +'":1'+
    '}'
  ;
  cjRequestNotification : TJSONStringType =
    '{'+
      '"'+ cjJSONRPC +'":"'+cjJSONRPCversion+'",'+
      '"'+ cjMethod +'":"",'+
      '"'+ cjParams +'":[]'+
    '}'
  ;
  cjRequestEchoWithMethod : TJSONStringType =
    '{'+
      '"'+ cjJSONRPC +'":"'+cjJSONRPCversion+'",'+
      '"'+ cjMethod +'":"mining.authorize",'+
      '"'+ cjParams +'":["login", "password"],'+
      '"'+ cjID +'":1'+
    '}'
  ;

procedure TTestNosoPoolStratumJSONRPCRequest.CheckFieldsCreate;
begin
  AssertEquals('Request '+cjJSONRPC+' is '+cjJSONRPCversion, cjJSONRPCversion, FRequest.JSONRPC);
  AssertEquals('Request '+cjMethod+' is Empty', EmptyStr, FRequest.Method);
  AssertNotNull('Request '+cjParams+' is not null', FRequest.Params);
  AssertEquals('Request '+cjParams+' array is empty', 0, FRequest.Params.Count);
  AssertEquals('Request '+cjID+' is -1', -1, FRequest.ID);
  AssertFalse('Request is not a notification', FRequest.Notification);
end;

procedure TTestNosoPoolStratumJSONRPCRequest.CheckFieldsCreateNotification;
begin
  AssertEquals('Request '+cjJSONRPC+' is '+cjJSONRPCversion, cjJSONRPCversion, FRequest.JSONRPC);
  AssertEquals('Request '+cjMethod+' is Empty', EmptyStr, FRequest.Method);
  AssertNotNull('Request '+cjParams+' is not null', FRequest.Params);
  AssertEquals('Request '+cjParams+' array is empty', 0, FRequest.Params.Count);
  AssertTrue('Request is a notification', FRequest.Notification);
end;

procedure TTestNosoPoolStratumJSONRPCRequest.CheckFieldsCreateRequestEmpty;
begin
  AssertEquals('Request '+cjJSONRPC+' is '+cjJSONRPCversion, cjJSONRPCversion, FRequest.JSONRPC);
  AssertEquals('Request '+cjMethod+' is Empty', EmptyStr, FRequest.Method);
  AssertNotNull('Request '+cjParams+' is not null', FRequest.Params);
  AssertEquals('Request '+cjParams+' array is empty', 0, FRequest.Params.Count);
  AssertEquals('Request '+cjID+' is 1', 1, FRequest.ID);
end;

procedure TTestNosoPoolStratumJSONRPCRequest.CheckFieldsCreateWithMethod;
begin
  AssertEquals('Request '+cjJSONRPC+' is '+cjJSONRPCversion, cjJSONRPCversion, FRequest.JSONRPC);
  AssertEquals('Request '+cjMethod+' is mining.authorize', 'mining.authorize', FRequest.Method);
  AssertNotNull('Request '+cjParams+' is not null', FRequest.Params);
  AssertEquals('Request '+cjParams+' count is 2', 2, FRequest.Params.Count);
  { TODO 100 -ogcarreno : Why does this go BOOM only here ?!?!?! }
  //AssertEquals('Request '+cjParams+' item[0] is "login""', 'login', FRequest.Params[0].AsString);
  //AssertEquals('Request '+cjParams+' item[0] is "password""', 'password', FRequest.Params[1].AsString);
  AssertEquals('Request '+cjID+' is 1', 1, FRequest.ID);
end;

procedure TTestNosoPoolStratumJSONRPCRequest.TestStratumJSONRPCRequestCreate;
begin
  FRequest:= TRequestParamsArray.Create;
  CheckFieldsCreate;
  FRequest.Free;
end;

procedure TTestNosoPoolStratumJSONRPCRequest.TestStratumJSONRPCRequestCreateFromJSONData;
begin
  FRequest:= TRequestParamsArray.Create(GetJSONData(cjRequestEmpty));
  CheckFieldsCreateRequestEmpty;
  FRequest.Free;
end;

procedure TTestNosoPoolStratumJSONRPCRequest.TestStratumJSONRPCRequestCreateFromJSONObject;
begin
  FRequest:= TRequestParamsArray.Create(TJSONObject(GetJSONData(cjRequestEmpty)));
  CheckFieldsCreateRequestEmpty;
  FRequest.Free;
end;

procedure TTestNosoPoolStratumJSONRPCRequest.TestStratumJSONRPCRequestCreateFromStream;
begin
  FRequest:= TRequestParamsArray.Create(TStringStream.Create(cjRequestEmpty, TEncoding.UTF8));
  CheckFieldsCreateRequestEmpty;
  FRequest.Free;
end;

procedure TTestNosoPoolStratumJSONRPCRequest.TestStratumJSONRPCRequestCreateNotification;
begin
  FRequest:= TRequestParamsArray.Create(cjRequestNotification);
  CheckFieldsCreateNotification;
  FRequest.Free;
end;

procedure TTestNosoPoolStratumJSONRPCRequest.TestStratumJSONRPCRequestCreateRequestEmpty;
begin
  FRequest:= TRequestParamsArray.Create(cjRequestEmpty);
  CheckFieldsCreateRequestEmpty;
  FRequest.Free;
end;

procedure TTestNosoPoolStratumJSONRPCRequest.TestStratumJSONRPCRequestCreateExceptionEmptyString;
var
  error: Integer = 0;
begin
  try
    FRequest:= TRequestParamsArray.Create('');
  except
    on E: ERequestEmptyString do
      error:= -32700;
  end;
  AssertEquals('Request Error Empty String', -32700, error);
end;

procedure TTestNosoPoolStratumJSONRPCRequest.TestStratumJSONRPCRequestCreateExceptionCannotParse;
var
  error: Integer = 0;
begin
  try
    FRequest:= TRequestParamsArray.Create('Not Valid JSON');
  except
    on E: ERequestCannotParse do
      error:= -32700;
  end;
  AssertEquals('Request Error Cannot Parse', -32700, error);
end;

procedure TTestNosoPoolStratumJSONRPCRequest.TestStratumJSONRPCRequestCreateExceptionMissingMembers;
var
  error: Integer;
begin
  // Missing JSON-RPC
  error:= 0;
  try
    FRequest:= TRequestParamsArray.Create(cjRequestMissingJSONRPC);
  except
    on E: ERequestMissingMember do
      error:= -32600;
  end;
  AssertEquals('Request Error Cannot Parse', -32600, error);
  // Missing Method
  error:= 0;
  try
    FRequest:= TRequestParamsArray.Create(cjRequestMissingMethod);
  except
    on E: ERequestMissingMember do
      error:= -32600;
  end;
  AssertEquals('Request Error Cannot Parse', -32600, error);
  // Missing Params
  error:= 0;
  try
    FRequest:= TRequestParamsArray.Create(cjRequestMissingParams);
  except
    on E: ERequestMissingMember do
      error:= -32600;
  end;
  AssertEquals('Request Error Cannot Parse', -32600, error);
end;

procedure TTestNosoPoolStratumJSONRPCRequest.TestStratumJSONRPCRequestCreateWithMethod;
begin
  FRequest:= TRequestParamsArray.Create(cjRequestEchoWithMethod);
  CheckFieldsCreateWithMethod;
  FRequest.Free;
end;

procedure TTestNosoPoolStratumJSONRPCRequest.TestStratumJSONRPCRequestCreateAsJSON;
begin
  FRequest:= TRequestParamsArray.Create(cjRequestEmpty);
  AssertFalse('Request is not a notification', FRequest.Notification);
  AssertEquals('Request AsJSON matches', cjRequestEmpty, FRequest.AsJSON);
  FRequest.Free;
end;

procedure TTestNosoPoolStratumJSONRPCRequest.TestStratumJSONRPCRequestCreateAsJSONNotification;
begin
  FRequest:= TRequestParamsArray.Create(cjRequestNotification);
  AssertTrue('Request is a notification', FRequest.Notification);
  AssertEquals('Request AsJSON Notification matches', cjRequestNotification, FRequest.AsJSON);
  FRequest.Free;
end;

procedure TTestNosoPoolStratumJSONRPCRequest.TestStratumJSONRPCRequestCreateAsJSONData;
begin
  FRequest:= TRequestParamsArray.Create(cjRequestEmpty);
  AssertFalse('Request is not a notification', FRequest.Notification);
  AssertEquals('Request AsJSONData matches', cjRequestEmpty, FRequest.AsJSONData.AsJSON);
  FRequest.Free;
end;

procedure TTestNosoPoolStratumJSONRPCRequest.TestStratumJSONRPCRequestCreateAsJSONObject;
begin
  FRequest:= TRequestParamsArray.Create(cjRequestEmpty);
  AssertFalse('Request is not a notification', FRequest.Notification);
  AssertEquals('Request AsJSONObject matches', cjRequestEmpty, FRequest.AsJSONObject.AsJSON);
  FRequest.Free;
end;

procedure TTestNosoPoolStratumJSONRPCRequest.TestStratumJSONRPCRequestCreateAsStream;
var
  ssRequest: TStringStream;
begin
  FRequest:= TRequestParamsArray.Create(cjRequestEmpty);
  AssertFalse('Request is not a notification', FRequest.Notification);
  ssRequest:= TStringStream.Create('', TEncoding.UTF8);
  ssRequest.LoadFromStream(FRequest.AsStream);
  AssertEquals('Request AsStream matches', cjRequestEmpty, ssRequest.DataString);
  ssRequest.Free;
  FRequest.Free;
end;

initialization
  RegisterTest(TTestNosoPoolStratumJSONRPCRequest);
end.


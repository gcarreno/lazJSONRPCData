{ Implements Test Response Object

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
unit Test.LJD.Response;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, fpcunit
//, testutils
, testregistry
, LJD.Response
;

type
{ TTestlazJSONRPCResponse }
  TTestlazJSONRPCResponse= class(TTestCase)
  private
    FResponse: TResponse;

    procedure CheckFieldsCreate;
    procedure CheckFieldsCreateEmpty;
  protected
  public
  published
    procedure TestlazJSONRPCResponseCreate;

    procedure TestlazJSONRPCResponseCreateFromJSON;
    procedure TestlazJSONRPCResponseCreateFromJSONData;
    procedure TestlazJSONRPCResponseCreateFromJSONObject;
    procedure TestlazJSONRPCResponseCreateFromStream;

    procedure TestlazJSONRPCResponseAsJSON;
    procedure TestlazJSONRPCResponseAsJSONData;
    procedure TestlazJSONRPCResponseAsJSONObject;
    procedure TestlazJSONRPCResponseAsStream;
  end;

implementation

uses
  fpjson
;

const
  cjResponseEmpty: TJSONStringType =
    '{'+
      '"'+ cjJSONRPC +'":"'+cjJSONRPCversion+'",'+
      '"'+ cjResult +'":"",'+
      '"'+ cjID +'":1'+
    '}'
  ;
  cjResponseErrorEmpty: TJSONStringType =
    '{'+
      '"'+ cjJSONRPC +'":"'+cjJSONRPCversion+'",'+
      '"'+ cjError +'":{"code":0,"message":""},'+
      '"'+ cjID +'":1'+
    '}'
  ;
  cjResponseErrorIdNullEmpty: TJSONStringType =
    '{'+
      '"'+ cjJSONRPC +'":"'+cjJSONRPCversion+'",'+
      '"'+ cjError +'":{"code":0,"message":""},'+
      '"'+ cjID +'":null'+
    '}'
  ;

{ TTestlazJSONRPCResponse }

procedure TTestlazJSONRPCResponse.CheckFieldsCreate;
begin
  AssertEquals('Response '+cjJSONRPC+' is '+cjJSONRPCversion, cjJSONRPCversion, FResponse.JSONRPC);
  AssertTrue('Response Has '+cjResult+' is True', FResponse.HasResult);
  AssertNull('Response '+cjResult+' is null', FResponse.Result);
  AssertFalse('Response Has '+cjError+' is False', FResponse.HasError);
  AssertNull('Response '+cjError+' is null', FResponse.Error);
  AssertEquals('Response '+cjID+' is -1', -1, FResponse.ID);
  //AssertEquals('Response '+cj+' is ', , );
end;

procedure TTestlazJSONRPCResponse.CheckFieldsCreateEmpty;
begin
  AssertEquals('Response '+cjJSONRPC+' is '+cjJSONRPCversion, cjJSONRPCversion, FResponse.JSONRPC);
  AssertTrue('Response Has '+cjResult+' is True', FResponse.HasResult);
  AssertNotNull('Response '+cjResult+' is not null', FResponse.Result);
  AssertFalse('Response Has '+cjError+' is False', FResponse.HasError);
  AssertNull('Response '+cjError+' is null', FResponse.Error);
  AssertEquals('Response '+cjID+' is 1', 1, FResponse.ID);
end;

procedure TTestlazJSONRPCResponse.TestlazJSONRPCResponseCreate;
begin
  FResponse:= TResponse.Create;
  CheckFieldsCreate;
  FResponse.Free;
end;

procedure TTestlazJSONRPCResponse.TestlazJSONRPCResponseCreateFromJSON;
begin
  FResponse:= TResponse.Create(cjResponseEmpty);
  CheckFieldsCreateEmpty;
  FResponse.Free;
end;

procedure TTestlazJSONRPCResponse.TestlazJSONRPCResponseCreateFromJSONData;
var
  jData: TJSONData = nil;
begin
  jData:= GetJSON(cjResponseEmpty);
  FResponse:= TResponse.Create(jData);
  jData.Free;
  CheckFieldsCreateEmpty;
  FResponse.Free;
end;

procedure TTestlazJSONRPCResponse.TestlazJSONRPCResponseCreateFromJSONObject;
var
  jData: TJSONData = nil;
begin
  jData:= GetJSON(cjResponseEmpty);
  FResponse:= TResponse.Create(TJSONObject(jData));
  jData.Free;
  CheckFieldsCreateEmpty;
  FResponse.Free;
end;

procedure TTestlazJSONRPCResponse.TestlazJSONRPCResponseCreateFromStream;
var
  ssRequestEmpty: TStringStream = nil;
begin
  ssRequestEmpty:= TStringStream.Create(cjResponseEmpty, TEncoding.UTF8);
  FResponse:= TResponse.Create(ssRequestEmpty);
  ssRequestEmpty.Free;
  CheckFieldsCreateEmpty;
  FResponse.Free;
end;

procedure TTestlazJSONRPCResponse.TestlazJSONRPCResponseAsJSON;
begin
  FResponse:= TResponse.Create(cjResponseEmpty);
  AssertEquals('Response AsJSON matches', cjResponseEmpty, FResponse.AsJSON);
  FResponse.Free;
end;

procedure TTestlazJSONRPCResponse.TestlazJSONRPCResponseAsJSONData;
var
  jData: TJSONData = nil;
begin
  FResponse:= TResponse.Create(cjResponseEmpty);
  jData:= FResponse.AsJSONData;
  AssertEquals('Response AsJSONData matches', cjResponseEmpty, jData.AsJSON);
  jData.Free;
  FResponse.Free;
end;

procedure TTestlazJSONRPCResponse.TestlazJSONRPCResponseAsJSONObject;
var
  jObject: TJSONObject = nil;
begin
  FResponse:= TResponse.Create(cjResponseEmpty);
  jObject:= FResponse.AsJSONObject;
  AssertEquals('Response AsJSONObject matches', cjResponseEmpty, jObject.AsJSON);
  jObject.Free;
  FResponse.Free;
end;

procedure TTestlazJSONRPCResponse.TestlazJSONRPCResponseAsStream;
var
  ssResponseEmpty: TStringStream;
  sResponseEmpty: TStream;
begin
  FResponse:= TResponse.Create(cjResponseEmpty);
  ssResponseEmpty:= TStringStream.Create('', TEncoding.UTF8);
  sResponseEmpty:= FResponse.AsStream;
  ssResponseEmpty.LoadFromStream(sResponseEmpty);
  sResponseEmpty.Free;
  AssertEquals('Response AsJSONObject matches', cjResponseEmpty, ssResponseEmpty.DataString);
  ssResponseEmpty.Free;
  FResponse.Free;
end;

initialization
  RegisterTest(TTestlazJSONRPCResponse);
end.


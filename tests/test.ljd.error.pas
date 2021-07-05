{ Implements Test Error Object

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
unit Test.LJD.Error;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, fpcunit
//, testutils
, testregistry
, LJD.Error
;

type
{ TTestlazJSONRPCError }
  TTestlazJSONRPCError= class(TTestCase)
  private
    FError: TError;

    procedure CheckFieldsCreate;
    procedure CheckFieldsCreateEmpty;
    procedure CheckFieldsCreateEmptyWithData;
  protected
  public
  published
    procedure TestlazJSONRPCErrorCreate;

    procedure TestlazJSONRPCErrorCreateFromJSON;
    procedure TestlazJSONRPCErrorCreateFromJSONData;
    procedure TestlazJSONRPCErrorCreateFromJSONObject;
    procedure TestlazJSONRPCErrorCreateFromStream;

    procedure TestlazJSONRPCErrorCreateEmptyWithData;

    procedure TestlazJSONRPCErrorAsJSON;
    procedure TestlazJSONRPCErrorAsJSONData;
    procedure TestlazJSONRPCErrorAsJSONObject;
    procedure TestlazJSONRPCErrorAsStream;
  end;

implementation

uses
  fpjson
, jsonparser
;

const
  cjErrorEmpty: TJSONStringType =
    '{'+
      '"'+cjCode+'":0,'+
      '"'+cjMessage+'":""'+
    '}'
  ;
  cjErrorEmptyWithData: TJSONStringType =
    '{'+
      '"'+cjCode+'":0,'+
      '"'+cjMessage+'":"",'+
      '"'+cjData+'":"A"'+
    '}'
  ;

{ TTestlazJSONRPCError }

procedure TTestlazJSONRPCError.CheckFieldsCreate;
begin
  AssertEquals('Error Object '+cjCode+' is 0', 0, FError.Code);
  AssertEquals('Error Object '+cjMessage+' is Empty', EmptyStr, FError.Message);
  AssertFalse('Error Object Has Data is false', FError.HasData);
  AssertEquals('Error Object '+cjData+' is Empty', EmptyStr, FError.Data);
  //AssertEquals('Error '+cj+' is ', , );
end;

procedure TTestlazJSONRPCError.CheckFieldsCreateEmpty;
begin
  AssertEquals('Error Object '+cjCode+' is 0', 0, FError.Code);
  AssertEquals('Error Object '+cjMessage+' is Empty', EmptyStr, FError.Message);
  AssertFalse('Error Object Has Data is false', FError.HasData);
  AssertEquals('Error Object '+cjData+' is Empty', EmptyStr, FError.Data);
end;

procedure TTestlazJSONRPCError.CheckFieldsCreateEmptyWithData;
begin
  AssertEquals('Error Object '+cjCode+' is 0', 0, FError.Code);
  AssertEquals('Error Object '+cjMessage+' is Empty', EmptyStr, FError.Message);
  AssertTrue('Error Object Has Data is True', FError.HasData);
  AssertEquals('Error Object '+cjData+' is A', 'A', FError.Data);
end;

procedure TTestlazJSONRPCError.TestlazJSONRPCErrorCreate;
begin
  FError:= TError.Create;
  CheckFieldsCreate;
  FError.Free;
end;

procedure TTestlazJSONRPCError.TestlazJSONRPCErrorCreateFromJSON;
begin
  FError:= TError.Create(cjErrorEmpty);
  CheckFieldsCreateEmpty;
  FError.Free;
end;

procedure TTestlazJSONRPCError.TestlazJSONRPCErrorCreateFromJSONData;
var
  jData: TJSONData = nil;
begin
  jData:= GetJSON(cjErrorEmpty);
  FError:= TError.Create(jData);
  jData.Free;
  CheckFieldsCreateEmpty;
  FError.Free;
end;

procedure TTestlazJSONRPCError.TestlazJSONRPCErrorCreateFromJSONObject;
var
  jData: TJSONData = nil;
begin
  jData:= GetJSON(cjErrorEmpty);
  FError:= TError.Create(TJSONObject(jData));
  jData.Free;
  CheckFieldsCreateEmpty;
  FError.Free;
end;

procedure TTestlazJSONRPCError.TestlazJSONRPCErrorCreateFromStream;
var
  ssErrorEmpty: TStringStream = nil;
begin
  ssErrorEmpty:= TStringStream.Create(cjErrorEmpty, TEncoding.UTF8);
  FError:= TError.Create(ssErrorEmpty);
  ssErrorEmpty.Free;
  CheckFieldsCreateEmpty;
  FError.Free;
end;

procedure TTestlazJSONRPCError.TestlazJSONRPCErrorCreateEmptyWithData;
begin
  FError:= TError.Create(cjErrorEmptyWithData);
  CheckFieldsCreateEmptyWithData;
  FError.Free;
end;

procedure TTestlazJSONRPCError.TestlazJSONRPCErrorAsJSON;
begin
  FError:= TError.Create(cjErrorEmpty);
  AssertEquals('Error Object AsJSON matches', cjErrorEmpty, FError.AsJSON);
  FError.Free;
end;

procedure TTestlazJSONRPCError.TestlazJSONRPCErrorAsJSONData;
var
  jData: TJSONData = nil;
begin
  FError:= TError.Create(cjErrorEmpty);
  jData:= FError.AsJSONData;
  AssertEquals('Error Object AsJSONData matches', cjErrorEmpty, jData.AsJSON);
  jData.Free;
  FError.Free;
end;

procedure TTestlazJSONRPCError.TestlazJSONRPCErrorAsJSONObject;
var
  jObject: TJSONObject = nil;
begin
  FError:= TError.Create(cjErrorEmpty);
  jObject:= FError.AsJSONObject;
  AssertEquals('Error Object AsJSONObject matches', cjErrorEmpty, jObject.AsJSON);
  jObject.Free;
  FError.Free;
end;

procedure TTestlazJSONRPCError.TestlazJSONRPCErrorAsStream;
var
  ssErrorEmpty: TStringStream = nil;
  sErrorEmpty: TStream = nil;
begin
  FError:= TError.Create(cjErrorEmpty);
  ssErrorEmpty:= TStringStream.Create('', TEncoding.UTF8);
  sErrorEmpty:= FError.AsStream;
  ssErrorEmpty.LoadFromStream(sErrorEmpty);
  sErrorEmpty.Free;
  AssertEquals('Error Object AsStream matches', cjErrorEmpty, ssErrorEmpty.DataString);
  ssErrorEmpty.Free;
  FError.Free;
end;

initialization
  RegisterTest(TTestlazJSONRPCError);
end.


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
, fpjson
, LJD.Response
;

type
{ TTestlazJSONRPCResponse }
  TTestlazJSONRPCResponse= class(TTestCase)
  private
    FResponse: TResponse;

    procedure CheckFieldsCreate;
  protected
  public
  published
    procedure TestlazJSONRPCResponseCreate;
  end;

implementation

{ TTestlazJSONRPCResponse }

procedure TTestlazJSONRPCResponse.CheckFieldsCreate;
begin
  AssertEquals('Response '+cjJSONRPC+' is '+cjJSONRPCversion, cjJSONRPCversion, FResponse.JSONRPC);

  AssertEquals('Response '+cjID+' is -1', -1, FResponse.ID);
  AssertFalse('Response is not error', FResponse.IsError);
end;

procedure TTestlazJSONRPCResponse.TestlazJSONRPCResponseCreate;
begin
  FResponse:= TResponse.Create;
  CheckFieldsCreate;
  FResponse.Free;
end;

initialization
  RegisterTest(TTestlazJSONRPCResponse);
end.


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
, LJD.Error
;

type
{ TResponse }
  TResponse = class(TObject)
  private
    FJSONRPC: TJSONStringType;
    FResult: TJSONStringType;
    FHasError: Boolean;
    FError: TError;
    FIDIsNull: Boolean;
    FID: Int64;

    FCompressedJSON: Boolean;
  protected
  public
    constructor Create;

    property JSONRPC: TJSONStringType
      read FJSONRPC;
    property Result: TJSONStringType
      read FResult
      write FResult;
    property HasError: Boolean
      read FHasError
      write FHasError;
    property Error: TError
      read FError;
    property IDIsNull: Boolean
      read FIDIsNull
      write FIDIsNull;
    property ID: Int64
      read FID
      write FID;

    property CompressedJSON: Boolean
      read FCompressedJSON
      write FCompressedJSON;
  published
  end;

const
  cjJSONRPCversion = '2.0';

  cjJSONRPC = 'jsonrpc';
  cjResult = 'result';
  cjError = 'error';
  cjID = 'ID';

implementation

uses
  LJD.JSON.Utils
;

{ TResponse }

constructor TResponse.Create;
begin
  FCompressedJSON:= True;

  FJSONRPC:= cjJSONRPCversion;
  FResult:= EmptyStr;
  FHasError:= False;
  FError:= nil;
  FIDIsNull:= False;
  FID:= -1;
end;

end.


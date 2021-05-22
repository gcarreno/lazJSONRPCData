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
{ TError }
  TError = class(TObject)
  private
    FCode: Integer;
    FID: Integer;
    FMessage: TJSONStringType;
    FData: TJSONStringType;

    FHasData: Boolean;

    FCompressedJSON: Boolean;
    function GetData: TJSONData;
  protected
  public
    constructor Create;

    property Code: Integer
      read FCode
      write FID;
    property Message: TJSONStringType
      read FMessage
      write FMessage;
    property Data: TJSONData
      read GetData;

    property HasData: Boolean
      read FHasData;

    property CompressedJSON: Boolean
      read FCompressedJSON
      write FCompressedJSON;
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
  rsMessageParseError     = 'Parse error';
  rsMessageInvalidRequest = 'Invalid request';
  rsMessageMethodNotFound = 'Method not found';
  rsMessageInvalidParams  = 'Invalid params';
  rsMessageInternalError  = 'Internal Error';

implementation

uses
  LJD.JSON.Utils
;

{ TError }

function TError.GetData: TJSONData;
begin
  Result:= GetJSONData(FData);
end;

constructor TError.Create;
begin
  FCompressedJSON:= True;

  FCode:= 0;
  FMessage:= EmptyStr;
  FData:= EmptyStr;
  FHasData:= False;
end;

end.


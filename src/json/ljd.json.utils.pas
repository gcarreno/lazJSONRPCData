unit LJD.JSON.Utils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, fpjson
, jsonparser
, jsonscanner
;

function GetJSONData(const aJSON: TJSONStringType): TJSONData;
function GetJSONData(const aStream: TStream): TJSONData;

implementation

function GetJSONData(const aJSON: TJSONStringType): TJSONData;
var
  jParser: TJSONParser;
begin
  Result := nil;
{$IF FPC_FULLVERSION >= 30002}
  jParser := TJSONParser.Create(aJSON, [joUTF8, joIgnoreTrailingComma]);
{$ELSE}
  jParser := TJSONParser.Create(aJSON, True);
{$ENDIF}
  try
    Result := jParser.Parse;
  finally
    jParser.Free;
  end;
end;

function GetJSONData(const aStream: TStream): TJSONData;
var
  jParser: TJSONParser;
begin
  Result:= nil;
  aStream.Position:= 0;
{$IF FPC_FULLVERSION >= 30002}
  jParser:= TJSONParser.Create(aStream, [joUTF8, joIgnoreTrailingComma]);
{$ELSE}
  jParser := TJSONParser.Create(aStream, True);
{$ENDIF}
  try
    Result:= jParser.Parse;
  finally
    jParser.Free;
  end;
end;

end.


//
// This unit is part of the DGLEngine Project, http://glscene.org
//
{ @HTML ( PictureRegisteredFormats<p>

   Hacks into the VCL to access the list of TPicture registered TGraphic formats<p>

   <b>History : </b><font size=-1><ul>
      <li>24/12/15 - JD - Imported From GLScene
   </ul></font>
}
unit DGLPictureRegisteredFormats;

interface

{$I DGLEngine.inc}

uses
  System.Classes,
  VCL.Graphics,
  DGLCrossPlatform;

{$DEFINE PRF_HACK_PASSES}

{ @HTML ( Returns the TGraphicClass associated to the extension, if any.<p>
   Accepts anExtension with or without the '.' }
function GraphicClassForExtension(const anExtension: string): TGraphicClass;

{ @HTML ( Adds to the passed TStrings the list of registered formats.<p>
   Convention is "extension=description" for the string, the Objects hold
   the corresponding TGraphicClass (extensions do not include the '.'). }
procedure HackTPictureRegisteredFormats(destList: TStrings);

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

type
  PInteger = ^integer;

// GraphicClassForExtension

function GraphicClassForExtension(const anExtension: string): TGraphicClass;
var
  i: integer;
  sl: TStringList;
  buf: string;
begin
  Result := nil;
  if anExtension = '' then
    Exit;
  if anExtension[1] = '.' then
    buf := Copy(anExtension, 2, MaxInt)
  else
    buf := anExtension;
  sl := TStringList.Create;
  try
    HackTPictureRegisteredFormats(sl);
    i := sl.IndexOfName(buf);
    if i >= 0 then
      Result := TGraphicClass(sl.Objects[i]);
  finally
    sl.Free;
  end;
end;

type
  PFileFormat = ^TFileFormat;

  TFileFormat = record
    GraphicClass: TGraphicClass;
    Extension: string;
    Description: string;
    DescResID: integer;
  end;

// HackTPictureRegisteredFormats
{$ifopt R+}
  {$define HackTPictureRegisteredFormats_Disable_RangeCheck}
  {$R-}
{$endif}
procedure HackTPictureRegisteredFormats(destList: TStrings);
var
  pRegisterFileFormat, pCallGetFileFormat, pGetFileFormats, pFileFormats: PAnsiChar;
  iCall: cardinal;
  i: integer;
  list: TList;
  fileFormat: PFileFormat;
begin
  {$MESSAGE Hint 'HackTPictureRegisteredFormats will crash when Graphics.pas is compiled with the 'Use Debug DCUs' option'}

  pRegisterFileFormat := PAnsiChar(@TPicture.RegisterFileFormat);
  if pRegisterFileFormat[0] = #$FF then // in case of BPL redirector
    pRegisterFileFormat := PAnsiChar(PCardinal(PCardinal(@pRegisterFileFormat[2])^)^);
  pCallGetFileFormat := @pRegisterFileFormat[16];
  iCall := PCardinal(pCallGetFileFormat)^;
  pGetFileFormats := @pCallGetFileFormat[iCall + 4];
  pFileFormats := PAnsiChar(PCardinal(@pGetFileFormats[2])^);
  list := TList(PCardinal(pFileFormats)^);

  if list <> nil then
  begin
    for i := 0 to list.Count - 1 do
    begin
      fileFormat := PFileFormat(list[i]);
      destList.AddObject(fileFormat.Extension + '=' + fileFormat.Description,
        TObject(fileFormat.GraphicClass));
    end;
  end;
end;

{$IFDEF HackTPictureRegisteredFormats_Disable_RangeCheck}
  {$R+}
  {$undef HackTPictureRegisteredFormats_Disable_RangeCheck}
{$ENDIF}

end.


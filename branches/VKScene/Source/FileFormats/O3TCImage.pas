//
// This unit is part of the GLScene Project   
//
{: O3TCImage<p>
    Good for preview picture in OpenDialog,
    so you may include both O3TCImage (preview) and GLFileO3TC (loading)

      <li>23/10/10 - Yar - Removed PBuffer    
      <li>23/08/10 - Yar - Changes after PBuffer upgrade
      <li>21/03/10 - Yar - Added Linux support
                           (thanks to Rustam Asmandiarov aka Predator)
      <li>24/01/10 - Yar - Improved FPC compatibility
      <li>21/01/10 - Yar - Creation
   </ul></font>
}

unit O3TCImage;

interface

{$I VKScene.inc}

uses
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF}
  System.Classes,
  System.SysUtils,
  VKS.CrossPlatform,
  VKS.VectorGeometry,
  VKS.Graphics,
  VKS.OpenGLTokens;

type

  TO3TCImage = class(TVKBitmap)
  public
    { Public Declarations }
    procedure LoadFromStream(stream: TStream); override;
    procedure SaveToStream(stream: TStream); override;
  end;

implementation

uses
  GLFileO3TC,
  VKS.TextureFormat;

// ------------------
// ------------------ TO3TCImage ------------------
// ------------------

// LoadFromStream
//

procedure TO3TCImage.LoadFromStream(stream: TStream);
var
  FullO3TC: TVKO3TCImage;
  src, dst: PGLubyte;
  y: Integer;
begin
  FullO3TC := TVKO3TCImage.Create;
  try
    FullO3TC.LoadFromStream(stream);
  except
    FullO3TC.Free;
    raise;
  end;

  FullO3TC.Narrow;

  Width := FullO3TC.LevelWidth[0];
  Height := FullO3TC.LevelHeight[0];
  Transparent := true;
  PixelFormat := glpf32bit;

  src := PGLubyte(FullO3TC.Data);
  for y := 0 to Height - 1 do
  begin
    dst := ScanLine[Height - 1 - y];
    BGRA32ToRGBA32(src, dst, Width);
    Inc(src, Width * 4);
  end;
  FullO3TC.Free;
end;

// SaveToStream
//

procedure TO3TCImage.SaveToStream(stream: TStream);
begin
  Assert(False, 'Not supported');
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------

  TVKPicture.RegisterFileFormat(
    'o3tc', 'oZone3D Texture Compression', TO3TCImage);

  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
finalization
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------

  TVKPicture.UnregisterGraphicClass(TO3TCImage);

end.


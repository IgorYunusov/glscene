//
// VKScene Component Library, based on GLScene http://glscene.sourceforge.net 
//

unit GLX.FileJPEG;

interface

{$I VKScene.inc}

uses
  System.Classes, System.SysUtils,
  GLX.CrossPlatform, Winapi.OpenGL, Winapi.OpenGLext,  GLX.Context, GLX.Graphics, GLX.TextureFormat,
  GLX.ApplicationFileIO;

type

  TGLJPEGImage = class(TGLBaseImage)
  private
    FAbortLoading: boolean;
    FDivScale: longword;
    FDither: boolean;
    FSmoothing: boolean;
    FProgressiveEncoding: boolean;
    procedure SetSmoothing(const AValue: boolean);
  public
    constructor Create; override;
    class function Capabilities: TGLDataFileCapabilities; override;

    procedure LoadFromFile(const filename: string); override;
    procedure SaveToFile(const filename: string); override;
    procedure LoadFromStream(stream: TStream); override;
    procedure SaveToStream(stream: TStream); override;

    { Assigns from any Texture.}
    procedure AssignFromTexture(textureContext: TGLContext;
      const textureHandle: GLuint;
      textureTarget: TGLTextureTarget;
      const CurrentFormat: boolean;
      const intFormat: GLinternalFormat); reintroduce;

    property DivScale: longword read FDivScale write FDivScale;
    property Dither: boolean read FDither write FDither;
    property Smoothing: boolean read FSmoothing write SetSmoothing;
    property ProgressiveEncoding: boolean read FProgressiveEncoding;
  end;

implementation

uses
   GLX.VectorGeometry;

// ------------------
// ------------------ TGLJPEGImage ------------------
// ------------------

constructor TGLJPEGImage.Create;
begin
  inherited;
  FAbortLoading := False;
  FDivScale := 1;
  FDither := False;
end;

// LoadFromFile


procedure TGLJPEGImage.LoadFromFile(const filename: string);
var
  fs: TStream;
begin
  if FileStreamExists(fileName) then
  begin
    fs := CreateFileStream(fileName, fmOpenRead);
    try
      LoadFromStream(fs);
    finally
      fs.Free;
      ResourceName := filename;
    end;
  end
  else
    raise EInvalidRasterFile.CreateFmt('File %s not found', [filename]);
end;

// SaveToFile


procedure TGLJPEGImage.SaveToFile(const filename: string);
var
  fs: TStream;
begin
  fs := CreateFileStream(fileName, fmOpenWrite or fmCreate);
  try
    SaveToStream(fs);
  finally
    fs.Free;
  end;
  ResourceName := filename;
end;

// LoadFromStream

procedure TGLJPEGImage.LoadFromStream(stream: TStream);
begin
  //Do nothing
end;


procedure TGLJPEGImage.SaveToStream(stream: TStream);
begin
  //Do nothing
end;

// AssignFromTexture


procedure TGLJPEGImage.AssignFromTexture(textureContext: TGLContext;
  const textureHandle: GLuint; textureTarget: TGLTextureTarget;
  const CurrentFormat: boolean; const intFormat: GLinternalFormat);
begin

end;

procedure TGLJPEGImage.SetSmoothing(const AValue: boolean);
begin
  if FSmoothing <> AValue then
    FSmoothing := AValue;
end;

// Capabilities


class function TGLJPEGImage.Capabilities: TGLDataFileCapabilities;
begin
  Result := [dfcRead {, dfcWrite}];
end;

initialization

  { Register this Fileformat-Handler with GLScene }
  RegisterRasterFormat('jpg', 'Joint Photographic Experts Group Image',
    TGLJPEGImage);
  RegisterRasterFormat('jpeg', 'Joint Photographic Experts Group Image',
    TGLJPEGImage);
  RegisterRasterFormat('jpe', 'Joint Photographic Experts Group Image',
    TGLJPEGImage);
end.

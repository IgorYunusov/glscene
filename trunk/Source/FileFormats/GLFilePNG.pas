//
// This unit is part of the GLScene Project, http://glscene.org
//
{
  PNG files loading implementation
  History :
         06/09/16 - PW - Replaced GLSPNG with VCL.Imaging.pngimage unit
         23/08/10 - Yar - Replaced OpenGL1x to OpenGLTokens
         31/05/10 - Yar - Fixes for Linux x64
         08/05/10 - Yar - Removed check for residency in AssignFromTexture
         22/04/10 - Yar - Fixes after GLState revision
         16/03/10 - Yar - Improved FPC compatibility
         05/03/10 - Yar - Creation

}
unit GLFilePNG;

interface

{$I GLScene.inc}

uses
  System.Classes,
  System.SysUtils,
  VCL.Imaging.pngimage,
  GLStrings,
  GLCrossPlatform,
  OpenGLTokens,
  GLContext,
  GLGraphics,
  GLTextureFormat,
  GLApplicationFileIO;

type

  TGLPNGImage = class(TGLBaseImage)
  private
  public
    class function Capabilities: TGLDataFileCapabilities; override;

    procedure LoadFromFile(const filename: string); override;
    procedure SaveToFile(const filename: string); override;
    procedure LoadFromStream(stream: TStream); override;
    procedure SaveToStream(stream: TStream); override;

    {Assigns from any Texture.}
    procedure AssignFromTexture(textureContext: TGLContext;
      const textureHandle: TGLuint;
      textureTarget: TGLTextureTarget;
      const CurrentFormat: Boolean;
      const intFormat: TGLInternalFormat); reintroduce;
  end;

implementation

// ------------------
// ------------------ TGLPNGImage ------------------
// ------------------

// LoadFromFile
//

procedure TGLPNGImage.LoadFromFile(const filename: string);
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
//

procedure TGLPNGImage.SaveToFile(const filename: string);
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
//

procedure TGLPNGImage.LoadFromStream(stream: TStream);
begin
  LoadFromStream(stream);
end;

// SaveToStream
//

procedure TGLPNGImage.SaveToStream(stream: TStream);
begin
  SaveToStream(stream);
end;

// AssignFromTexture
//

procedure TGLPNGImage.AssignFromTexture(textureContext: TGLContext;
  const textureHandle: TGLuint;
  textureTarget: TGLTextureTarget;
  const CurrentFormat: Boolean;
  const intFormat: TGLInternalFormat);
var
  oldContext: TGLContext;
  contextActivate: Boolean;
  texFormat: Cardinal;
  residentFormat: TGLInternalFormat;
  glTarget: TGLEnum;
begin
  if not ((textureTarget = ttTexture2D)
    or (textureTarget = ttTextureRect)) then
    Exit;

  oldContext := CurrentGLContext;
  contextActivate := (oldContext <> textureContext);
  if contextActivate then
  begin
    if Assigned(oldContext) then
      oldContext.Deactivate;
    textureContext.Activate;
  end;
  glTarget := DecodeGLTextureTarget(textureTarget);

  try
    textureContext.GLStates.TextureBinding[0, textureTarget] := textureHandle;
    fLevelCount := 0;
    fCubeMap := false;
    fTextureArray := false;
    // Check level existence
    GL.GetTexLevelParameteriv(glTarget, 0, GL_TEXTURE_INTERNAL_FORMAT,
      @texFormat);
    if texFormat > 1 then
    begin
      GL.GetTexLevelParameteriv(glTarget, 0, GL_TEXTURE_WIDTH, @FLOD[0].Width);
      GL.GetTexLevelParameteriv(glTarget, 0, GL_TEXTURE_HEIGHT, @FLOD[0].Height);
      FLOD[0].Depth := 0;
      residentFormat := OpenGLFormatToInternalFormat(texFormat);
      if CurrentFormat then
        fInternalFormat := residentFormat
      else
        fInternalFormat := intFormat;
      FindCompatibleDataFormat(fInternalFormat, fColorFormat, fDataType);
      Inc(fLevelCount);
    end;
    if fLevelCount > 0 then
    begin
      fElementSize := GetTextureElementSize(fColorFormat, fDataType);
      ReallocMem(FData, DataSize);
      GL.GetTexImage(glTarget, 0, fColorFormat, fDataType, fData);
    end
    else
      fLevelCount := 1;
    GL.CheckError;
  finally
    if contextActivate then
    begin
      textureContext.Deactivate;
      if Assigned(oldContext) then
        oldContext.Activate;
    end;
  end;
end;

// Capabilities
//

class function TGLPNGImage.Capabilities: TGLDataFileCapabilities;
begin
  Result := [dfcRead, dfcWrite];
end;

initialization
  { Register this Fileformat-Handler with GLScene }
  RegisterRasterFormat('png', 'Portable Network Graphic', TGLPNGImage);

end.

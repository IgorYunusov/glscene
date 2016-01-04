//
// This unit is part of the DGLEngine Project, http://glscene.org
//
{ @HTML ( DGLFileO3TC<p>
      oZone3D Texture Compression file support<p>

 <b>History : </b><font size=-1><ul>
        <li>28/12/15 - JD - Imported from GLScene
   </ul><font>
}
unit DGLFileO3TC;

interface

{$I DGLEngine.inc}

uses
  System.Classes,
  System.SysUtils,
  //GLS
  DGLCrossPlatform,
  DGLTypes,
  dglOpenGL,
  DGLContext,
  DGLGraphics,
  DGLTextureFormat,
  DGLApplicationFileIO;

type

  TDGLO3TCImage = class(TDGLBaseImage)
  public
    class function Capabilities: TDGLDataFileCapabilities; override;

    procedure LoadFromFile(const filename: string); override;
    procedure SaveToFile(const filename: string); override;
    procedure LoadFromStream(stream: TStream); override;
    procedure SaveToStream(stream: TStream); override;

    procedure AssignFromTexture(textureContext: TDGLContext;
      const textureHandle: TGLuint;
      textureTarget: TDGLTextureTarget;
      const CurrentFormat: Boolean;
      const intFormat: TDGLInternalFormat); reintroduce;
  end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

uses
  DGLVectorMaths;

const
  O3_TC_RGB_S3TC_DXT1 = 1;
  O3_TC_RGBA_S3TC_DXT5 = 4;
  O3_TC_ATI3DC_ATI2N = 16;

const
  O3_TC_CUBE_MAP = $0001;
  O3_TC_ARRAY = $0002;

type

  TO3TC_Header = record
    Useless: Cardinal;
    Magic: Cardinal; // Magic number: Must be O3TC.
    Size: Cardinal; // Must be filled with sizeof(TO3TC_Header).
    Version: Cardinal; // Version.
  end;

  TO3TC_ChunkHeader = record
    // Must be filled with sizeof(TO3TC_Chunk_Header):
    ChunkHeaderSize: Cardinal;
    // Reserved in JeGX's version 1.0
    Extension: Cardinal;
    // The size of the data chunk that follows this one.
    Size: Cardinal;
    // Reserved
    reserved2: Cardinal;
    // Pixel format:
    // - O3_TC_RGB_S3TC_DXT1 = 1
    // - O3_TC_RGBA_S3TC_DXT5 = 4
    // - O3_TC_ATI3DC_ATI2N = 16
    InternalPixelFormat: Cardinal;
    // Texture width.
    Width: Cardinal;
    // Texture height.
    Height: Cardinal;
    // Texture depth.
    Depth: Cardinal;
    // Number of mipmaps.
    NumMipmaps: Cardinal;
    // The texture name (optional).
    TextureName: array[0..127] of AnsiChar;
    // The texture id (optional).
    TextureId: Cardinal;
  end;

// ------------------
// { TDGLO3TCImage }
{$IFDEF GLS_REGIONS}{$REGION 'TDGLO3TCImage'}{$ENDIF}

procedure TDGLO3TCImage.LoadFromFile(const filename: string);
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
    raise EInvalidRasterFile.CreateFmt('File %s not found.', [filename]);
end;

procedure TDGLO3TCImage.SaveToFile(const filename: string);
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

procedure TDGLO3TCImage.LoadFromStream(stream: TStream);
type
  TFOURCC = array[0..3] of AnsiChar;
var
  Header: TO3TC_Header;
  ChunkHeader: TO3TC_ChunkHeader;
begin
  // Get the O3TC_Header.
  stream.Read(Header, Sizeof(TO3TC_Header));
  // Check for O3TC magic number...
  if TFOURCC(Header.Magic) <> 'O3TC' then
    raise EInvalidRasterFile.Create('Invalid O3TC file.');
  // Get the O3TC_Chunk_Header
  stream.Read(ChunkHeader, Sizeof(TO3TC_ChunkHeader));

  FLOD[0].Width := ChunkHeader.Width;
  FLOD[0].Height := ChunkHeader.Height;
  FLOD[0].Depth := ChunkHeader.Depth;
  // Get the number of mipmaps
  if ChunkHeader.NumMipmaps <> 0 then
    fLevelCount := MaxInteger(ChunkHeader.NumMipmaps, 1)
  else
    fLevelCount := 1;

  if Header.Version > 1 then
  begin
    fCubeMap := (ChunkHeader.Extension and O3_TC_CUBE_MAP) <> 0;
    fTextureArray := (ChunkHeader.Extension and O3_TC_ARRAY) <> 0;
  end
  else
  begin
    fCubeMap := false;
    fTextureArray := false;
  end;

  // Set format properties
  case ChunkHeader.InternalPixelFormat of
    O3_TC_RGB_S3TC_DXT1:
      begin
        fColorFormat := GL_COMPRESSED_RGB_S3TC_DXT1_EXT;
        fInternalFormat := tfCOMPRESSED_RGB_S3TC_DXT1;
        fDataType := GL_COMPRESSED_RGB_S3TC_DXT1_EXT;
        fElementSize := 8;
      end;
    O3_TC_RGBA_S3TC_DXT5:
      begin
        fColorFormat := GL_COMPRESSED_RGBA_S3TC_DXT5_EXT;
        fInternalFormat := tfCOMPRESSED_RGBA_S3TC_DXT5;
        fDataType := GL_COMPRESSED_RGBA_S3TC_DXT5_EXT;
        fElementSize := 16;
      end;
//    O3_TC_ATI3DC_ATI2N:
//      begin
//        fColorFormat := GL_COMPRESSED_LUMINANCE_ALPHA_3DC_ATI;
//        fInternalFormat := tfCOMPRESSED_LUMINANCE_ALPHA_3DC;
//        fDataType := GL_COMPRESSED_LUMINANCE_ALPHA_3DC_ATI;
//        fElementSize := 16;
//      end;
  else
    raise EInvalidRasterFile.Create('Unsupported O3TC format.')
  end;

  if ChunkHeader.Size <> DataSize then
    EInvalidRasterFile.Create('O3TC erroneous image data size.');

  ReallocMem(fData, ChunkHeader.Size);
  // Read raw data
  stream.Read(fData^, ChunkHeader.Size);
end;

procedure TDGLO3TCImage.SaveToStream(stream: TStream);
const
  Magic: array[0..3] of AnsiChar = 'O3TC';
var
  Header: TO3TC_Header;
  ChunkHeader: TO3TC_ChunkHeader;
begin
  if not ((fColorFormat = GL_COMPRESSED_RGB_S3TC_DXT1_EXT)
    or (fColorFormat = GL_COMPRESSED_RGBA_S3TC_DXT5_EXT)) then raise
//or (fColorFormat = GL_COMPRESSED_LUMINANCE_ALPHA_3DC_ATI))
      EInvalidRasterFile.Create('These image format do not match the O3TC format specification.');
  // Setup Header
  Header.Magic := Cardinal(Magic);
  Header.Size := SizeOf(TO3TC_Header) - SizeOf(Cardinal);
  ChunkHeader.Extension := 0;
  if not (fCubeMap or fTextureArray) then
  begin
    Header.Version := 1;
  end
  else
  begin
    Header.Version := 2;
    if fCubeMap then
      ChunkHeader.Extension := ChunkHeader.Extension or O3_TC_CUBE_MAP;
    if fTextureArray then
      ChunkHeader.Extension := ChunkHeader.Extension or O3_TC_ARRAY;
  end;
  ChunkHeader.ChunkHeaderSize := SizeOf(TO3TC_ChunkHeader);
  ChunkHeader.Width := GetWidth;
  ChunkHeader.Height := GetHeight;
  ChunkHeader.Depth := GetDepth;
  ChunkHeader.NumMipmaps := fLevelCount;
  ChunkHeader.reserved2 := 1;
  FillChar(ChunkHeader.TextureName, 128, 0);
  ChunkHeader.TextureId := 0;
  case fColorFormat of
    GL_COMPRESSED_RGB_S3TC_DXT1_EXT: ChunkHeader.InternalPixelFormat := O3_TC_RGB_S3TC_DXT1;
    GL_COMPRESSED_RGBA_S3TC_DXT5_EXT: ChunkHeader.InternalPixelFormat := O3_TC_RGBA_S3TC_DXT5;
//    GL_COMPRESSED_LUMINANCE_ALPHA_3DC_ATI: ChunkHeader.InternalPixelFormat := O3_TC_ATI3DC_ATI2N;
  end;
  ChunkHeader.Size := DataSize;
  stream.Write(Header, Sizeof(TO3TC_Header));
  stream.Write(ChunkHeader, Sizeof(TO3TC_ChunkHeader));
  stream.Write(fData[0], ChunkHeader.Size);
end;

procedure TDGLO3TCImage.AssignFromTexture(textureContext: TDGLContext;
  const textureHandle: TGLuint;
  textureTarget: TDGLTextureTarget;
  const CurrentFormat: Boolean;
  const intFormat: TDGLInternalFormat);
var
  oldContext: TDGLContext;
  contextActivate: Boolean;
  texFormat, texLod, optLod: Cardinal;
  level, faceCount, face: Integer;
  residentFormat: TDGLInternalFormat;
  bCompressed: Boolean;
  vtcBuffer, top, bottom: PByte;
  i, j, k: Integer;
  cw, ch: Integer;
  glTarget: TGLEnum;

  function blockOffset(x, y, z: Integer): Integer;
  begin
    if z >= (FLOD[level].Depth and -4) then
      Result := fElementSize * (cw * ch * (FLOD[level].Depth and -4) + x +
        cw * (y + ch * (z - 4 * ch)))
    else
      Result := fElementSize * (4 * (x + cw * (y + ch * floor(z / 4))) + (z and
        3));
    if Result < 0 then
      Result := 0;
  end;

begin
  oldContext := CurrentDGLContext;
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
    glGetTexParameteriv(glTarget, GL_TEXTURE_MAX_LEVEL, @texLod);
    if glTarget = GL_TEXTURE_CUBE_MAP then
    begin
      fCubeMap := true;
      faceCount := 6;
      glTarget := GL_TEXTURE_CUBE_MAP_POSITIVE_X;
    end
    else
    begin
      fCubeMap := false;
      faceCount := 1;
    end;
    fTextureArray := (glTarget = GL_TEXTURE_1D_ARRAY)
      or (glTarget = GL_TEXTURE_2D_ARRAY)
      or (glTarget = GL_TEXTURE_CUBE_MAP_ARRAY);

    repeat
      // Check level existence
      glGetTexLevelParameteriv(glTarget, fLevelCount, GL_TEXTURE_INTERNAL_FORMAT,@texFormat);
      if texFormat = 1 then
        Break;
      Inc(fLevelCount);
      if fLevelCount = 1 then
      begin
        glGetTexLevelParameteriv(glTarget, 0, GL_TEXTURE_WIDTH, @FLOD[0].Width);
        glGetTexLevelParameteriv(glTarget, 0, GL_TEXTURE_HEIGHT, @FLOD[0].Height);
        FLOD[0].Depth := 0;
        if (glTarget = GL_TEXTURE_3D)
          or (glTarget = GL_TEXTURE_2D_ARRAY)
          or (glTarget = GL_TEXTURE_CUBE_MAP_ARRAY) then
          glGetTexLevelParameteriv(glTarget, 0, GL_TEXTURE_DEPTH, @FLOD[0].Depth);
        residentFormat := OpenGLFormatToInternalFormat(texFormat);
        if CurrentFormat then
          fInternalFormat := residentFormat
        else
          fInternalFormat := intFormat;
        FindCompatibleDataFormat(fInternalFormat, fColorFormat, fDataType);
        // Get optimal number or MipMap levels
        optLod := GetImageLodNumber(GetWidth, GetHeight, GetDepth, IsVolume);
        if texLod > optLod then
          texLod := optLod;
        // Check for MipMap posibility
        if ((fInternalFormat >= tfR16F)
          and (fInternalFormat <= tfRGBA32F)) then
          texLod := 1;
      end;
    until fLevelCount = Integer(texLod);

    if fLevelCount > 0 then
    begin
      fElementSize := GetTextureElementSize(fColorFormat, fDataType);
      ReallocMem(FData, DataSize);
      bCompressed := IsCompressed;
      vtcBuffer := nil;

      for face := 0 to faceCount - 1 do
      begin
        if fCubeMap then
          glTarget := face + GL_TEXTURE_CUBE_MAP_POSITIVE_X;
        for level := 0 to fLevelCount - 1 do
        begin
          if bCompressed then
          begin

            if dglCheckExtension('NV_texture_compression_vtc') and IsVolume then
            begin
              if level = 0 then
                GetMem(vtcBuffer, GetLevelSizeInByte(0));
              glGetCompressedTexImage(glTarget, level, vtcBuffer);
              // Shufle blocks from VTC to S3TC
              cw := (FLOD[level].Width + 3) div 4;
              ch := (FLOD[level].Height + 3) div 4;
              top := GetLevelAddress(level);
              for k := 0 to FLOD[level].Depth - 1 do
                for i := 0 to ch - 1 do
                  for j := 0 to cw - 1 do
                  begin
                    bottom := vtcBuffer;
                    Inc(bottom, blockOffset(j, i, k));
                    Move(bottom^, top^, fElementSize);
                    Inc(top, fElementSize);
                  end;
             end
            else
              glGetCompressedTexImage(glTarget, level, GetLevelAddress(level));
          end
          else
            glGetTexImage(glTarget, level, fColorFormat, fDataType, GetLevelAddress(level));
        end; // for level
      end; // for face
      if Assigned(vtcBuffer) then
        FreeMem(vtcBuffer);
      // Check memory corruption
      ReallocMem(FData, DataSize);

      if fLevelCount = 0 then
        fLevelCount := 1;
      CheckOpenGLError;
    end;
  finally
    if contextActivate then
    begin
      textureContext.Deactivate;
      if Assigned(oldContext) then
        oldContext.Activate;
    end;
  end;
end;

class function TDGLO3TCImage.Capabilities: TDGLDataFileCapabilities;
begin
  Result := [dfcRead, dfcWrite];
end;

{$IFDEF GLS_REGIONS}{$ENDREGION}{$ENDIF}

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
  { Register this Fileformat-Handler with GLScene }
  RegisterRasterFormat('o3tc', 'oZone3D Texture Compression', TDGLO3TCImage);

end.

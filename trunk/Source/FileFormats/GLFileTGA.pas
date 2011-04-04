//
// This unit is part of the GLScene Project, http://glscene.org
//
{: GLFileTGA<p>

   Graphic engine friendly loading of TGA image.

 <b>History : </b><font size=-1><ul>
        <li>04/04/11 - Yar - Creation
   </ul><p>
}

unit GLFileTGA;

interface

{.$I GLScene.inc}

uses
  Classes,
  SysUtils,
  GLCrossPlatform,
  OpenGLTokens,
  GLContext,
  GLGraphics,
  GLTextureFormat,
  ApplicationFileIO;

type

  // TGLTGAImage
  //

  TGLTGAImage = class(TGLBaseImage)
  public
    { Public Declarations }
    procedure LoadFromFile(const filename: string); override;
    procedure SaveToFile(const filename: string); override;
    procedure LoadFromStream(stream: TStream); override;
    procedure SaveToStream(stream: TStream); override;
    class function Capabilities: TDataFileCapabilities; override;

    procedure AssignFromTexture(textureContext: TGLContext;
      const textureHandle: TGLuint;
      textureTarget: TGLTextureTarget;
      const CurrentFormat: boolean;
      const intFormat: TGLInternalFormat); reintroduce;

    property Data;
    property Width;
    property Height;
    property Depth;
    property ColorFormat;
    property InternalFormat;
    property DataType;
    property ElementSize;
    property CubeMap;
    property TextureArray;
  end;

implementation

type

  // TTGAHeader
  //

  TTGAFileHeader = packed record
    IDLength: Byte;
    ColorMapType: Byte;
    ImageType: Byte;
    ColorMapOrigin: Word;
    ColorMapLength: Word;
    ColorMapEntrySize: Byte;
    XOrigin: Word;
    YOrigin: Word;
    Width: Word;
    Height: Word;
    PixelSize: Byte;
    ImageDescriptor: Byte;
  end;

  // ReadAndUnPackRLETGA24
  //

procedure ReadAndUnPackRLETGA24(stream: TStream; destBuf: PAnsiChar;
  totalSize: Integer);
type
  TRGB24 = packed record
    r, g, b: Byte;
  end;
  PRGB24 = ^TRGB24;
var
  n: Integer;
  color: TRGB24;
  bufEnd: PAnsiChar;
  b: Byte;
begin
  bufEnd := @destBuf[totalSize];
  while destBuf < bufEnd do
  begin
    stream.Read(b, 1);
    if b >= 128 then
    begin
      // repetition packet
      stream.Read(color, 3);
      b := (b and 127) + 1;
      while b > 0 do
      begin
        PRGB24(destBuf)^ := color;
        Inc(destBuf, 3);
        Dec(b);
      end;
    end
    else
    begin
      n := ((b and 127) + 1) * 3;
      stream.Read(destBuf^, n);
      Inc(destBuf, n);
    end;
  end;
end;

// ReadAndUnPackRLETGA32
//

procedure ReadAndUnPackRLETGA32(stream: TStream; destBuf: PAnsiChar;
  totalSize: Integer);
type
  TRGB32 = packed record
    r, g, b, a: Byte;
  end;
  PRGB32 = ^TRGB32;
var
  n: Integer;
  color: TRGB32;
  bufEnd: PAnsiChar;
  b: Byte;
begin
  bufEnd := @destBuf[totalSize];
  while destBuf < bufEnd do
  begin
    stream.Read(b, 1);
    if b >= 128 then
    begin
      // repetition packet
      stream.Read(color, 4);
      b := (b and 127) + 1;
      while b > 0 do
      begin
        PRGB32(destBuf)^ := color;
        Inc(destBuf, 4);
        Dec(b);
      end;
    end
    else
    begin
      n := ((b and 127) + 1) * 4;
      stream.Read(destBuf^, n);
      Inc(destBuf, n);
    end;
  end;
end;

// LoadFromFile
//

procedure TGLTGAImage.LoadFromFile(const filename: string);
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

procedure TGLTGAImage.SaveToFile(const filename: string);
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

procedure TGLTGAImage.LoadFromStream(stream: TStream);
var
  LHeader: TTGAFileHeader;
  y, rowSize, bufSize: Integer;
  verticalFlip: Boolean;
  unpackBuf: PAnsiChar;
  Ptr: PByte;
begin
  stream.Read(LHeader, Sizeof(TTGAFileHeader));

  if LHeader.ColorMapType <> 0 then
    raise EInvalidRasterFile.Create('ColorMapped TGA unsupported');

  FWidth := LHeader.Width;
  FHeight := LHeader.Height;
  FDepth := 0;

  case LHeader.PixelSize of
    24:
      begin
        FColorFormat := GL_BGR;
        FInternalFormat := tfRGB8;
        FElementSize := 3;
      end;
    32:
      begin
        FColorFormat := GL_RGBA;
        FInternalFormat := tfRGBA8;
        FElementSize := 4;
      end;
  else
    raise EInvalidRasterFile.Create('Unsupported TGA ImageType');
  end;

  FDataType := GL_UNSIGNED_BYTE;
  FMipLevels := 1;
  FCubeMap := False;
  FTextureArray := False;
  ReallocMem(FData, DataSize);
  FLevels.Clear;

  rowSize := Width * FElementSize;
  verticalFlip := ((LHeader.ImageDescriptor and $20) <> 1);

  if LHeader.IDLength > 0 then
    stream.Seek(LHeader.IDLength, soFromCurrent);

  case LHeader.ImageType of
    2:
      begin // uncompressed RGB/RGBA
        if verticalFlip then
        begin
          Ptr := PByte(FData);
          Inc(Ptr, rowSize * (FHeight - 1));
          for y := 0 to Height - 1 do
          begin
            stream.Read(Ptr^, rowSize);
            Dec(Ptr, rowSize);
          end;
        end
        else
          stream.Read(FData^, rowSize * FHeight);
      end;
    10:
      begin // RLE encoded RGB/RGBA
        bufSize := Height * rowSize;
        GetMem(unpackBuf, bufSize);
        try
          // read & unpack everything
          if LHeader.PixelSize = 24 then
            ReadAndUnPackRLETGA24(stream, unpackBuf, bufSize)
          else
            ReadAndUnPackRLETGA32(stream, unpackBuf, bufSize);
          // fillup bitmap
          if verticalFlip then
          begin
            Ptr := PByte(FData);
            Inc(Ptr, rowSize * (FHeight - 1));
            for y := 0 to Height - 1 do
            begin
              Move(unPackBuf[y * rowSize], Ptr^, rowSize);
              Dec(Ptr, rowSize);
            end;
          end
          else
            Move(unPackBuf[rowSize * FHeight], FData^, rowSize * FHeight);
        finally
          FreeMem(unpackBuf);
        end;
      end;
  else
    raise EInvalidRasterFile.CreateFmt('Unsupported TGA ImageType %d',
      [LHeader.ImageType]);
  end;
end;

// SaveToStream
//

procedure TGLTGAImage.SaveToStream(stream: TStream);
begin
{$MESSAGE Hint 'TGLTGAImage.SaveToStream not yet implemented' }
end;

// AssignFromTexture
//

procedure TGLTGAImage.AssignFromTexture(textureContext: TGLContext;
  const textureHandle: TGLuint; textureTarget: TGLTextureTarget;
  const CurrentFormat: boolean; const intFormat: TGLInternalFormat);
begin
{$MESSAGE Hint 'TGLTGAImage.AssignFromTexture not yet implemented' }
end;

class function TGLTGAImage.Capabilities: TDataFileCapabilities;
begin
  Result := [dfcRead {, dfcWrite}];
end;

initialization

  { Register this Fileformat-Handler with GLScene }
  RegisterRasterFormat('tga', 'TARGA Image File', TGLTGAImage);

end.


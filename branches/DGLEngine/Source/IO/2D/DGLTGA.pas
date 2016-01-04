//
// This unit is part of the DGLEngine Project, http://glscene.org
//
{ @HTML ( TGA<p>

   Simple TGA formats supports for Delphi.<br>
   Currently supports only 24 and 32 bits RGB formats (uncompressed
   and RLE compressed).<p>

   Based on David McDuffee's document from www.wotsit.org<p>

	<b>History : </b><font size=-1><ul>
	   <li>21/11/02 - JD - imported from GLScene
	</ul></font>
}
unit DGLTGA;

interface

{$i DGLEngine.inc}

uses
  Classes, SysUtils,
  DGLCrossPlatform;

type

	// TTGAImage
	//
   { @HTML ( TGA image load/save capable class for Delphi.<p>
      TGA formats supported : 24 and 32 bits uncompressed or RLE compressed,
      saves only to uncompressed TGA. }
        TTGAImage = class (TDGLBitmap)
	   private
	      { Private Declarations }

	   protected
	      { Protected Declarations }

	   public
	      { Public Declarations }
	      constructor Create; override;
         destructor Destroy; override;

         procedure LoadFromStream(stream : TStream); override;
         procedure SaveToStream(stream : TStream); override;
	end;

   // ETGAException
   //
   ETGAException = class (Exception)
   end;


// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

uses
  DGLGraphics;

type

   // TTGAHeader
   //
   TTGAHeader = packed record
      IDLength          : Byte;
      ColorMapType      : Byte;
      ImageType         : Byte;
      ColorMapOrigin    : Word;
      ColorMapLength    : Word;
      ColorMapEntrySize : Byte;
      XOrigin           : Word;
      YOrigin           : Word;
      Width             : Word;
      Height            : Word;
      PixelSize         : Byte;
      ImageDescriptor   : Byte;
  end;

// ------------------
{ Helpers Functions }
{$IFDEF GLS_REGION}{$REGION 'Helpers Functions'}{$ENDIF}

procedure ReadAndUnPackRLETGA24(stream : TStream; destBuf : PAnsiChar; totalSize : Integer);
type
   TRGB24 = packed record
      r, g, b : Byte;
   end;
   PRGB24 = ^TRGB24;
var
   n : Integer;
   color : TRGB24;
   bufEnd : PAnsiChar;
   b : Byte;
begin
   bufEnd:=@destBuf[totalSize];
   while destBuf<bufEnd do
   begin
      stream.Read(b, 1);
      if b>=128 then
      begin
         // repetition packet
         stream.Read(color, 3);
         b:=(b and 127)+1;
         while b>0 do
         begin
            PRGB24(destBuf)^:=color;
            Inc(destBuf, 3);
            Dec(b);
         end;
      end else
      begin
         n:=((b and 127)+1)*3;
         stream.Read(destBuf^, n);
         Inc(destBuf, n);
      end;
   end;
end;


procedure ReadAndUnPackRLETGA32(stream : TStream; destBuf : PAnsiChar; totalSize : Integer);
type
   TRGB32 = packed record
      r, g, b, a : Byte;
   end;
   PRGB32 = ^TRGB32;
var
   n : Integer;
   color : TRGB32;
   bufEnd : PAnsiChar;
   b : Byte;
begin
   bufEnd:=@destBuf[totalSize];
   while destBuf<bufEnd do
   begin
      stream.Read(b, 1);
      if b>=128 then
      begin
         // repetition packet
         stream.Read(color, 4);
         b:=(b and 127)+1;
         while b>0 do
         begin
            PRGB32(destBuf)^:=color;
            Inc(destBuf, 4);
            Dec(b);
         end;
      end else
      begin
         n:=((b and 127)+1)*4;
         stream.Read(destBuf^, n);
         Inc(destBuf, n);
      end;
   end;
end;

{$IFDEF GLS_REGIONS}{$ENDREGION}{$ENDIF}

// ------------------
{ TTGAImage }
{$IFDEF GLS_REGION}{$REGION 'TTGAImage'}{$ENDIF}

constructor TTGAImage.Create;
begin
	inherited Create;
end;

destructor TTGAImage.Destroy;
begin
	inherited Destroy;
end;

procedure TTGAImage.LoadFromStream(stream : TStream);
var
   header : TTGAHeader;
   y, rowSize, bufSize : Integer;
   verticalFlip : Boolean;
   unpackBuf : PAnsiChar;

   function GetLineAddress(ALine: Integer): PByte;
   begin
     Result := PByte(ScanLine[ALine]);
   end;

begin
   stream.Read(header, Sizeof(TTGAHeader));

   if header.ColorMapType<>0 then
      raise ETGAException.Create('ColorMapped TGA unsupported');

   case header.PixelSize of
      24 : PixelFormat:=glpf24bit;
      32 : PixelFormat:=glpf32bit;
   else
      raise ETGAException.Create('Unsupported TGA ImageType');
   end;

   Width:=header.Width;
   Height:=header.Height;
   rowSize:=(Width*header.PixelSize) div 8;
   verticalFlip:=((header.ImageDescriptor and $20)=0);
   if header.IDLength>0 then
      stream.Seek(header.IDLength, soFromCurrent);
   try
     case header.ImageType of
        0 :
        begin // empty image, support is useless but easy ;)
           Width:=0;
           Height:=0;
           Abort;
        end;
        2 :
        begin // uncompressed RGB/RGBA
           if verticalFlip then
           begin
              for y:=0 to Height-1 do
                 stream.Read(GetLineAddress(Height-y-1)^, rowSize);
           end else
           begin
              for y:=0 to Height-1 do
                 stream.Read(GetLineAddress(y)^, rowSize);
           end;
        end;
        10 :
        begin // RLE encoded RGB/RGBA
           bufSize:=Height*rowSize;
           unpackBuf:=GetMemory(bufSize);
           try
              // read & unpack everything
              if header.PixelSize=24 then
                 ReadAndUnPackRLETGA24(stream, unpackBuf, bufSize)
              else ReadAndUnPackRLETGA32(stream, unpackBuf, bufSize);
              // fillup bitmap
              if verticalFlip then
              begin
                 for y:=0 to Height-1 do
                 begin
                    Move(unPackBuf[y*rowSize], GetLineAddress(Height-y-1)^, rowSize);
                 end;
              end else
              begin
                 for y:=0 to Height-1 do
                    Move(unPackBuf[y*rowSize], GetLineAddress(y)^, rowSize);
              end;
           finally
              FreeMemory(unpackBuf);
           end;
        end;
     else
        raise ETGAException.Create('Unsupported TGA ImageType '+IntToStr(header.ImageType));
     end;
   finally
     //
   end;
end;


procedure TTGAImage.SaveToStream(stream : TStream);
var
   y, rowSize : Integer;
   header : TTGAHeader;
begin
   // prepare the header, essentially made up from zeroes
   FillChar(header, SizeOf(TTGAHeader), 0);
   header.ImageType:=2;
   header.Width:=Width;
   header.Height:=Height;
   case PixelFormat of
      glpf24bit : header.PixelSize:=24;
      glpf32bit : header.PixelSize:=32;
   else
      raise ETGAException.Create('Unsupported Bitmap format');
   end;

   stream.Write(header, SizeOf(TTGAHeader));

   rowSize:=(Width*header.PixelSize) div 8;
   for y:=0 to Height-1 do
      stream.Write(ScanLine[Height-y-1]^, rowSize);
end;

{$IFDEF GLS_REGIONS}{$ENDREGION}{$ENDIF}

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization

   TDGLPicture.RegisterFileFormat('tga', 'Targa', TTGAImage);

finalization

   TDGLPicture.UnregisterGraphicClass(TTGAImage);
end.

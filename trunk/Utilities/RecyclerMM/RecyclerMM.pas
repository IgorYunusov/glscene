// RecyclerMM
{: Egg<p>

	Recycling Memory Manager (aka RMM).<p>
   Provides high-speed allocation/release of highly-aligned memory
   via a segregated storage algorithm (for small and medium blocks)
   and a virtual heap (large blocks).<br>
   Supports Shared Memory (like ShareMem, but no DLL required).<p>

   Copyright 2003 - Creative IT / Eric Grange<br>
   Default licensing is GPL, use under MPL can be granted (on request, for free)
   for users/companies "supporting" Open Source (purely subjective decision by us)<p>

   Implementation Notes:<ul>
      <li>To use this unit ideally place the unit as first unit in your project's
         'uses' clause (this is a requirement is DEFER_INVALIDATE_POINTERS isn't set).
      <li>Shared Memory support is implemented through the creation of a Local
         Atom and a (never visible) window, which allow main EXE/DLLs modules
         to be aware of each other's RecyclerMM support and thus, reuse a single
         manager instance (which may be one from the main exe, or the one of
         the statically linked DLLs, depending on initialization order).
      <li>Small blocks chunks and batches are allocated at the top of the address
         space, large blocks at the bottom.
      <li>The Borland MM is currently used internally by the RMM for its own
         needs, it is strongly recommended (for efficiency reasons) to let RMM
         be its sole user.
   </ul><p>

	<b>History : </b><font size=-1><ul>
      <li>29/01/04 - EG - Added RAISE_EXCEPTION_ON_INVALID_RELEASE logic,
                          AllocateLGB now properly lets EOutOfMemory surface 
      <li>07/11/03 - EG - Properly checks allocation of LGB, minor optims
      <li>06/11/03 - EG - Changed batch logic, more defines supported
      <li>03/11/03 - EG - Shared Memory support (like ShareMem, but DLL-free)
      <li>30/10/03 - EG - Implemented SSE transfer/clear
	   <li>28/10/03 - EG - Creation
	</ul></font>
}
unit RecyclerMM;

interface

{$OPTIMIZATION ON}
{$STACKFRAMES OFF}
{$WRITEABLECONST OFF}
{$BOOLEVAL OFF}

{$ifdef VER150}   // of course it's "unsafe", so no warnings plz
   {$WARN UNSAFE_CODE OFF}
   {$WARN UNSAFE_TYPE OFF}
{$endif}

uses Windows;

// If set, RecyclerMM will automatically locate and share memory with other
// RecyclerMMs in DLL modules (same functionality as Borland's ShareMem unit).
// Sharing will only happen with compatible RMMs.
// This option is NOT compatible with PATCH_ALLOCMEM
{$define SHARE_MEM}

// If set, the RMM memorymap will not be writeable by the process, which will
// ensure wild pointers can't corrupt it and Allocated() remains accurate.
// Activating it incurs a small performance penalty.
{.$define SECURE_MEMORYMAP}

// if set the (possible) BPLs won't be patched, only the jump table will
{.$define NO_BPL_PATCHING}

// If set SysUtils.AllocMem will be redirected to RAllocMem (*much* faster)
// however, note that this activates DEFER_INVALIDATE_POINTERS (see below)
// to avoid crashes resulting from alteration of SysUtils variables.
// This option is NOT compatible with SHARE_MEM
{.$define PATCH_ALLOCMEM}

// if set SSE code for Move16/Clear16 will be allowed
{$define ALLOW_SSE}

// if set the RecyclerMM will automatically bind itself as default memory manager
{$define AUTO_BIND}

// if set and exception will be explicitly raised if your code attempts
// to release a block that isn't allocated. By default, RMM only detects
// that issue reliably for large blocks and signals the issue to the Borland RTL,
// which may then raise an exception. But in some circumstances, the RTL will
// just ignore the issue. When the option is active, RMM will accurately detect
// this issue all the time, and trigger an exception itself.
// Doing so incurs a performance penalty on block release, and should preferably
// only be used for testing or if memory integrity is of primary importance
{.$define RAISE_EXCEPTION_ON_INVALID_RELEASE}

// if set invalid pointers free/realloc will be defered to SysFreeMem
// This allows a mixed mode where the RecyclerMM can replace the default
// after it has started allocating, but also means the RMM cannot be unbound.
{$define DEFER_INVALIDATE_POINTERS}

// compile options implicit dependency rules

{$ifdef PATCH_ALLOCMEM}
   {$define DEFER_INVALIDATE_POINTERS}
   {$define USES_SYSUTILS}
{$endif}
{$ifdef RAISE_EXCEPTION_ON_INVALID_RELEASE}
   {$define DEFER_INVALIDATE_POINTERS}
   {$define USES_SYSUTILS}
{$endif}

// compile error when incompatible options have been selected

{$ifdef PATCH_ALLOCMEM}
{$ifdef SHARE_MEM}
   Error : you cannot combine PATCH_ALLOCMEM and SHARE_MEM
{$endif}
{$endif}


const
   // Alignment for SMBs
   cSMBAlignmentBits       = 4;
   cSMBAlignment           = 1 shl cSMBAlignmentBits;
   // Size of Small Blocks chunks
   cSMBChunkSize           = 64*1024;
   // Maximum Size (bytes) of "dense" blocks managed by SMBs
   cSMBDenseMaxBits        = 11; // 2kB
   cSMBDenseMaxSize        = 1 shl cSMBDenseMaxBits;
   // Maximum Size (bytes) of "sparse" blocks managed by SMBs (max 64kB)
   cSMBSparseMaxBits       = 15; // 32 kB
   cSMBSparseMaxSize       = 1 shl cSMBSparseMaxBits;
   cSMBSparseBitRange      = cSMBSparseMaxBits-cSMBDenseMaxBits;
   // Maximum Size (bytes) of blocks managed by SMBs (max 64kB)
   cSMBMaxSize             = cSMBSparseMaxSize;
   // Minimal Desired amount of blocks per SMB chunk
   cSMBBlocksPerChunk      = 32;
   // Maximum size of SMB chunks (may limit block count)
   cSMBMaxChunkSize        = 512*1024;
   // Ratio for ReallocDownSizing (4 = downsizing will happen if only 1/4 used)
   cSMBReallocDownSizing   = 4;
   cLGBReallocDownSizing   = 4;

   // Size of chunk allocation batches (max 30)
   cRMMChunkBatchAllocSize = 8;
   // Size of chunk batches
   cRMMChunkBatchSize      = cSMBChunkSize*cRMMChunkBatchAllocSize;
   cRMMChunkBatchFullMask  = (1 shl cRMMChunkBatchAllocSize)-1;

   // Size and Index limits for SMBs
   cSMBRange0End           = cSMBDenseMaxSize shr 3;
   cSMBRange1Offset        = cSMBDenseMaxSize shr (cSMBAlignmentBits+3);
   cSMBRange1End           = cSMBDenseMaxSize shr 2;
   cSMBRange2Offset        = (cSMBDenseMaxSize shr (cSMBAlignmentBits+4))+cSMBRange1Offset;
   cSMBRange2End           = cSMBDenseMaxSize shr 1;
   cSMBRange3Offset        = (cSMBDenseMaxSize shr (cSMBAlignmentBits+4))+cSMBRange2Offset;
   cSMBDenseOffsetEnd      = cSMBRange3Offset + ((cSMBDenseMaxSize-1-cSMBRange2End) shr (cSMBAlignmentBits+3));

   cSMBMaxSizeIndex        = cSMBDenseOffsetEnd+cSMBSparseBitRange;

type

   // TRMMStatus
   //
   TRMMStatus = (rmmsUnallocated, rmmsAllocated, rmmsReserved,
                 rmmsSysAllocated, rmmsSysReserved);

   // TRMMMemoryMap
   //
   {: Describes a 64 kB range of the RMM memory use.<p>
      This structure isn't used by RMM itself, it's used to report the status
      of the memory allocation in RMMUsageSnapShot. }
   TRMMMemoryMap = packed record
      StartAddr : Pointer;          // Start of address range
      Length : Cardinal;            // Length of address range (bytes)
      AllocatedUserSize : Cardinal; // Bytes in range allocated by user
      Status : TRMMStatus;          // Status of address range
   end;
   PRMMMemoryMap = ^TRMMMemoryMap;

   // TRMMSMBStat
   //
   TRMMSMBStat = packed record
      BlockSize : Cardinal;
      AllocatedBlocks : Cardinal;
      AllocatedUserSize : Cardinal;
      TotalVirtualAllocated : Cardinal;
   end;
   PRMMSMBStat = ^TRMMSMBStat;

   // TRMMUsageSnapShot
   //
   {: RMM usage diagnostic snapshot, returned by RMMUsageSnapShot. }
   TRMMUsageSnapShot = packed record
      // RMM Stats
      TotalVirtualAllocated : Cardinal;
      AllocatedBlocks : Cardinal;
      AllocatedUserSize : Cardinal;
      // Virtual Memory Stats
      TotalVMSpace : Cardinal;
      SystemAllocatedVM : Cardinal;
      SystemReservedVM : Cardinal;
      LargestFreeVM : Cardinal;
      // Map
      NbMapItems : Cardinal;
      Map : packed array [0..32767] of TRMMMemoryMap;
      SMBStats : packed array [0..cSMBMaxSizeIndex] of TRMMSMBStat;
   end;
   PRMMUsageSnapShot = ^TRMMUsageSnapShot;

   // TRMMUsageBench
   //
   TRMMUsageBench = record
      TotalTime : Int64;
      NbCalls : Cardinal;
   end;

{: Fast 16 bytes-based move.<p>
   Copies blocks of 16 bytes only, ie. Count is rounded up to the nearest
   multiple of 16. Overlapping source/destination are not handled. }
var Move16 : procedure (const Source; var Dest; Count: Integer); register;
{: Fills an area whose size is a multiple of 16-bytes with zeros.<p>
   Count is rounded up to the nearest multiple of 16 }
var MemClear16 : procedure (const Buffer; Count: Integer); register;

// Direct access functions - only for single .EXE with no RMM DLLs

function RGetMem(Size: Integer): Pointer;
function RAllocMem(Size : Cardinal) : Pointer;
function RFreeMem(P: Pointer): Integer;
function RReallocMem(P: Pointer; Size: Cardinal): Pointer;

{: True if P points to the beginning of an allocated block.<p> }
function Allocated(const P : Pointer) : Boolean;

{: Generates a memory map of RMM memory usage.<p>
   While the map is generated, all RMM activity is freezed. }
function RMMUsageSnapShot : TRMMUsageSnapShot; overload;
procedure RMMUsageSnapShot(var result : TRMMUsageSnapShot); overload;

procedure BindRMM;
procedure UnBindRMM;
function  RMMActive : Boolean;

procedure InitializeRMM;
procedure FinalizeRMM;

function SMBSizeToIndex(s : Integer) : Integer; register;
function SMBIndexToSize(i : Integer) : Integer; register;

var
   // Total Virtual Memory Allocated
   vTotalVirtualAllocated : Cardinal;

resourcestring
   // Unused, this is just to have it in clear in the DCU 
   cRecyclerMMCopyright = 'RecyclerMM - �2003 Creative IT';

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

{$ifdef USES_SYSUTILS}
uses SysUtils;
{$endif}

const
   HEAP_GENERATE_EXCEPTIONS   = $00000004;

   cSMBSignature = (Ord('S')+(Ord('M') shl 8)+(Ord('B') shl 16)) shl 8;
   cLGBSignature = (Ord('L')+(Ord('G') shl 8)+(Ord('B') shl 16)) shl 8;

type
   PPointer = ^Pointer;
   TPointerArray32k = packed array [0..32767] of Pointer;
   PPointerArray32k = ^TPointerArray32k;

   TWordArray = packed array [0..MaxInt shr 2] of Word;
   PWordArray = ^TWordArray;

   // TRedirectPatch
   //
   TRedirectPatch = record
      jumpAddr : Pointer;
      jumpBuffer : array [0..5] of Byte;
      bplAddr : Pointer;
      bplBuffer : array [0..5] of Byte;
   end;

   // TRMMChunkBatch
   //
   {: SMB Chunks batch allocation structure.<p>
      These are used too allocate several 64kB chunks at once. }
   PRMMChunkBatch = ^TRMMChunkBatch;
   TRMMChunkBatch = record
      ChunkAllocated : Integer;     // bitwise meaning
      Next, Prev : PRMMChunkBatch;
      Chunks : array [0..cRMMChunkBatchAllocSize-1] of Pointer;
   end;

   // TSMBManager
   //
   {: Manages a Small Blocks chunk.<p>
      Small blocks manage many user blocks of constant (BlockSize) size,
      which are allocated/freed in a stack-like fashion. }
   PSMBManager = ^TSMBManager;
   TSMBManager = packed record
      Signature : Integer;       // 'SMB'#0
      BlockStart : Pointer;      // 64 kB aligned base address for the chunk
      ChunkSize : Cardinal;      // Size of block
      Next, Prev : PSMBManager;  // pointer to the next/prev managers
      SMBIndex : Cardinal;
      NbFreeBlockOffset : Cardinal;
      MaxFreeBlockOffset : Cardinal;
      ReasonnablyFreeTreshold : Cardinal;
      ReallocDownSizingSize : Cardinal;
      BlockSize : Cardinal;
      InvBlockSize : Single;
      BlockOffsets : PWordArray;
      BlockSizes : PWordArray;
      ChunkBatch : PRMMChunkBatch;
   end;

   // TLGBManager
   //
   {: Manages a Large Block.<p>
      LGBs each manage a single user-allocated block. They are allowed to
      reserve address space (to improve the chances of in-place growth). }
   PLGBManager = ^TLGBManager;
   TLGBManager = record
      Signature : Integer;       // 'LGB'#0
      BlockStart : Pointer;      // 64 kB aligned base address for the block
      BlockSize : Cardinal;      // Total allocated size for the block
      ReallocDownSizingSize : Cardinal;   // Size treshold for downsizing
      DataSize : Cardinal;       // Size requested by the user
      Next, Prev : PLGBManager;
      ChunkBatch : PRMMChunkBatch;
   end;

   // TSharedMemoryManager
   //
   {: Extends TMemoryManager to accomodate RMM functions.<p>
      This structure is what RMMs cross-refer when sharing memory. }
   TSharedMemoryManager = record
      MemoryManager : TMemoryManager;
      AllocMem : function(Size : Cardinal) : Pointer;
      Allocated : function(const P : Pointer) : Boolean;
      RMMUsageSnapShot : function : TRMMUsageSnapShot;
   end;
   PSharedMemoryManager = ^TSharedMemoryManager;

var
   // Only the lower 2 GB are accessible to an application under Win32,
   // that's a maximum of 32768 blocks which are all mapped by a 128 kB array
   {$ifdef SECURE_MEMORYMAP}
   vMemoryMap : PPointerArray32k;
   {$else}
   vMemoryMap : TPointerArray32k;
   {$endif}

   // Binding variables
   vOldMemoryManager : TMemoryManager;
   vAllocatedPatch : TRedirectPatch;
   vRMMUsageSnapShotPatch : TRedirectPatch;
   vRMMBound : Integer;
   {$ifdef PATCH_ALLOCMEM}
   vAllocMemPatch : TRedirectPatch;
   {$endif}
   {$ifdef ALLOW_SSE}
   vSSESupported : Integer;
   {$endif}

   // Shared memory variables
   vSharedMemoryManager : TSharedMemoryManager;
   {$ifdef SHARE_MEM}
   vSharedMemory_Data : HWND;
   vSharedMemory_DataName : ShortString = '########-RecyclerMM-100'#0;
   vSharedMemory_InUse : Boolean;
   {$endif}

   // Pointers to the topmost/last SmallBlocks managers and accompanying CS
   vFirstSMBs : array [0..cSMBMaxSizeIndex] of PSMBManager;
   vLastSMBs : array [0..cSMBMaxSizeIndex] of PSMBManager;
   vSMBLocks : array [0..cSMBMaxSizeIndex] of TRTLCriticalSection;
   // Head of the ChunkBatches chained list
   vRMMChunkBatches : PRMMChunkBatch;
   vRMMBatchesLock : TRTLCriticalSection;
   // Large blocks are chained in a hash table
   vLGBManagers : array [0..255] of PLGBManager;
   vLGBLock : TRTLCriticalSection;

// RaiseRMMException
//
procedure RaiseRMMException(const msg : String);
begin
   // we can't use the Delphi mechanism, because it relies on SysUtils,
   // which we can't have a dependancy to (since SysUtils allocates dynamic memory)
   // msg is ignored right now, and an AV systematically triggered...
   RaiseException(EXCEPTION_ACCESS_VIOLATION,
                  EXCEPTION_NONCONTINUABLE, 0, nil);
end;

// RaiseRMMInvalidPointerException
//
procedure RaiseRMMInvalidPointerException;
begin
   RaiseRMMException('Invalid Pointer');
end;

// UpdateMemoryMap
//
procedure UpdateMemoryMap(baseAddr : Pointer; size : Cardinal; manager : Pointer);
var
   i, n : Cardinal;
   p : PPointerArray32k;
   {$ifdef SECURE_MEMORYMAP}
   oldProtect : Cardinal;
   {$endif}
begin
   p:=@vMemoryMap[Cardinal(baseAddr) shr 16];
   n:=(size shr 16);
   {$ifdef SECURE_MEMORYMAP}
   VirtualProtect(vMemoryMap, SizeOf(TPointerArray32k), PAGE_READWRITE, oldProtect);
   for i:=0 to n-1 do
      p[i]:=manager;
   VirtualProtect(vMemoryMap, SizeOf(TPointerArray32k), PAGE_READONLY, oldProtect);
   {$else}
   for i:=0 to n-1 do
      p[i]:=manager;
   {$endif}
end;

// AllocateRMMChunkBatch
//
function AllocateRMMChunkBatch : PRMMChunkBatch;
var
   i : Integer;
   p : Pointer;
begin
   Result:=SysGetMem(SizeOf(TRMMChunkBatch));
   p:=VirtualAlloc(nil, cRMMChunkBatchSize,
                   MEM_COMMIT+MEM_TOP_DOWN, PAGE_READWRITE);
   if Assigned(p) then begin
      Inc(vTotalVirtualAllocated, cRMMChunkBatchSize);
      for i:=0 to cRMMChunkBatchAllocSize-1 do
         Result.Chunks[i]:=Pointer(Integer(p)+i*cSMBChunkSize);
      Result.ChunkAllocated:=0;
      Result.Next:=nil;
      Result.Prev:=nil;
   end else Result:=nil;
end;

// ReleaseRMMChunkBatch
//
procedure ReleaseRMMChunkBatch(batch : PRMMChunkBatch);
begin
   if batch.ChunkAllocated<>0 then
      RaiseRMMException('SMBChunk release detected incoherency');
   Dec(vTotalVirtualAllocated, cRMMChunkBatchSize);
   VirtualFree(batch.Chunks[0], 0, MEM_RELEASE);
   SysFreeMem(batch);
end;

// AllocateRMMChunk
//
function AllocateRMMChunk(chunkSize : Cardinal; var batch : PRMMChunkBatch) : Pointer;
var
   i, n : Integer;
   iter, next : PRMMChunkBatch;
label
   lblExitOnError;
begin
   if IsMultiThread then
      EnterCriticalSection(vRMMBatchesLock);

   if chunkSize<=(64*1024) then begin
      // this will be 64kB chunk, coming from chunk batches
      // locate a batch with capacity
      iter:=vRMMChunkBatches;
      while iter.ChunkAllocated=cRMMChunkBatchFullMask do begin
         next:=iter.Next;
         if next=nil then begin
            // allocate a new batch
            next:=AllocateRMMChunkBatch;
            if next=nil then begin
               Result:=nil;
               goto lblExitOnError;
            end;
            next.Prev:=iter;
            iter.Next:=next;
            iter:=next;
            Break;
         end else iter:=next;
      end;
      // locate a free chunk in the batch
      i:=1;
      n:=0;
      while n<cRMMChunkBatchAllocSize do begin
         if (iter.ChunkAllocated and i)=0 then begin
            batch:=iter;
            Result:=iter.Chunks[n];
            iter.ChunkAllocated:=iter.ChunkAllocated+i;
            goto lblExitOnError;
         end else begin
            i:=i shl 1;
            Inc(n);
         end;
      end;
      RaiseRMMException('SMBChunk allocation failure');
      Result:=nil;
   end else begin
      // larger chunk, allocated directly from the WinAPI (for the time being)
      batch:=nil;
      Result:=VirtualAlloc(nil, chunkSize,
                           MEM_COMMIT+MEM_TOP_DOWN, PAGE_READWRITE);
      if Result<>nil then
         Inc(vTotalVirtualAllocated, chunkSize);
   end;
lblExitOnError:
   if IsMultiThread then
      LeaveCriticalSection(vRMMBatchesLock);
end;

// ReleaseRMMChunk
//
procedure ReleaseRMMChunk(chunk : Pointer; batch : PRMMChunkBatch; chunkSize : Cardinal);
var
   n : Integer;
begin
   if IsMultiThread then
      EnterCriticalSection(vRMMBatchesLock);

   if batch<>nil then begin
      // locate the batch containing the chunk
      n:=(Integer(chunk)-Integer(batch.Chunks[0])) div cSMBChunkSize;
      batch.ChunkAllocated:=batch.ChunkAllocated-(1 shl n);
      if (batch.ChunkAllocated=0) and (batch.Prev<>nil) then begin
         batch.Prev.Next:=batch.Next;
         if batch.Next<>nil then
            batch.Next.Prev:=batch.Prev;
         ReleaseRMMChunkBatch(batch);
      end;
   end else begin
      Dec(vTotalVirtualAllocated, chunkSize);
      VirtualFree(chunk, 0, MEM_RELEASE);
   end;

   if IsMultiThread then
      LeaveCriticalSection(vRMMBatchesLock);
end;

// AllocateLGB
//
function AllocateLGB(Size : Cardinal) : PLGBManager;
var
   hash : Integer;
   blkSize : Cardinal;
   head : PLGBManager;
begin
   // Spawn manager, allocate block
   Result:=SysGetMem(SizeOf(TLGBManager));
   if Result=nil then Exit;
   Result.Signature:=cLGBSignature;
   blkSize:=(Size and $FFFF0000);
   if (Size and $FFFF)<>0 then
      Inc(blkSize, $10000);
   if blkSize=64*1024 then
      Result.BlockStart:=AllocateRMMChunk(blkSize, Result.ChunkBatch)
   else begin
      Result.BlockStart:=VirtualAlloc(nil, blkSize, MEM_COMMIT, PAGE_READWRITE);
      Result.ChunkBatch:=nil;
   end;
   if Result.BlockStart=nil then begin
      SysFreeMem(Result);
      Result:=nil;
      Exit;
   end;
   Result.BlockSize:=blkSize;
   Result.ReallocDownSizingSize:=blkSize div cLGBReallocDownSizing;
   if Result.ReallocDownSizingSize>cSMBMaxSize then
      Result.ReallocDownSizingSize:=cSMBMaxSize;
   Inc(vTotalVirtualAllocated, blkSize);
   Result.DataSize:=Size;
   // Add in hash table
   hash:=((Cardinal(Result) shr 2) xor (Cardinal(Result) shr 19)) and $FF;
   if IsMultiThread then
      EnterCriticalSection(vLGBLock);

   head:=vLGBManagers[hash];
   if head<>nil then
      head.Prev:=Result;
   Result.Next:=head;
   Result.Prev:=nil;
   vLGBManagers[hash]:=Result;

   if IsMultiThread then
      LeaveCriticalSection(vLGBLock);
      
   UpdateMemoryMap(Result.BlockStart, Result.BlockSize, Result);
end;

// ReleaseLGB
//
procedure ReleaseLGB(manager : PLGBManager);
var
   hash : Integer;
begin
   UpdateMemoryMap(manager.BlockStart, manager.BlockSize, nil);
   // Free block
   Dec(vTotalVirtualAllocated, manager.BlockSize);
   if manager.ChunkBatch=nil then
      VirtualFree(manager.BlockStart, 0, MEM_RELEASE)
   else ReleaseRMMChunk(manager.BlockStart, manager.ChunkBatch, manager.BlockSize);
   // Remove from hash table
   hash:=((Cardinal(manager) shr 2) xor (Cardinal(manager) shr 19)) and $FF;
   if IsMultiThread then
      EnterCriticalSection(vLGBLock);

   if manager.Prev=nil then
      vLGBManagers[hash]:=manager.Next
   else manager.Prev.Next:=manager.Next;
   if manager.Next<>nil then
      manager.Next.Prev:=manager.Prev;

   if IsMultiThread then
      LeaveCriticalSection(vLGBLock);
      
   SysFreeMem(manager);
end;

// SMBIndexToSize
//
function SMBIndexToSize(i : Integer) : Integer; register;
begin
   if i<cSMBRange1Offset then
      Result:=(i+1) shl cSMBAlignmentBits
   else if i<cSMBRange2Offset then
      Result:=cSMBRange0End+((i+1-cSMBRange1Offset) shl (cSMBAlignmentBits+1))
   else if i<cSMBRange3Offset then
      Result:=cSMBRange1End+((i+1-cSMBRange2Offset) shl (cSMBAlignmentBits+2))
   else if i<cSMBDenseOffsetEnd then
      Result:=cSMBRange2End+((i+1-cSMBRange3Offset) shl (cSMBAlignmentBits+3))
   else Result:=1 shl (cSMBDenseMaxBits+(i-cSMBDenseOffsetEnd));
end;

// SMBSizeToIndex
//
function SMBSizeToIndex(s : Integer) : Integer; register;
asm
   //if s<=cSMBRange0End then
   //   Result:=(s-1) shr cSMBAlignmentBits
   cmp   eax, cSMBRange0End
   jnle  @@NotRange0
      dec   eax
      shr   eax, cSMBAlignmentBits
      ret
@@NotRange0:
   //else if s<=cSMBRange1End then
   //   Result:=((s-(1+cSMBRange0End)) shr (cSMBAlignmentBits+1))+cSMBRange1Offset
   cmp   eax, cSMBRange1End
   jnle  @@NotRange1
      add   eax, (cSMBRange1Offset shl (cSMBAlignmentBits+1))-(1+cSMBRange0End)
      shr   eax, cSMBAlignmentBits+1
      ret
@@NotRange1:
   //else if s<=cSMBRange2End then
   //   Result:=((s-(1+cSMBRange1End)) shr (cSMBAlignmentBits+2))+cSMBRange2Offset
   cmp   eax, cSMBRange2End
   jnle  @@NotRange2
      add   eax, (cSMBRange2Offset shl (cSMBAlignmentBits+2))-(1+cSMBRange1End)
      shr   eax, cSMBAlignmentBits+2
      ret
@@NotRange2:
   //else if s<=cSMBDenseMaxSize then begin
   //   Result:=((s-(1+cSMBRange2End)) shr (cSMBAlignmentBits+3))+cSMBRange3Offset
   cmp   eax, cSMBDenseMaxSize
   jnle  @@NotDense
      add   eax, (cSMBRange3Offset shl (cSMBAlignmentBits+3))-(1+cSMBRange2End)
      shr   eax, cSMBAlignmentBits+3
      ret
@@NotDense:
   //k:=1 shl (cSMBDenseMaxBits+1);
   mov   edx, 1 shl (cSMBDenseMaxBits+1);
   //Result:=cSMBDenseOffsetEnd+1;
   mov   ecx, eax
   mov   eax, cSMBDenseOffsetEnd+1
   //while k<s do begin
@@While:
   cmp   edx, ecx
   jge   @@End
   //   k:=k shl 1;
   shl   edx, 1
   //   Inc(Result);
   inc   eax
   //end;
   jmp   @@while
@@End:
end;

// Move16SSE
//
procedure Move16SSE(const Source; var Dest; Count: Integer); register;
asm
   or       ecx, ecx
   jz       @@End

@@Copy:
   // round to 16
   add      ecx, 15
   and      cl, $F0

   lea      eax, [eax+ecx]
   lea      edx, [edx+ecx]

   neg      ecx

   test     ecx, 16
   jz       @@Loop

   db $0F,$6F,$34,$08       /// movq     mm6, [eax+ecx]
   db $0F,$6F,$7C,$08,$08   /// movq     mm7, [eax+ecx+8]
   db $0F,$E7,$34,$0A       /// movntq   [edx+ecx], mm6
   db $0F,$E7,$7C,$0A,$08   /// movntq   [edx+ecx+8], mm7
   add      ecx, 16
   jz       @@End

@@Loop:
   db $0F,$6F,$04,$08       /// movq     mm0, [eax+ecx]
   db $0F,$6F,$4C,$08,$08   /// movq     mm1, [eax+ecx+8]
   db $0F,$6F,$54,$08,$10   /// movq     mm2, [eax+ecx+16]
   db $0F,$6F,$5C,$08,$18   /// movq     mm3, [eax+ecx+24]
   db $0F,$E7,$04,$0A       /// movntq   [edx+ecx], mm0
   db $0F,$E7,$4C,$0A,$08   /// movntq   [edx+ecx+8], mm1
   db $0F,$E7,$54,$0A,$10   /// movntq   [edx+ecx+16], mm2
   db $0F,$E7,$5C,$0A,$18   /// movntq   [edx+ecx+24], mm3
   add      ecx, 32
   jnz      @@Loop

@@End:
   db $0F,$77               /// emms
end;

// Move16FPU
//
procedure Move16FPU(const Source; var Dest; Count: Integer); register;
asm
   or       ecx, ecx
   jz       @@End

@@Copy:
   // round to 16
   add      ecx, 15
   and      cl, $F0

   lea      eax, [eax+ecx]
   lea      edx, [edx+ecx]

   neg      ecx

   test     ecx, 16
   jz       @@Loop

   fild     qword ptr [eax+ecx]
   fild     qword ptr [eax+ecx+8]
   fistp    qword ptr [edx+ecx+8]
   fistp    qword ptr [edx+ecx]
   add      ecx, 16
   jz       @@End

@@Loop:
   fild     qword ptr [eax+ecx]
   fild     qword ptr [eax+ecx+8]
   fistp    qword ptr [edx+ecx+8]
   fistp    qword ptr [edx+ecx]
   fild     qword ptr [eax+ecx+16]
   fild     qword ptr [eax+ecx+24]
   fistp    qword ptr [edx+ecx+24]
   fistp    qword ptr [edx+ecx+16]
   add      ecx, 32
   jnz      @@Loop

@@End:
end; //}

// MemClear16SSE
//
procedure MemClear16SSE(const Buffer; Count: Integer); register;
asm
   or       edx, edx
   jz       @@End

@@Copy:
   // round to 16
   add      edx, 15
   and      dl, $F0

   lea      eax, [eax+edx]
   db $0F,$EF,$C0           /// pxor     mm0, mm0

   neg      edx

   test     edx, 16
   jz       @@Loop

   db $0F,$E7,$04,$10       /// movntq   [eax+edx], mm0
   db $0F,$E7,$44,$10,$08   /// movntq   [eax+edx+8], mm0
   add      edx, 16
   jz       @@End

@@Loop:
   db $0F,$E7,$04,$10       /// movntq   [eax+edx], mm0
   db $0F,$E7,$44,$10,$08   /// movntq   [eax+edx+8], mm0
   db $0F,$E7,$44,$10,$10   /// movntq   [eax+edx+16], mm0
   db $0F,$E7,$44,$10,$18   /// movntq   [eax+edx+24], mm0
   add      edx, 32
   jnz      @@Loop

@@End:
   db $0F,$77               /// emms
end;

// MemClear16FPU
//
procedure MemClear16FPU(const Buffer; Count: Integer); register;
asm
   or       edx, edx
   jz       @@TrueEnd

@@Copy:
   // round to 16
   add      edx, 15
   and      dl, $F0

   lea      eax, [eax+edx]
   fldz

   neg      edx

   test     edx, 16
   jz       @@Loop

   fst      qword ptr [eax+edx]
   fst      qword ptr [eax+edx+8]
   add      edx, 16
   jz       @@End

@@Loop:
   fst      qword ptr [eax+edx]
   fst      qword ptr [eax+edx+8]
   fst      qword ptr [eax+edx+16]
   fst      qword ptr [eax+edx+24]
   add      edx, 32
   jnz      @@Loop

@@End:
   ffree    st(0)
@@TrueEnd:
end; //}

// AllocateSMB
//
function AllocateSMB(smbIndex : Integer) : PSMBManager;

   procedure FillOffsetArray(wa : PWordArray; n : Integer);
   asm
      dec   edx
   @@Loop:
      mov   word ptr [eax], dx
      dec   edx
      mov   word ptr [eax+2], dx
      add   eax, 4
      dec   edx
      jns   @@Loop
{   var
      i, k : Integer;
   begin
      k:=0;
      for i:=n-1 downto 0 do begin
         wa[k]:=i;
         Inc(k);
      end; }
   end;

var
   i, k, n : Cardinal;
   chunkSize, blkSize : Cardinal;
   p : Pointer;
   head : PSMBManager;
begin
   // Determine ChunkSize
   blkSize:=SMBIndexToSize(smbIndex);
   chunkSize:=cSMBBlocksPerChunk*blkSize;
   if chunkSize<64*1024 then
      chunkSize:=64*1024
   else begin
      if (chunkSize and $FFFF)<>0 then
         chunkSize:=(chunkSize and $FFFF0000)+$10000
      else chunkSize:=(chunkSize and $FFFF0000);
   end;
   n:=(chunkSize div blkSize);
   n:=n and $FFFFFFFE; // round to multiple of 2

   p:=SysGetMem(SizeOf(TSMBManager)+2*n*SizeOf(Word));
   Result:=PSMBManager(p);
   if p=nil then Exit;

   Result.Signature:=cSMBSignature;

   p:=Pointer(Integer(p)+SizeOf(TSMBManager));
   Result.BlockOffsets:=PWordArray(p);
   Result.BlockSizes:=PWordArray(Cardinal(p)+n*SizeOf(Word));

   // allocate our chunk
   Result.BlockStart:=AllocateRMMChunk(chunkSize, Result.ChunkBatch);
   if Result.BlockStart=nil then begin
      SysFreeMem(Result);
      Result:=nil;
      Exit;
   end;
   Result.ChunkSize:=chunkSize;

   UpdateMemoryMap(Result.BlockStart, chunkSize, Result);

   // fillup remaining block fields
   Result.BlockSize:=blkSize;
   Result.InvBlockSize:=1/blkSize;
   Result.ReallocDownSizingSize:=(blkSize div cSMBReallocDownSizing);
   if Result.ReallocDownSizingSize<cSMBAlignment then
      Result.ReallocDownSizingSize:=0;
   Result.MaxFreeBlockOffset:=n;
   Result.NbFreeBlockOffset:=n;
   i:=Result.NbFreeBlockOffset shr 3;
   if i<=0 then
      i:=1;
   Result.ReasonnablyFreeTreshold:=i;
   Result.SMBIndex:=smbIndex;
   FillOffsetArray(Result.BlockOffsets, n);
   k:=n*SizeOf(Word);
   if (k and 15)=0 then
      MemClear16(Result.BlockSizes[0], k)
   else FillChar(Result.BlockSizes[0], k, 0);
   head:=vFirstSMBs[smbIndex];
   Result.Next:=head;
   if Assigned(head) then
      head.Prev:=Result
   else vLastSMBs[smbIndex]:=Result;
   Result.Prev:=nil;
   vFirstSMBs[smbIndex]:=Result;
end;

// ReleaseSMB
//
procedure ReleaseSMB(manager : PSMBManager);
begin
   if manager.Next<>nil then begin
      manager.Next.Prev:=manager.Prev;
      if manager.Prev<>nil then
         manager.Prev.Next:=manager.Next
      else vFirstSMBs[manager.SMBIndex]:=manager.Next;
   end else begin
      vLastSMBs[manager.SMBIndex]:=manager.Prev;
      if manager.Prev<>nil then
         manager.Prev.Next:=manager.Next
      else vFirstSMBs[manager.SMBIndex]:=nil;
   end;

   UpdateMemoryMap(manager.BlockStart, manager.ChunkSize, nil);

   ReleaseRMMChunk(manager.BlockStart, manager.ChunkBatch, manager.ChunkSize);
   SysFreeMem(manager);
end;

// MakeSMBTopMost
//
procedure MakeSMBTopMost(manager : PSMBManager); register;
var
   smbIndex : Integer;
begin
   if manager.Prev<>nil then begin
      smbIndex:=manager.SMBIndex;
      manager.Prev.Next:=manager.Next;
      if manager.Next<>nil then
         manager.Next.Prev:=manager.Prev
      else vLastSMBs[smbIndex]:=manager.Prev;
      vFirstSMBs[smbIndex].Prev:=manager;
      manager.Next:=vFirstSMBs[smbIndex];
      manager.Prev:=nil;
      vFirstSMBs[smbIndex]:=manager;
   end;
end;

// MakeSMBLast
//
procedure MakeSMBLast(manager : PSMBManager); register; 
var
   smbIndex : Integer;
begin
   if manager.Next<>nil then begin
      smbIndex:=manager.SMBIndex;
      manager.Next.Prev:=manager.Prev;
      if manager.Prev<>nil then
         manager.Prev.Next:=manager.Next
      else vFirstSMBs[smbIndex]:=manager.Next;
      vLastSMBs[smbIndex].Next:=manager;
      manager.Prev:=vLastSMBs[smbIndex];
      manager.Next:=nil;
      vLastSMBs[smbIndex]:=manager;
   end;
end;

// FindNonFullSMBManager
//
function FindNonFullSMBManager(smbIndex : Integer) : PSMBManager;
var
   manager, candidate : PSMBManager;
   candidateFree : Cardinal;
begin
   manager:=vFirstSMBs[smbIndex];
   candidate:=nil;
   candidateFree:=0;
   while True do begin
      manager:=manager.next;
      if manager=nil then begin
         if candidateFree=0 then
            Result:=AllocateSMB(smbIndex)
         else begin
            MakeSMBTopMost(candidate);
            Result:=candidate;
         end;
         Exit;
      end else if manager.NbFreeBlockOffset>candidateFree then begin
         candidate:=manager;
         candidateFree:=manager.NbFreeBlockOffset;
         if candidateFree>=manager.ReasonnablyFreeTreshold then begin
            MakeSMBTopMost(manager);
            Result:=manager;
            Exit;
         end;
      end;
   end;
end;

// BlockOffsetToBlockIndex
//
procedure BlockOffsetToBlockIndex(p : Pointer; manager : PSMBManager; var result : Cardinal);
{var     // Pascal reference version
   relP : Cardinal;
begin
   relP:=Cardinal(p)-Cardinal(manager.BlockStart);
   result:=relP div manager.BlockSize;
   if result*manager.BlockSize<>relP then
      result:=Cardinal(-1);   // }
asm      // ASM mixed integer-FPU version (10 to 40 times faster)
   sub   eax, dword ptr [edx + offset TSMBManager.BlockStart]
   push  eax
   fild  dword ptr [esp]
   fmul  dword ptr [edx + offset TSMBManager.InvBlockSize]
   fistp dword ptr [ecx]
   movzx eax, word ptr [edx + offset TSMBManager.BlockSize]

   mul   dword ptr [ecx]
   pop   edx
   sub   eax, edx
   jnz   @@Error
   ret
@@Error:
   mov   [ecx], Cardinal(-1)   //}
end;

// RGetMem
//
function RGetMem(Size: Integer): Pointer;
var
   smbIndex, offset, blkID : Cardinal;
   n : Integer;
   manager : PSMBManager;
   lgbManager : PLGBManager;
label
   lblExitWhenOutOfMemory;    // t'was that or a try..finally (can't afford here)
begin
   if Size<=cSMBMaxSize then begin
      // Small Blocks logic
      smbIndex:=SMBSizeToIndex(Size);
      if System.IsMultiThread then
         EnterCriticalSection(vSMBLocks[smbIndex]);

      manager:=vFirstSMBs[smbIndex];
      if manager=nil then begin
         manager:=AllocateSMB(smbIndex);
         if manager=nil then begin
            Result:=nil;
            goto lblExitWhenOutOfMemory;
         end;
         n:=manager.NbFreeBlockOffset;
      end else begin
         // if current block is full, look for an empty one
         n:=manager.NbFreeBlockOffset;
         if n=0 then begin
            MakeSMBLast(manager);
            manager:=FindNonFullSMBManager(smbIndex);
            if manager=nil then begin
               Result:=nil;
               goto lblExitWhenOutOfMemory;
            end;
            n:=manager.NbFreeBlockOffset;
         end;
      end;
      Dec(n);
      manager.NbFreeBlockOffset:=n;
      blkID:=manager.BlockOffsets[n];
      manager.BlockSizes[blkID]:=Size;
      offset:=blkID*manager.BlockSize;
      Result:=Pointer(Cardinal(manager.BlockStart)+offset);

lblExitWhenOutOfMemory:
      if System.IsMultiThread then
         LeaveCriticalSection(vSMBLocks[smbIndex]);
   end else begin
      // Large blocks
      lgbManager:=AllocateLGB(Size);
      if Assigned(lgbManager) then
         Result:=lgbManager.BlockStart
      else Result:=nil;
   end;
end;

// RFreeMem
//
function RFreeMem(P: Pointer): Integer;
var
   {$ifdef RAISE_EXCEPTION_ON_INVALID_RELEASE}
   i : Integer;
   {$endif}
   n, blkID, locBlkID : Cardinal;
   smbIndex : Integer;
   manager : PSMBManager;
label
   lblRFreeMemExit;
begin
   {$ifdef SECURE_MEMORYMAP}
   if Integer(P)>0 then
      manager:=vMemoryMap[Cardinal(P) shr 16]
   else manager:=nil;
   {$else}
   manager:=vMemoryMap[Cardinal(P) shr 16];
   {$endif}

   if manager<>nil then begin
      if manager.Signature=cSMBSignature then begin
         // Small block release logic
         smbIndex:=manager.SMBIndex;
         if System.IsMultiThread then
            EnterCriticalSection(vSMBLocks[smbIndex]);

         BlockOffsetToBlockIndex(P, manager, blkID);
         locBlkID:=blkID;  // hints compiler it can place blkID in a register!
         if locBlkID<manager.MaxFreeBlockOffset then begin
            n:=manager.NbFreeBlockOffset;
            {$ifdef RAISE_EXCEPTION_ON_INVALID_RELEASE}
            for i:=n-1 downto 0 do begin
               if manager.BlockOffsets[i]=locBlkID then begin
                  if System.IsMultiThread then
                     LeaveCriticalSection(vSMBLocks[smbIndex]);
                  Result:=-1;
                  goto lblRFreeMemExit;
               end;
            end;
            {$endif}
            manager.BlockOffsets[n]:=locBlkID;
            manager.BlockSizes[locBlkID]:=0;
            Inc(n);
            manager.NbFreeBlockOffset:=n;
            if n<manager.MaxFreeBlockOffset then begin
               if n>=vFirstSMBs[smbIndex].NbFreeBlockOffset then
                  if vFirstSMBs[smbIndex].NbFreeBlockOffset<manager.ReasonnablyFreeTreshold then
                     MakeSMBTopMost(manager);
            end else begin
               // topmost manager can't die
               if (manager.Prev<>nil) or (smbIndex>cSMBRange1Offset) then
                  ReleaseSMB(manager);
            end;

            if System.IsMultiThread then
               LeaveCriticalSection(vSMBLocks[smbIndex]);
            Result:=0;
         end else Result:=-1;
      end else if manager.Signature=cLGBSignature then begin
         // Large block
         if P=PLGBManager(manager).BlockStart then begin
            ReleaseLGB(PLGBManager(manager));
            Result:=0;
         end else Result:=-1;
      end else Result:=-1;
   end else begin
      {$ifdef DEFER_INVALIDATE_POINTERS}
      Result:=SysFreeMem(P);
      {$else}
      Result:=-1;
      {$endif}
   end;
   {$ifdef RAISE_EXCEPTION_ON_INVALID_RELEASE}
lblRFreeMemExit:
   if Result=-1 then
      raise Exception.Create('RecyclerMM: attempt to free an unallocated block!');
   {$endif}
end;

// RReallocMem
//
function RReallocMem(P: Pointer; Size: Cardinal) : Pointer;
var
   blkID, copySize : Cardinal;
   manager : PSMBManager;
   lgm : PLGBManager;
begin
   {$ifdef SECURE_MEMORYMAP}
   if Integer(P)>0 then
      manager:=vMemoryMap[Cardinal(P) shr 16]
   else manager:=nil;
   {$else}
   manager:=vMemoryMap[Cardinal(P) shr 16];
   {$endif}
   if manager<>nil then begin
      if manager.Signature=cSMBSignature then begin
         // Reallocating a SMB
         BlockOffsetToBlockIndex(P, manager, blkID);
         if blkID<manager.MaxFreeBlockOffset then begin
            if (Size<=manager.BlockSize) and (Size>=manager.ReallocDownSizingSize) then begin
               manager.BlockSizes[blkID]:=Size;
               Result:=P;
            end else begin
               Result:=RGetMem(Size);
               copySize:=manager.BlockSizes[blkID];
               if copySize>Size then copySize:=Size;
               Move16(P^, Result^, copySize);
               RFreeMem(P);
            end;
         end else begin
            RaiseRMMInvalidPointerException;
            Result:=nil;
         end;
      end else if manager.Signature=cLGBSignature then begin
         // Reallocating a LGB
         lgm:=PLGBManager(manager);
         if P=lgm.BlockStart then begin
            if (Size<=lgm.BlockSize) and (Size>=lgm.ReallocDownSizingSize) then begin
               lgm.DataSize:=Size;
               Result:=P;
            end else begin
               Result:=RGetMem(Size);
               copySize:=lgm.DataSize;
               if copySize>Size then copySize:=Size;
               Move16(P^, Result^, copySize);
               RFreeMem(P);
            end;
         end else begin
            RaiseRMMInvalidPointerException;
            Result:=nil;
         end;
      end else begin
         RaiseRMMException('RReallocMem: Incoherency detected');
         Result:=nil;
      end;
   end else begin
      {$ifdef DEFER_INVALIDATE_POINTERS}
      Result:=SysReallocMem(P, Size);
      {$else}
      RaiseRMMInvalidPointerException;
      Result:=nil;
      {$endif}
   end;
end;

// RAllocMem
//
function RAllocMem(Size : Cardinal) : Pointer; register;
asm
   push  ebx
   mov   ebx, eax
   call  RGetMem              // Result:=RGetMem(Size);
   cmp   ebx, cSMBChunkSize   // LGBs are automatically initialized to zero
   jg    @@End
   mov   edx, ebx
   mov   ebx, eax
   call  [MemClear16]      // MemClear16(Result^, Size);
   mov   eax, ebx
@@End:
   pop   ebx
end;

// Allocated
//
function Allocated(const P : Pointer) : Boolean;
var
   blkID : Cardinal;
   manager : PSMBManager;
   locP : Pointer;
begin
   locP:=P;
   if locP=nil then
      Result:=False
   else begin
      {$ifdef SECURE_MEMORYMAP}
      if Integer(locP)>0 then
         manager:=vMemoryMap[Cardinal(locP) shr 16]
      else manager:=nil;
      {$else}
      manager:=vMemoryMap[Cardinal(locP) shr 16];
      {$endif}
      if Assigned(manager) then begin
         if manager.Signature=cSMBSignature then begin
            BlockOffsetToBlockIndex(locP, manager, blkID);
            Result:=(blkID<manager.MaxFreeBlockOffset) and (manager.BlockSizes[blkID]>0);
         end else if manager.Signature=cLGBSignature then begin
            Result:=(PLGBManager(manager).BlockStart=locP);
         end else Result:=False;
      end else Result:=False;
   end;
end;

// RedirectPatch
//
function RedirectPatch(oldRoutine, newRoutine : Pointer) : TRedirectPatch;
var
   oldProtect, protect : Cardinal;
   bplAddr : Pointer;
begin
   if oldRoutine=newRoutine then Exit;
   // backup jump data
   Result.jumpAddr:=oldRoutine;
   Move(PByte(oldRoutine)^, Result.jumpBuffer[0], 6);
   // patch jump
   VirtualProtect(oldRoutine, 256, PAGE_READWRITE, @oldProtect);
   PByte(oldRoutine)^:=$E9;
   PInteger(Integer(oldRoutine)+1)^:=Integer(newRoutine)-Integer(oldRoutine)-5;
   VirtualProtect(oldRoutine, 256, oldProtect, @protect);
   // did we patch a BPL jump table?
   Result.bplAddr:=nil;
   {$ifndef NO_BPL_PATCHING}
   if Result.jumpBuffer[0]=$FF then begin
      // yep, find address of the routine in the BPL
      bplAddr:=PPointer(PPointer(@Result.jumpBuffer[2])^)^;
      // back it up
      Result.bplAddr:=bplAddr;
      Move(PByte(bplAddr)^, Result.bplBuffer[0], 6);
      // and patch it too
      VirtualProtect(bplAddr, 256, PAGE_READWRITE, @oldProtect);
      PByte(bplAddr)^:=$E9;
      PInteger(Integer(bplAddr)+1)^:=Integer(newRoutine)-Integer(bplAddr)-5;
      VirtualProtect(bplAddr, 256, oldProtect, @protect);
   end;
   {$endif}
end;

// RestorePatch
//
procedure RestorePatch(var redirectBackup : TRedirectPatch);
var
   oldProtect, protect : Cardinal;
begin
   with redirectBackup do begin
      if jumpAddr<>nil then begin
         VirtualProtect(jumpAddr, 256, PAGE_READWRITE, @oldProtect);
         Move(jumpBuffer[0], jumpAddr^, 6);
         VirtualProtect(jumpAddr, 256, oldProtect, @protect);
      end;
      jumpAddr:=nil;
      if bplAddr<>nil then begin
         VirtualProtect(bplAddr, 256, PAGE_READWRITE, @oldProtect);
         Move(bplBuffer[0], bplAddr^, 6);
         VirtualProtect(bplAddr, 256, oldProtect, @protect);
      end;
      bplAddr:=nil
   end;
end;

// InitializeRMM
//
procedure InitializeRMM;
var
   i : Integer;
begin
   InitializeCriticalSection(vLGBLock);
   {$ifdef SECURE_MEMORYMAP}
   vMemoryMap:=VirtualAlloc(nil, SizeOf(TPointerArray32k), MEM_COMMIT,
                            PAGE_READWRITE);
   {$endif}
   for i:=Low(vSMBLocks) to High(vSMBLocks) do
      InitializeCriticalSection(vSMBLocks[i]);

   InitializeCriticalSection(vRMMBatchesLock);
   vRMMChunkBatches:=AllocateRMMChunkBatch;
end;

// FinalizeRMM
//
procedure FinalizeRMM;
var
   i : Integer;
begin
   for i:=Low(vFirstSMBs) to High(vFirstSMBs) do
      while vFirstSMBs[i]<>nil do
         ReleaseSMB(vFirstSMBs[i]);
   for i:=Low(vLGBManagers) to High(vLGBManagers) do
      while vLGBManagers[i]<>nil do
         ReleaseLGB(vLGBManagers[i]);
   ReleaseRMMChunkBatch(vRMMChunkBatches);
   {$ifdef SECURE_MEMORYMAP}
   VirtualFree(vMemoryMap, 0, MEM_RELEASE);
   {$endif}
   for i:=Low(vSMBLocks) to High(vSMBLocks) do
      DeleteCriticalSection(vSMBLocks[i]);
   DeleteCriticalSection(vLGBLock);
   DeleteCriticalSection(vRMMBatchesLock);
end;

// LockRMM
//
procedure LockRMM;
var
   i : Integer;
begin
   for i:=Low(vSMBLocks) to High(vSMBLocks) do
      EnterCriticalSection(vSMBLocks[i]);
   EnterCriticalSection(vLGBLock);
   EnterCriticalSection(vRMMBatchesLock);
end;

// UnLockRMM
//
procedure UnLockRMM;
var
   i : Integer;
begin
   LeaveCriticalSection(vRMMBatchesLock);
   LeaveCriticalSection(vLGBLock);
   for i:=High(vSMBLocks) downto Low(vSMBLocks) do
      LeaveCriticalSection(vSMBLocks[i]);
end;

// BindRMM
//
procedure BindRMM;

   {$ifdef SHARE_MEM}
   procedure PrepareDataName;
   const
      cIntToHex : ShortString = '0123456789ABCDEF';
   var
      i : Integer;
      h : Cardinal;
   begin
      // name generation must NOT use any dynamic stuff (for obvious reasons)
      h:=GetCurrentProcessID;
      for i:=0 to 7 do
         vSharedMemory_DataName[i+1]:=cIntToHex[1+((h shr (i*4)) and $F)];
   end;
   {$endif}

var
   smm : PSharedMemoryManager;
   hwnd : Integer;
begin
   Inc(vRMMBound);
   if vRMMBound=1 then begin
      {$ifdef SHARE_MEM}
      PrepareDataName;
      hwnd:=FindWindow('STATIC', PChar(@vSharedMemory_DataName[1]));
      {$else}
      hwnd:=0;
      {$endif}
      smm:=@vSharedMemoryManager;
      if hwnd=0 then begin
         // defined SharedMemoryManager fields
         smm.MemoryManager.GetMem:=@RGetMem;
         smm.MemoryManager.FreeMem:=@RFreeMem;
         smm.MemoryManager.ReallocMem:=@RReallocMem;
         smm.AllocMem:=@RAllocMem;
         smm.Allocated:=@Allocated;
         smm.RMMUsageSnapShot:=@RMMUsageSnapShot;
         // Setup structure data for shared memory
         {$ifdef SHARE_MEM}
         vSharedMemory_Data:=CreateWindow('STATIC',
                                          PChar(@vSharedMemory_DataName[1]),
                                          WS_POPUP,
                                          0, 0, 0, 0,
                                          0, 0, GetCurrentProcessID, nil);
         SetWindowLong(vSharedMemory_Data, GWL_USERDATA,
                       LongWord(@vSharedMemoryManager));
         vSharedMemory_InUse:=False;
         {$endif}
         InitializeRMM;
      end else begin
         {$ifdef SHARE_MEM}
         // we're in a DLL and a RMM has been setup by the application
         smm:=PSharedMemoryManager(GetWindowLong(hwnd, GWL_USERDATA));
         vSharedMemory_InUse:=True;
         {$endif}
      end;
      // replace standard MemoryManager
      GetMemoryManager(vOldMemoryManager);
      SetMemoryManager(smm.MemoryManager);
      // Redirect SysUtils's AllocMem
      {$ifdef PATCH_ALLOCMEM}
      vAllocMemPatch:=RedirectPatch(@SysUtils.AllocMem, @smm.AllocMem);
      {$endif}
      vAllocatedPatch:=RedirectPatch(@Allocated, @smm.Allocated);
      vRMMUsageSnapShotPatch:=RedirectPatch(@RMMUsageSnapShot, @smm.RMMUsageSnapShot);
   end;
end;

// UnBindRMM
//
procedure UnBindRMM;
begin
   Dec(vRMMBound);
   if vRMMBound=0 then begin
      {$ifdef PATCH_ALLOCMEM}
      RestorePatch(vAllocMemPatch);
      {$endif}
      {$ifndef DEFER_INVALIDATE_POINTERS}
      RestorePatch(vAllocatedPatch);
      RestorePatch(vRMMUsageSnapShotPatch);
      SetMemoryManager(vOldMemoryManager);
      {$ifdef SHARE_MEM}
      if not vSharedMemory_InUse then begin
         DestroyWindow(vSharedMemory_Data);
         FinalizeRMM;
      end;
      {$else}
      FinalizeRMM;
      {$endif}
      {$endif}
   end else if vRMMBound<0 then
      RaiseRMMException('Unbalanced UnBindRMM');
end;

// RMMActive
//
function  RMMActive : Boolean;
begin
   Result:=(vRMMBound>0);
end;

// RMMUsageSnapShot (func)
//
function RMMUsageSnapShot : TRMMUsageSnapShot;
begin
   RMMUsageSnapShot(Result);
end;

// RMMUsageSnapShot (proc)
//
procedure RMMUsageSnapShot(var result : TRMMUsageSnapShot); overload;

   // computes userSize and nbBlocks contribution for overlapping situations
   procedure AddOverlapStat(start, blockStart, blockEnd, blockSize : Cardinal;
                            var userSize, nbBlocks : Cardinal);
   var
      startEnd : Cardinal;
   begin
      if blockSize=0 then Exit;
      startEnd:=start+(1 shl 16);
      if (blockStart>=startEnd) or (blockEnd<=start) then Exit;
      if (blockStart>=start) and (blockStart<startEnd) then
         Inc(nbBlocks);
      blockEnd:=blockStart+blockSize;
      if blockEnd<=start then Exit;
      if blockEnd<=startEnd then
         if blockStart>=start then
            Inc(userSize, blockSize)
         else Inc(userSize, blockEnd-start)
      else if blockStart>=start then
         Inc(userSize, startEnd-blockStart)
      else Inc(userSize, 1 shl 16);
   end;

var
   i, j, k, kp, kp1 : Cardinal;
   userSize, nbBlocks, blkSize, totalUserSize : Cardinal;
   psmb : PSMBManager;
   plgb : PLGBManager;
   pchunk : PRMMChunkBatch;
   mapEntry : PRMMMemoryMap;
   mbi : TMemoryBasicInformation;
begin
   Assert(vRMMBound>0);
   // we're not allowed to use any kind of dynamic allocation here
   LockRMM;
   try
      Result.NbMapItems:=32768;
      Result.TotalVirtualAllocated:=vTotalVirtualAllocated;
      nbBlocks:=0;
      totalUserSize:=0;
      // Build the memory map
      // first go through the memory map
      for i:=0 to 32767 do begin
         mapEntry:=@Result.Map[i];
         mapEntry.StartAddr:=Pointer(i shl 16);
         mapEntry.Length:=1 shl 16;
         psmb:=vMemoryMap[i];
         if psmb=nil then begin
            // 64kb area not allocated by RMM (but maybe reserved as chunkbatch)
            mapEntry.AllocatedUserSize:=0;
            mapEntry.Status:=rmmsUnallocated;
         end else if psmb.Signature=cSMBSignature then begin
            // 64kb area used by an SMB
            userSize:=0;
            if psmb.ChunkSize<=(1 shl 16) then begin
               // chunk size below 64kB is fully evaluated
               for k:=0 to psmb.MaxFreeBlockOffset-1 do begin
                  blkSize:=psmb.BlockSizes[k];
                  if blkSize>0 then begin
                     Inc(userSize, blkSize);
                     Inc(nbBlocks);
                  end;
               end;
            end else begin
               // chunk larger than 64kB, partial evaluation required
               j:=(i shl 16)-Cardinal(psmb.BlockStart);
               for k:=0 to psmb.MaxFreeBlockOffset-1 do begin
                  kp:=(k*psmb.BlockSize);
                  kp1:=kp+psmb.BlockSize;
                  AddOverlapStat(j, kp, kp1, psmb.BlockSizes[k],
                                 userSize, nbBlocks);
               end;
            end;
            Inc(totalUserSize, userSize);
            mapEntry.AllocatedUserSize:=userSize;
            if userSize>0 then
               mapEntry.Status:=rmmsAllocated
            else mapEntry.Status:=rmmsReserved;
         end else if psmb.Signature=cLGBSignature then begin
            // 64kb area used by an LGB
            plgb:=PLGBManager(psmb);
            k:=(i shl 16)-Cardinal(plgb.BlockStart);
            if k=0 then begin
               Inc(totalUserSize, plgb.DataSize);
               Inc(nbBlocks);
            end;
            if k<plgb.DataSize then
               mapEntry.AllocatedUserSize:=1 shl 16
            else if k+(1 shl 16)<plgb.DataSize then
               mapEntry.AllocatedUserSize:=plgb.DataSize-k
            else mapEntry.AllocatedUserSize:=0;
            mapEntry.Status:=rmmsAllocated;
         end;
      end;
      Result.AllocatedBlocks:=nbBlocks;
      Result.AllocatedUserSize:=totalUserSize;
      // then go through chunks and mark them as reserved
      pchunk:=vRMMChunkBatches;
      while Assigned(pchunk) do begin
         for i:=0 to cRMMChunkBatchAllocSize-1 do begin
            if (pchunk.ChunkAllocated and (1 shl i))=0 then begin
               mapEntry:=@Result.Map[Cardinal(pchunk.Chunks[i]) shr 16];
               Assert(mapEntry.Status=rmmsUnallocated);
               mapEntry.Status:=rmmsReserved;
            end;
         end;
         pchunk:=pchunk.Next;
      end;
      {$ifdef SECURE_MEMORYMAP}
      // mark vMemoryMap as 100% used
      k:=Cardinal(vMemoryMap) shr 16;
      for i:=k to k+(SizeOf(TPointerArray32k) shr 16)-1 do begin
         mapEntry:=@Result.Map[i];
         Assert(mapEntry.Status=rmmsUnallocated);
         mapEntry.Status:=rmmsAllocated;
         mapEntry.AllocatedUserSize:=mapEntry.Length;
      end;
      {$endif}
      // Collect VM space stats
      Result.TotalVMSpace:=Cardinal(1) shl 31;
      Result.SystemAllocatedVM:=0;
      Result.SystemReservedVM:=0;
      k:=0; kp:=0;
      // Make a pass through the unallocated chunks and ask about their status
      for i:=0 to 32767 do begin
         mapEntry:=@Result.Map[i];
         if mapEntry.Status=rmmsUnallocated then begin
            VirtualQuery(Pointer(i shl 16), mbi, SizeOf(mbi));
            if mbi.State=MEM_COMMIT	then begin
               mapEntry.Status:=rmmsSysAllocated;
               Inc(Result.SystemAllocatedVM, 1 shl 16);
            end else if mbi.State=MEM_RESERVE then begin
               mapEntry.Status:=rmmsSysReserved;
               Inc(Result.SystemReservedVM, 1 shl 16);
            end;
         end;
         if mapEntry.Status<>rmmsUnallocated then begin
            if i-k>kp then kp:=i-k;
            k:=i+1;
         end;
      end;
      if 32768-k>kp then kp:=32767-k;
      Result.LargestFreeVM:=kp shl 16;
      // Build SMBStats
      for i:=Low(vFirstSMBs) to High(vFirstSMBs) do begin
         nbBlocks:=0;
         userSize:=0;
         k:=0;
         psmb:=vFirstSMBs[i];
         while Assigned(psmb) do begin
            Inc(nbBlocks, psmb.MaxFreeBlockOffset-psmb.NbFreeBlockOffset);
            for j:=0 to psmb.MaxFreeBlockOffset-1 do
               Inc(userSize, psmb.BlockSizes[j]);
            Inc(k, psmb.ChunkSize);
            psmb:=psmb.Next;
         end;
         with Result.SMBStats[i] do begin
            BlockSize:=SMBIndexToSize(i);
            AllocatedBlocks:=nbBlocks;
            AllocatedUserSize:=userSize;
            TotalVirtualAllocated:=k;
         end;
      end;
   finally
      UnLockRMM;
   end;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

   {$ifdef ALLOW_SSE}
   try
      // detect SSE capable CPU
      asm
         push   ebx
         pushfd
         pop    eax
         mov    edx, eax
         xor    edx, $200000
         push   eax
         popfd
         pushfd
         pop    eax
         cmp    eax, edx
         jz     @@Exit           // CPUID not supported
         mov    eax, 0
         db $0F,$A2              /// cpuid
         jz     @@Exit           // features not supported
         mov    eax, 1
         db $0F,$A2              /// cpuid
         test   edx, (1 shl 25)  // SSE support?
         setnz  al
         mov    byte ptr [vSSESupported], al
      @@Exit:
         pop     ebx
      end;
   except
      // trap for old/exotics CPUs
      vSSESupported:=0;
   end;
   if vSSESupported<>0 then begin
      MemClear16:=@MemClear16SSE;
      Move16:=@Move16SSE;
   end else begin
      MemClear16:=@MemClear16FPU;
      Move16:=@Move16FPU;
   end;
   {$else}
   MemClear16:=@MemClear16FPU;
   Move16:=@Move16FPU;
   {$endif}

{$ifdef AUTO_BIND}
   BindRMM;

finalization

   UnBindRMM; //}
{$endif}

end.

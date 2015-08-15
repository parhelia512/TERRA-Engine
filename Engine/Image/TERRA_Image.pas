{***********************************************************************************************************************
 *
 * TERRA Game Engine
 * ==========================================
 *
 * Copyright (C) 2003, 2014 by S�rgio Flores (relfos@gmail.com)
 *
 ***********************************************************************************************************************
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 **********************************************************************************************************************
 * TERRA_Image
 * Implements image manipulation class
 ***********************************************************************************************************************
}
Unit TERRA_Image;

{$I terra.inc}

Interface
Uses TERRA_Object, TERRA_String, TERRA_Utils, TERRA_Stream, TERRA_Color;

Const
  componentRed    = 0;
  componentGreen  = 1;
  componentBlue   = 2;
  componentAlpha  = 3;

  maskRed = 1;
  maskGreen = 2;
  maskBlue = 4;
  maskAlpha = 8;
  maskRGB = maskRed Or maskGreen Or maskBlue;
  maskRGBA = maskRGB Or maskAlpha;

  PixelSize:Cardinal = 4;

Type
  ImageTransparencyType = (imageUnknown, imageOpaque, imageTransparent, imageTranslucent);

  ImageFrame = Class(TERRAObject)
    Protected
      _Data:Array Of ColorRGBA;
    Public
      Constructor Create(Width, Height:Integer);
      Procedure Release; Override;

  End;

  Image = Class;

  ImageProcessFlags = Set Of (image_Read, image_Write, image_Fill, image_Kernel);

  ImageKernel = Array[0..8] Of Single;

  ImageIterator = Class(TERRAObject)
    Private
      _Value:ColorRGBA;
      _Current:PColorRGBA;

    Protected
      _X:Integer;
      _Y:Integer;

      _Clone:Image;
      _Target:Image;
      _Flags:ImageProcessFlags;
      _Mask:Cardinal;

      Function ObtainNext():Boolean; Virtual; Abstract;

    Public
      Constructor Create(Target:Image; Flags:ImageProcessFlags; Const Mask:Cardinal);
      Procedure Release; Override;

      Function ApplyKernel(Const Kernel:ImageKernel):ColorRGBA;

      Function HasNext():Boolean;

      Property Value:ColorRGBA Read _Value Write _Value;
      Property X:Integer Read _X;
      Property Y:Integer Read _Y;
  End;

  Image = Class(TERRAObject)
    Protected
      _Frames:Array Of ImageFrame;
      _FrameCount:Cardinal;

      _Pixels:ImageFrame;

      _Width:Cardinal;
      _Height:Cardinal;
      _Pitch:Cardinal;
      _Size:Cardinal;

      _CurrentFrame:Cardinal;

      _TransparencyType:ImageTransparencyType;

      Procedure Discard;

      Function GetPixelCount:Cardinal;
      Function GetPixels:PColorRGBA;

      Function GetImageTransparencyType:ImageTransparencyType;

    Public
      Constructor Create(Width, Height:Integer);Overload;
      Constructor Create(Source:Stream);Overload;
      Constructor Create(FileName:TERRAString);Overload;
      Constructor Create(Source:Image);Overload;
      Procedure Release; Override;

      Procedure Load(Source:Stream);Overload;
      Procedure Load(FileName:TERRAString);Overload;

      Procedure Save(Dest:Stream; Format:TERRAString; Options:TERRAString='');Overload;
      Procedure Save(Filename:TERRAString; Format:TERRAString=''; Options:TERRAString='');Overload;

      Procedure Copy(Source:Image);
      Procedure Resize(Const NewWidth,NewHeight:Cardinal);

      Procedure LinearResize(Const NewWidth,NewHeight:Cardinal);

      Procedure New(Const Width,Height:Cardinal);
      Function AddFrame:ImageFrame;
      Procedure NextFrame(Skip:Cardinal=1);
      Procedure SetCurrentFrame(ID:Cardinal);

      {$IFDEF NDS}Function AutoTile:Cardinal;{$ENDIF}

      Procedure BlitByUV(Const U,V,U1,V1,U2,V2:Single; Const Source:Image);
      Procedure Blit(X,Y,X1,Y1,X2,Y2:Integer; Const Source:Image);

      Procedure BlitAlphaMapByUV(Const U,V,U1,V1,U2,V2,AU1,AV1,AU2,AV2:Single; Const Source,AlphaMap:Image);
      Procedure BlitAlphaMap(X,Y,X1,Y1,X2,Y2,AX1,AY1,AX2,AY2:Integer; Const Source,AlphaMap:Image);

      Procedure BlitWithAlphaByUV(Const U,V,U1,V1,U2,V2:Single; Const Source:Image; ForceBlend:Boolean = True);
      Procedure BlitWithAlpha(X,Y,X1,Y1,X2,Y2:Integer; Const Source:Image; ForceBlend:Boolean = True);

      Procedure BlitWithMaskByUV(Const U,V,U1,V1,U2,V2:Single; Const Color:ColorRGBA; Const Source:Image);
      Procedure BlitWithMask(X,Y,X1,Y1,X2,Y2:Integer; Const Color:ColorRGBA; Const Source:Image);

      Function Crop(X1,Y1,X2,Y2:Integer):Image;

      Procedure FlipHorizontal();
      Procedure FlipVertical();

      Function Combine(Layer:Image; Alpha:Single; Mode:ColorCombineMode; Const Mask:Cardinal = maskRGBA):Boolean;

      Function LineByUV(Const U1,V1,U2,V2:Single; Flags:ImageProcessFlags; Const Mask:Cardinal = maskRGBA):ImageIterator;
      Function Line(X1,Y1,X2,Y2:Integer; Flags:ImageProcessFlags; Const Mask:Cardinal = maskRGBA):ImageIterator;

      Function RectangleByUV(Const U1,V1,U2,V2:Single; Flags:ImageProcessFlags; Const Mask:Cardinal = maskRGBA):ImageIterator;
      Function Rectangle(X1,Y1,X2,Y2:Integer; Flags:ImageProcessFlags; Const Mask:Cardinal = maskRGBA):ImageIterator;

      Function CircleByUV(Const xCenter,yCenter:Single; Const Radius:Integer; Flags:ImageProcessFlags; Const Mask:Cardinal = maskRGBA):ImageIterator;
      Function Circle(xCenter,yCenter:Integer; Const Radius:Integer; Flags:ImageProcessFlags; Const Mask:Cardinal = maskRGBA):ImageIterator;

      Function Pixels(Flags:ImageProcessFlags; Const Mask:Cardinal = maskRGBA):ImageIterator;

      Procedure ClearWithColor(Const Color:ColorRGBA; Mask:Cardinal = maskRGBA);

      Function GetPixel(X,Y:Integer):ColorRGBA; {$IFDEF FPC}Inline;{$ENDIF}
      Function GetPixelByUV(Const U,V:Single):ColorRGBA; {$IFDEF FPC}Inline;{$ENDIF}
      Function GetComponent(X,Y,Component:Integer):Byte; {$IFDEF FPC}Inline;{$ENDIF}

      Procedure SetPixel(X,Y:Integer; Const Color:ColorRGBA); {$IFDEF FPC}Inline;{$ENDIF}
      Procedure SetPixelByUV(Const U,V:Single; Const Color:ColorRGBA); {$IFDEF FPC}Inline;{$ENDIF}

      //Procedure AddPixel(X,Y:Integer; Const Color:Color); {$IFDEF FPC}Inline;{$ENDIF}
      Procedure MixPixel(X,Y:Integer; Const Color:ColorRGBA); {$IFDEF FPC}Inline;{$ENDIF}

      Function MipMap():Image;

      Procedure LineDecodeRGBPalette4(Buffer, Palette:Pointer; Line:Cardinal);
      Procedure LineDecodeRGBPalette8(Buffer, Palette:Pointer; Line:Cardinal);
      Procedure LineDecodeRGB8(Buffer:Pointer; Line:Cardinal);
      Procedure LineDecodeRGB16(Buffer:Pointer; Line:Cardinal);
      Procedure LineDecodeRGB24(Buffer:Pointer; Line:Cardinal);
      Procedure LineDecodeRGB32(Buffer:Pointer; Line:Cardinal);

      Procedure LineDecodeBGRPalette4(Buffer, Palette:Pointer; Line:Cardinal);
      Procedure LineDecodeBGRPalette8(Buffer, Palette:Pointer; Line:Cardinal);
      Procedure LineDecodeBGR8(Buffer:Pointer; Line:Cardinal);
      Procedure LineDecodeBGR16(Buffer:Pointer; Line:Cardinal);
      Procedure LineDecodeBGR24(Buffer:Pointer; Line:Cardinal);
      Procedure LineDecodeBGR32(Buffer:Pointer; Line:Cardinal);

      Function GetPixelOffset(X,Y:Integer):PColorRGBA;
      Function GetLineOffset(Y:Integer):PColorRGBA;

      Property Width:Cardinal Read _Width;
      Property Height:Cardinal Read _Height;
      Property PixelCount:Cardinal Read GetPixelCount;
      Property Size:Cardinal Read _Size;
      Property RawPixels:PColorRGBA Read GetPixels;

      Property CurrentFrame:Cardinal Read _CurrentFrame Write SetCurrentFrame;
      Property FrameCount:Cardinal Read _FrameCount;

      Property TransparencyType:ImageTransparencyType Read GetImageTransparencyType;
  End;


  ImageStreamValidateFunction = Function(Source:Stream):Boolean;
  ImageLoader = Procedure(Source:Stream; Image:Image);
  ImageSaver = Procedure(Source:Stream; Image:Image; Const Options:TERRAString='');

  ImageClassInfo = Record
    Name:TERRAString;
    Validate:ImageStreamValidateFunction;
    Loader:ImageLoader;
    Saver:ImageSaver;
  End;

  Function GetImageLoader(Source:Stream):ImageLoader;
  Function GetImageSaver(Const Format:TERRAString):ImageSaver;
  Procedure RegisterImageFormat(Name:TERRAString;
                                Validate:ImageStreamValidateFunction;
                                Loader:ImageLoader;
                                Saver:ImageSaver=Nil);

  Function GetImageExtensionCount():Integer;
  Function GetImageExtension(Index:Integer):ImageClassInfo;

Implementation
Uses TERRA_FileStream, TERRA_FileUtils, TERRA_FileManager, TERRA_Math, TERRA_Log, TERRA_Vector4D, TERRA_ImageDrawing;

Var
  _ImageExtensions:Array Of ImageClassInfo;
  _ImageExtensionCount:Integer;

Function GetImageExtensionCount():Integer;
Begin
  Result := _ImageExtensionCount;
End;

Function GetImageExtension(Index:Integer):ImageClassInfo;
Begin
  If (Index>=0) And (Index<_ImageExtensionCount) Then
    Result := _ImageExtensions[Index]
  Else
  	FillChar(Result, SizeOf(Result), 0);
End;

Function GetImageLoader(Source:Stream):ImageLoader;
Var
  Pos:Cardinal;
  I:Integer;
Begin
  Result := Nil;
  If Not Assigned(Source) Then
    Exit;

  Pos := Source.Position;

  For I:=0 To Pred(_ImageExtensionCount) Do
  Begin
    Source.Seek(Pos);
    If _ImageExtensions[I].Validate(Source) Then
    Begin
      Log(logDebug, 'Image', 'Found '+_ImageExtensions[I].Name);
      Result := _ImageExtensions[I].Loader;
      Break;
    End;
  End;

  Source.Seek(Pos);
End;

Function GetImageSaver(Const Format:TERRAString):ImageSaver;
Var
  I:Integer;
Begin
  Result := Nil;

  For I:=0 To Pred(_ImageExtensionCount) Do
  If StringEquals(_ImageExtensions[I].Name, Format) Then
  Begin
    Result := _ImageExtensions[I].Saver;
    Exit;
  End;
End;

Procedure RegisterImageFormat(Name:TERRAString;
                              Validate:ImageStreamValidateFunction;
                              Loader:ImageLoader;
                              Saver:ImageSaver=Nil);
Var
  I,N:Integer;
Begin
  Name := StringLower(Name);

  For I:=0 To Pred(_ImageExtensionCount) Do
  If (_ImageExtensions[I].Name = Name) Then
    Exit;

  N := _ImageExtensionCount;
  Inc(_ImageExtensionCount);
  SetLength(_ImageExtensions, _ImageExtensionCount);
  _ImageExtensions[N].Name := Name;
  _ImageExtensions[N].Validate :=Validate;
  _ImageExtensions[N].Loader := Loader;
  _ImageExtensions[N].Saver := Saver;
End;

{ ImageIterator }
Constructor ImageIterator.Create(Target:Image; Flags:ImageProcessFlags; Const Mask:Cardinal);
Begin
  Self._Flags := Flags;
  Self._Mask := Mask;
  Self._Target := Target;

  If (image_Kernel In _Flags) Then
  Begin
    _Clone := Image.Create(Target);
  End;
End;

Function ImageIterator.ApplyKernel(Const Kernel:ImageKernel):ColorRGBA;
Var
  I,J:Integer;
  Denominator, K:Single;
  PR,PG,PB,PA:Integer;
  P:PColorRGBA;
Begin
  If {(_X<=0) Or (_Y<=0) Or (_X>=Pred(_Target.Width)) Or (_Y>=Pred(_Target.Height)) Or }(_Clone = Nil) Then
  Begin
    Result := _Value;
    Exit;
  End;

  PR := 0;
  PG := 0;
  PB := 0;
  PA := 0;

  Denominator := 0.0;
  For J:=-1 To 1 Do
    For I:=-1 To 1 Do
    Begin
      P := _Clone.GetPixelOffset(_X+I, _Y+J);

      K := Kernel[Succ(I) + Succ(J)*3];
      Denominator := Denominator + K;

      PR := PR + Trunc(P.R * K);
      PG := PG + Trunc(P.G * K);
      PB := PB + Trunc(P.B * K);
      PA := PA + Trunc(P.A * K);
    End;

  If (Denominator <> 0.0) Then
    Denominator := 1.0 / Denominator
  Else
    Denominator := 1.0;

  Result := ColorCreate(
    Trunc(FloatMax(0.0, FloatMin(255.0, PR * Denominator))),
    Trunc(FloatMax(0.0, FloatMin(255.0, PG * Denominator))),
    Trunc(FloatMax(0.0, FloatMin(255.0, PB * Denominator))),
    Trunc(FloatMax(0.0, FloatMin(255.0, PA * Denominator)))
  );
End;

Function ImageIterator.HasNext: Boolean;
Begin
  If (Assigned(_Current)) And (image_Write In _Flags) Then
  Begin
    If (_Mask  = maskRGBA) Then
    Begin
      _Current^ := _Value;
    End Else
    Begin
      If (_Mask And maskRed<>0) Then
        _Current.R := _Value.R;

      If (_Mask And maskGreen<>0) Then
        _Current.G := _Value.G;

      If (_Mask And maskBlue<>0) Then
        _Current.B := _Value.B;

      If (_Mask And maskAlpha<>0) Then
        _Current.A := _Value.A;
    End;
  End;

  Result := Self.ObtainNext();

  If Result Then
  Begin
    _Current := _Target.GetPixelOffset(_X, _Y);

    If (image_Read In _Flags) Then
    Begin
        _Value := _Current^;
    End;
  End;
End;

Procedure ImageIterator.Release;
Begin
  ReleaseObject(_Clone);
End;

{ Image }
Constructor Image.Create(Width, Height:Integer);
Begin
  _CurrentFrame := 0;
  _FrameCount := 0;
  New(Width, Height);
End;

Constructor Image.Create(Source:Stream);
Begin
  Load(Source);
End;

Constructor Image.Create(FileName:TERRAString);
Begin
  Load(FileName);
End;

Constructor Image.Create(Source:Image);
Begin
  Copy(Source);
End;

Procedure Image.Release;
Begin
  Discard;
End;

Procedure Image.New(Const Width,Height:Cardinal);
Begin
  Discard();

  _TransparencyType := imageUnknown;
  _CurrentFrame := MaxInt;

  _Width := Width;
  _Height := Height;
  _Size := Width * Height * PixelSize;

  _FrameCount := 0;
  Self.AddFrame();
End;

Function Image.AddFrame():ImageFrame;
Var
  K:Integer;
Begin
  Inc(_FrameCount);
  SetLength(_Frames,_FrameCount);

  K := Pred(_FrameCount);
  _Frames[K] := ImageFrame.Create(_Width, _Height);
  Result := _Frames[K];
  SetCurrentFrame(K);
End;

Function Image.GetPixelCount:Cardinal;
Begin
  Result := Width * Height;
End;

Function Image.GetPixels:PColorRGBA;
Begin
  If Assigned(_Pixels._Data) Then
    Result := @_Pixels._Data[0]
  Else
    Result := Nil;
End;

Procedure Image.Copy(Source:Image);
Var
  I:Cardinal;
Begin
  {Log(logDebug, 'Game', 'Copying image');
  Log(logDebug, 'Game', 'Width:'+IntToString(Source.Width));
  Log(logDebug, 'Game', 'Height:'+IntToString(Source.Height));}

  New(Source.Width, Source.Height);

  If Source.FrameCount<=0 Then
    Exit;

  For I:=0 To Pred(Source.FrameCount) Do
  Begin
    Move(Source._Frames[I]._Data[0], Self._Frames[I]._Data[0], Size);

    If I<Pred(Source.FrameCount) Then
      Self.AddFrame();
  End;

  _TransparencyType := Source._TransparencyType;
End;

Procedure Image.Resize(Const NewWidth,NewHeight:Cardinal);
Const
  FixedPointBits = 12;
Var
  K:Integer;
  X, Y:Cardinal;
  AX,AY,BX,BY,CX,CY,DX,DY:Single;
  U,V,UV:Single;
  OneMinusU, OneMinusV, oneMinusUOneMinusV:Single;
  uOneMinusV, vOneMinusU:Single;
  srcX, srcY, srcXStep, srcYStep:Single;
  pSrcPixelA, pSrcPixelB, pSrcPixelC, pSrcPixelD:ColorRGBA;
  Dest:ImageFrame;
  Pixel:ColorRGBA;
Begin
  If (NewWidth=Width) And (NewHeight=Height) Then
    Exit;

  If (Width<=0) Or (Height<=0) Then
    Exit;

  If (NewWidth<=0) Or (NewHeight<=0) Then
  Begin
    _Width := 0;
    _Height := 0;
    _Size := 0;
    Exit;
  End;

  // Resizes the bitmap image using bilinear sampling.
  srcX := 0.0;
  srcY := 0.0;
  srcXStep := _width / NewWidth;
  srcYStep := _height / NewHeight;

  For K:=0 To Pred(FrameCount) Do
  Begin
    SetCurrentFrame(K);
    Dest := ImageFrame.Create(NewWidth, NewHeight);

    For Y := 0 To Pred(NewHeight) Do
    Begin
      For X:= 0 To Pred(NewWidth) Do
      Begin
        ax := floor(srcX);
        u := srcX - ax;
        if (srcXStep>1.0) Then
          u := 0.5;

        ay := floor(srcY);
        v := srcY - ay;
        if (srcYStep>1.0) Then
          v := 0.5;

        dx := ax + 1.0;
        dy := ay + 1.0;

        if (dx >= _width) Then
          dx := _width - 1.0;

        if (dy >= _height) Then
          dy := _height - 1.0;

        bx := dx;
        by := ay;

        cx := ax;
        cy := dy;

        uv := u * v;
        oneMinusU := 1.0 - u;
        oneMinusV := 1.0 - v;
        uOneMinusV := u * oneMinusV;
        vOneMinusU := v * oneMinusU;
        oneMinusUOneMinusV := oneMinusU * oneMinusV;

			  If (ax<0) Then ax := 0;
			  If (ax>=_width) Then ax := _width-1;
			  If (bx<0) Then bx := 0;
			  If (bx>=_width) Then bx := _width-1;
			  If (cx<0) Then cx := 0;
			  If (cx>=_width) Then cx := _width-1;
			  If (dx<0) Then dx := 0;
			  If (dx>=_width) Then dx := _width-1;

			  If (ay<0) Then ay := 0;
			  If (ay>=_height) Then ay := _height-1;
			  If (by<0) Then by := 0;
			  If (by>=_height) Then by := _height-1;
			  If (cy<0) Then cy := 0;
			  If (cy>=_height) Then cy := _height-1;
			  If (dy<0) Then dy := 0;
			  If (dy>=_height) Then dy := _height-1;

        pSrcPixelA := _Pixels._Data[Trunc((ay * _width) + ax)];
        pSrcPixelB := _Pixels._Data[Trunc((by * _width) + bx)];
        pSrcPixelC := _Pixels._Data[Trunc((cy * _width) + cx)];
        pSrcPixelD := _Pixels._Data[Trunc((dy * _width) + dx)];

			  pixel.R := Trunc(pSrcPixelA.R * oneMinusUOneMinusV + pSrcPixelB.R * uOneMinusV + pSrcPixelC.R * vOneMinusU + pSrcPixelD.R * uv);
			  pixel.G := Trunc(pSrcPixelA.G * oneMinusUOneMinusV + pSrcPixelB.G * uOneMinusV + pSrcPixelC.G * vOneMinusU + pSrcPixelD.G * uv);
			  pixel.B := Trunc(pSrcPixelA.B * oneMinusUOneMinusV + pSrcPixelB.B * uOneMinusV + pSrcPixelC.B * vOneMinusU + pSrcPixelD.B * uv);
			  pixel.A := Trunc(pSrcPixelA.A * oneMinusUOneMinusV + pSrcPixelB.A * uOneMinusV + pSrcPixelC.A * vOneMinusU + pSrcPixelD.A * uv);

        Dest._Data[(Y * NewWidth + X)] := Pixel;
        srcX := srcX + srcXStep;
      End;

      srcX := 0.0;
      srcY := srcY + srcYStep;
    End;

    ReleaseObject(_Frames[K]);
    _Frames[K]:= Dest;
  End;

  _Width := NewWidth;
  _Height := NewHeight;
  _Size := _Width * _Height * PixelSize;
  _CurrentFrame := MaxInt;
  SetCurrentFrame(0);
End;

Procedure Image.LinearResize(Const NewWidth,NewHeight:Cardinal);
Const
  FixedPointBits = 12;
Var
  I,J,K:Cardinal;
  Sx,Sy:Cardinal;
  NX,NY:Cardinal;
  PX,PY:Cardinal;
  Buffer:ImageFrame;
  Dest:PColorRGBA;
Begin
  If (NewWidth=Width)And(NewHeight=Height) Then
    Exit;

  If (_Pixels = Nil) Then
  Begin
    Self.New(Width, Height);
    Exit;
  End;

  Sx := Trunc((Width / NewWidth)*(1 Shl FixedPointBits));
  Sy := Trunc((Height/ NewHeight)*(1 Shl FixedPointBits));

  For K:=0 To Pred(FrameCount) Do
  Begin
    Buffer := ImageFrame.Create(NewWidth, NewHeight);

    Dest := @Buffer._Data[0];
    NX := 0;
    NY := 0;
    For J:=0 To Pred(NewHeight) Do
    Begin
      For I:=0 To Pred(NewWidth) Do
      Begin
        PX := (NX Shr FixedPointBits);
        PY := (NY Shr FixedPointBits);

        Dest^ := _Pixels._Data[(PY*Width+PX)];
        Inc(Dest);

        Inc(NX, SX);
      End;

      Inc(NY, SY);
      NX:=0;
    End;

    ReleaseObject(_Frames[K]);
    _Frames[K] := Buffer;
  End;

  _Width := NewWidth;
  _Height := NewHeight;
  _Size := _Width * _Height * PixelSize;
  _CurrentFrame := MaxInt;
  SetCurrentFrame(0);
End;

Procedure Image.SetCurrentFrame(ID:Cardinal);
Begin
  If (ID>=_FrameCount) Then
    ID:=0;

  If (ID=_CurrentFrame) Then
    Exit;

  _CurrentFrame:=ID;
  _Pixels := _Frames[ID];
End;

Procedure Image.NextFrame(Skip:Cardinal=1);
Begin
  If Skip<=0 Then
    Exit;
  SetCurrentFrame((_CurrentFrame+Skip) Mod _FrameCount);
End;

Procedure Image.Discard;
Var
  I:Integer;
Begin
  If (_FrameCount>0) Then
  For I:=0 To Pred(_FrameCount) Do
  If Assigned(_Frames[I]) Then
  Begin
    ReleaseObject(_Frames[I]);
    _Frames[I] := Nil;
  End;

  SetLength(_Frames,0);
  _FrameCount:=0;
  _CurrentFrame:=0;
  _Pixels := Nil;
End;

Procedure Image.FlipVertical();
Var
  N:Cardinal;
  I,J,K:Cardinal;
  Temp:ColorRGBA;
  Source,Dest:PColorRGBA;
Begin
  If (_Width = 0) Or (_Height = 0) Then
    Exit;

  For K:=0 To Pred(_FrameCount) Do
  Begin
    Source := RawPixels;
    N := _Height Shr 1;
    If (Not Odd(_Height)) Then
      Dec(N);

    For J:=0 To N Do
    For I:=0 To Pred(_Width) Do
    Begin
      Dest := @_Frames[K]._Data[((Pred(Height)-J)*_Width+I)];

      Temp := Source^;
      Source^ := Dest^;
      Dest^ := Temp;

      Inc(Source);
    End;
  End;
End;

Procedure Image.FlipHorizontal();
Var
  N:Cardinal;
  Temp:ColorRGBA;
  I,J,K:Cardinal;
  Source,Dest:PColorRGBA;
Begin
  If (_Width = 0) Or (_Height = 0) Then
    Exit;

  For K:=0 To Pred(_FrameCount) Do
  Begin
    N := _Width Shr 1;
    If (Not Odd(_Width)) Then
      Dec(N);

    For J:=0 To Pred(_Height) Do
    Begin
      Source := @_Frames[K]._Data[(J*_Width)];
      Dest := @_Frames[K]._Data[(J*_Width+Pred(_Width))];

      For I:=0 To N Do
      Begin
        Temp := Source^;
        Source^ := Dest^;
        Dest^ := Temp;

        Inc(Source);
        Dec(Dest);
      End;

      Inc(Source, N);
    End;
  End;
End;

Procedure Image.BlitByUV(Const U,V,U1,V1,U2,V2:Single; Const Source:Image);
Begin
  Blit(Integer(Round(U*Width)), Integer(Round(V*Height)),
       Integer(Round(U1*Source.Width)), Integer(Round(V1*Source.Height)),
       Integer(Round(U2*Source.Width)), Integer(Round(V2*Source.Height)), Source);
End;

Procedure Image.BlitAlphaMapByUV(Const U,V,U1,V1,U2,V2,AU1,AV1,AU2,AV2:Single; Const Source,AlphaMap:Image);
Begin
  BlitAlphaMap(Integer(Round(U*Width)), Integer(Round(V*Height)),
              Integer(Round(U1*Source.Width)), Integer(Round(V1*Source.Height)),
              Integer(Round(U2*Source.Width)), Integer(Round(V2*Source.Height)),
              Integer(Round(AU1*AlphaMap.Width)), Integer(Round(AV1*AlphaMap.Height)),
              Integer(Round(AU2*AlphaMap.Width)), Integer(Round(AV2*AlphaMap.Height)),
              Source,AlphaMap);
End;

Procedure Image.BlitWithAlphaByUV(Const U,V,U1,V1,U2,V2:Single; Const Source:Image; ForceBlend:Boolean);
Begin
  BlitWithAlpha(Integer(Round(U*Width)), Integer(Round(V*Height)),
                  Integer(Round(U1*Source.Width)), Integer(Round(V1*Source.Height)),
                  Integer(Round(U2*Source.Width)), Integer(Round(V2*Source.Height)),
                  Source, ForceBlend);
End;


Procedure Image.BlitWithMaskByUV(Const U,V,U1,V1,U2,V2:Single; Const Color:ColorRGBA; Const Source:Image);
Begin
  BlitWithMask(Integer(Round(U*Width)), Integer(Round(V*Height)),
                  Integer(Round(U1*Source.Width)), Integer(Round(V1*Source.Height)),
                  Integer(Round(U2*Source.Width)), Integer(Round(V2*Source.Height)),
                  Color, Source);
End;

Function Image.LineByUV(Const U1,V1,U2,V2:Single; Flags:ImageProcessFlags; Const Mask:Cardinal):ImageIterator;
Begin
  Result := Line(Integer(Trunc(U1*Width)), Integer(Trunc(V1*Height)), Integer(Trunc(U2*Width)), Integer(Trunc(V2*Height)), Flags, Mask);
End;

Procedure Image.Blit(X,Y, X1,Y1,X2,Y2:Integer; Const Source:Image);
Var
  Dest, Data:PColorRGBA;
  I,J:Integer;
  BlitSize,BlitHeight:Integer;
Begin
  If (X>=_Width) Or (Y>=_Height) Then
    Exit;

  If (X1>=Source.Width) Or (Y1>=Source.Height) Then
    Exit;

  If (X<0) Then
  Begin
    X1 := X1 - X;
    If (X1>=X2) Then
      Exit;

    X := 0;
  End;

  If (Y<0) Then
  Begin
    Y1 := Y1 - Y;
    If (Y1>=Y2) Then
      Exit;

    Y := 0;
  End;
    
  BlitHeight := Y2-Y1;
  BlitSize := X2-X1;

  If (BlitHeight<=0) Or (BlitSize<=0) Then
    Exit;

  For J:=0 To Pred(BlitHeight) Do
    For I:=0 To Pred(BlitSize) Do
      SetPixel(X+I, Y+J, Source.GetPixel(X1+I, Y1+J));
    Exit;

{  Dest := Self.GetPixelOffset(X,Y);
  Data := Source.GetPixelOffset(X1, Y1);
  While (BlitHeight>0) Do
  Begin
    SafeMove(Data^, Dest^, BlitSize, Self.Pixels, Self._Size);
    Inc(Dest, Width);
    Inc(Data, Source.Width);
    Dec(BlitHeight);
  End;}
End;

Procedure Image.BlitAlphaMap(X,Y,X1,Y1,X2,Y2,AX1,AY1,AX2,AY2:Integer; Const Source,AlphaMap:Image);
Var
  I,J:Integer;
  BlitSize,BlitHeight:Integer;
  AX,AY,ADX,ADY:Single;
  A,B,C:ColorRGBA;
  Alpha:Cardinal;
Begin
  If (X>=_Width) Or (Y>=_Height) Then
    Exit;

  If (X1>=Source.Width) Or (Y1>=Source.Height) Then
    Exit;

  If (X<0) Then
  Begin
    X1 := X1 - X;
    If (X1>=X2) Then
      Exit;

    X := 0;
  End;

  If (Y<0) Then
  Begin
    Y1 := Y1 - Y;
    If (Y1>=Y2) Then
      Exit;

    Y := 0;
  End;
    
  BlitHeight := (Y2-Y1);
  BlitSize := (X2-X1);
  If (BlitHeight<=0) Or (BlitSize<=0) Then
    Exit;

  AX := AX1;
  AY := AY1;
  ADX := (AX2-AX1) / BlitSize;
  ADY := (AY2-AY1) / BlitHeight;
          
  For J:=0 To Pred(BlitHeight) Do
  Begin
    For I:=0 To Pred(BlitSize) Do
    Begin
    	Alpha := AlphaMap.GetPixel(Integer(Trunc(AX)), Integer(Trunc(AY))).R;
    	
    	A := Source.GetPixel(X1+I, Y1+J);
    	B :=  Self.GetPixel(X+I, Y+J);
    	C := ColorBlend(A, B, Alpha);
 	    SetPixel(X+I, Y+J, C);
      
      AX:=AX+ADX;
    End;

    AX:=AX1;
    AY:=AY+ADY;
  End;
End;

Procedure Image.BlitWithAlpha(X,Y,X1,Y1,X2,Y2:Integer; Const Source:Image; ForceBlend:Boolean);
Var
  I,J,BlitSize,BlitHeight:Integer;
  Data,Dest:PColorRGBA;
Begin
  X1:=IntMax(X1,0);
  X2:=IntMin(X2,Integer(Source.Width));

  Y1:=IntMax(Y1,0);
  Y2:=IntMin(Y2,Integer(Source.Height));

  If (X<0) Then
  Begin
    X1 := X1 - X;
    If (X1>=X2) Then
      Exit;

    X := 0;
  End;

  If (Y<0) Then
  Begin
    Y1 := Y1 - Y;
    If (Y1>=Y2) Then
      Exit;

    Y := 0;
  End;

  BlitHeight:=(Y2-Y1);
  BlitSize:=(X2-X1);

  If (X+BlitSize >= Self.Width) Then
    BlitSize := Self.Width-X;

  If (Y+BlitHeight>= Self.Height) Then
    BlitHeight := Self.Height-Y;

  Dest := @_Pixels._Data[Y*Width +X];
  Data := @Source._Pixels._Data[Y1* Source.Width +X1];
  J := Y;
  While (BlitHeight>0) Do
  Begin
    If J>=0 Then

    For I:=1 To BlitSize Do
    Begin
      If (ForceBlend) Then
      Begin
        Dest^ := ColorBlend(Data^, Dest^);
      End Else
      If (Data.A>0) Then
      Begin
        //Data.A := Dest.A;
        //Dest^ := ColorScale(Data^, 1.3);
        Dest^ := Data^;
      End;

      Inc(Dest);
      Inc(Data);
    End;
    Inc(Dest, (Self.Width-BlitSize));
    Inc(Data, (Source.Width-BlitSize));
    Dec(BlitHeight);
    Inc(J);
  End;
End;

Procedure Image.BlitWithMask(X,Y,X1,Y1,X2,Y2:Integer; Const Color:ColorRGBA; Const Source:Image);
Var
  I,BlitSize,BlitHeight:Integer;
  Data,Dest:PColorRGBA;
Begin
  X1:=IntMax(X1,0);
  X2:=IntMin(X2,Integer(Pred(Source.Width)));

  Y1:=IntMax(Y1,0);
  Y2:=IntMin(Y2,Integer(Pred(Source.Height)));

  BlitHeight:=(Y2-Y1);
  BlitSize:=(X2-X1);

  If (X+BlitSize>=Self.Width) Then
    BlitSize:=Self.Width-X;
  If (Y+BlitHeight>=Self.Height) Then
    BlitHeight:=Self.Height-Y;

  Dest := @_Pixels._Data[Y*Width +X];
  Data := @Source._Pixels._Data[Y1* Source.Width +X1];
  While (BlitHeight>0) Do
  Begin
    For I:=1 To BlitSize Do
    Begin
      Dest^ := ColorBlend(Color, Dest^, Data.A);
      Inc(Dest);
      Inc(Data);
    End;
    Inc(Dest, (Self.Width-BlitSize));
    Inc(Data, (Source.Width-BlitSize));
    Dec(BlitHeight);
  End;
End;

Function Image.Line(X1,Y1,X2,Y2:Integer; Flags:ImageProcessFlags; Const Mask:Cardinal):ImageIterator;
Begin
  Result := LineImageIterator.Create(Self, X1, Y1, X2, Y2, Flags, Mask);
End;

Function Image.RectangleByUV(Const U1,V1,U2,V2:Single; Flags:ImageProcessFlags; Const Mask:Cardinal):ImageIterator;
Begin
  Result := Rectangle(Integer(Trunc(U1*Width)), Integer(Trunc(V1*Height)), Integer(Trunc(U2*Width)), Integer(Trunc(V2*Height)), Flags, Mask);
End;

Function Image.Rectangle(X1,Y1,X2,Y2:Integer; Flags:ImageProcessFlags; Const Mask:Cardinal):ImageIterator;
Begin
  Result := RectImageIterator.Create(Self, X1, Y1, X2, Y2, Flags, Mask);
End;

Function Image.CircleByUV(Const xCenter,yCenter:Single; Const Radius:Integer; Flags:ImageProcessFlags; Const Mask:Cardinal):ImageIterator;
Begin
  Result := Self.Circle(Integer(Round(xCenter*Width)),Integer(Round(yCenter*Height)), Radius, Flags, Mask);
End;

Function Image.Circle(xCenter,yCenter:Integer; Const Radius:Integer; Flags:ImageProcessFlags; Const Mask:Cardinal):ImageIterator;
Begin
  Result := CircleImageIterator.Create(Self, xCenter, yCenter, Radius, Flags, Mask);
End;

Function Image.GetLineOffset(Y:Integer):PColorRGBA;
Begin
  If (_Height<=0) Then
  Begin
    Result := Nil;
    Exit;
  End;

  If (Y<0) Then
    Y := 0
  Else
  If (Y>=_Height) Then
    Y := Pred(_Height);

  Result := @_Pixels._Data[Y * Width];
End;

Function Image.GetPixelOffset(X,Y:Integer):PColorRGBA;
Begin
  While (X<0) Do
    X := X + Width;

  If (X>=Width) Then
    X := X Mod Width;

  While (Y<0) Do
    Y := Y + Height;

  If (Y>=Height) Then
    Y := Y Mod Height;

  If (_Pixels._Data = Nil) Then
    Result := Nil
  Else
    Result := @_Pixels._Data[Y * Width + X];
End;

Function Image.GetPixelByUV(Const U,V:Single):ColorRGBA; {$IFDEF FPC}Inline;{$ENDIF}
Var
  X,Y:Integer;
Begin
  X := Trunc(U*Width);
  Y := Trunc(V*Height);
  Result := GetPixel(X,Y);
End;

Function Image.GetPixel(X,Y:Integer):ColorRGBA; {$IFDEF FPC}Inline;{$ENDIF}
Begin
  If (RawPixels = Nil) Or (Width<=0) Or (Height<=0)Then
  Begin
    Result := ColorNull;
    Exit;
  End;

  Result := GetPixelOffset(X,Y)^;
End;

Function Image.GetComponent(X,Y,Component:Integer):Byte; {$IFDEF FPC}Inline;{$ENDIF}
Var
  P:ColorRGBA;
Begin
  P := GetPixel(X,Y);
  Result := PByteArray(@P)[Component];
End;

Procedure Image.SetPixelByUV(Const U,V:Single; Const Color:ColorRGBA); {$IFDEF FPC}Inline;{$ENDIF}
Var
  X,Y:Integer;
Begin
  X:=Trunc(U*Width) Mod Width;
  Y:=Trunc(V*Height) Mod Height;
  SetPixel(X,Y,Color);
End;

Procedure Image.SetPixel(X,Y:Integer; Const Color:ColorRGBA); {$IFDEF FPC}Inline;{$ENDIF}
Var
  Dest:PColorRGBA;
Begin
  Dest := Self.GetPixelOffset(X, Y);
  Dest^ := Color;
End;

Procedure Image.MixPixel(X,Y:Integer; Const Color:ColorRGBA); {$IFDEF FPC}Inline;{$ENDIF}
Var
  Dest:PColorRGBA;
Begin
  If (X<0) Then X:=0;
  If (Y<0) Then Y:=0;
  If (X>=Integer(Width)) Then X:=Pred(Integer(Width));
  If (Y>=Integer(Height)) Then Y:=Pred(Integer(Height));

  Dest :=  @_Pixels._Data[Y*Width+X];
  Dest^ := ColorBlend(Color, Dest^);
End;

(*Procedure Image.AddPixel(X,Y:Integer; Const Color:Color); {$IFDEF FPC}Inline;{$ENDIF}
Var
  Dest:PColor;
Begin
  If (X<0) Or (Y<0) Or (X>=Width) Or (Y>=Height) Then
    Exit;

  {$IFDEF PIXEL8}
  //TODO
  {$ELSE}
  Dest := @_Pixels._Data[Y*Width+X];
  Dest^ := ColorAdd(Dest^, Color);
  {$ENDIF}
End;*)

Procedure Image.Load(FileName:TERRAString);
Var
  Source:Stream;
Begin
  Source := FileManager.Instance.OpenStream(FileName);
  If Assigned(Source) Then
  Begin
    Load(Source);
    ReleaseObject(Source);
  End;
End;

Procedure Image.Load(Source:Stream);
Var
  Loader:ImageLoader;
Begin
  If Source = Nil Then
  Begin
    Log(logDebug, 'Image', 'Invalid image stream!');
    Exit;
  End;

  Log(logDebug, 'Image', 'Searching formats');
  Loader := GetImageLoader(Source);
  If Not Assigned(Loader) Then
  Begin
    Self.New(4, 4);
    Log(logDebug, 'Image', 'Unknown image format. ['+Source.Name+']');
    Exit;
  End;

  Log(logDebug, 'Image', 'Loading image from loader ');
  Loader(Source, Self);
  Log(logDebug, 'Image', 'Image loaded');
End;

Procedure Image.Save(Dest:Stream; Format:TERRAString; Options:TERRAString='');
Var
  Saver:ImageSaver;
Begin
  If (_Pixels = Nil) Then
    Exit;

  Saver := GetImageSaver(Format);
  If Not Assigned(Saver) Then
  Begin
    Log(logError, 'Image', 'Cannot save image to '+Format+' format. ['+Dest.Name+']');
    Exit;
  End;

  Log(logDebug, 'Image', 'Saving image in '+Format+' format');
  Saver(Dest, Self, Options);
End;

Procedure Image.Save(Filename:TERRAString; Format:TERRAString=''; Options:TERRAString='');
Var
  Dest:Stream;
Begin
  If Format='' Then
    Format := GetFileExtension(FileName);

  Dest := FileStream.Create(FileName);
  Save(Dest, Format, Options);
  ReleaseObject(Dest);
End;


{$IFDEF PIXEL8}
Procedure Image.LineDecodeRGB8(Buffer: Pointer; Line: Cardinal);
Var
  Dest:PByte;
Begin
fsdfs
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Move(Buffer^, Dest^, _Width);
End;

Procedure Image.LineDecodeRGB16(Buffer: Pointer; Line: Cardinal);
Var
  Source:PWord;
  Dest:PByte;
  Count:Integer;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;
sfds
  Count:=_Width;
  Source:=Buffer;

  While (Count>0) Do
  Begin
//    Dest^:=ColorRGB16To8(Source^);
    Inc(Source);
    Inc(Dest);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeRGB24(Buffer: Pointer; Line: Cardinal);
Var
  Source:PByte;
  Dest:PByte;
  Temp:Color;
  Count:Integer;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count:=_Width;
  Source:=Buffer;

  Temp.A:=255;
  While (Count>0) Do
  Begin
    {$IFDEF RGB}
    Temp.R:=Source^; Inc(Source);
    Temp.G:=Source^; Inc(Source);
    Temp.B:=Source^; Inc(Source);
    {$ENDIF}
    {$IFDEF BGR}
    Temp.B:=Source^; Inc(Source);
    Temp.G:=Source^; Inc(Source);
    Temp.R:=Source^; Inc(Source);
    {$ENDIF}
    Dest^:=ColorRGB32To8(Temp);
    Inc(Dest);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeRGB32(Buffer: Pointer; Line: Cardinal);
Var
  Source:PColor;
  Dest:PByte;
  Count:Integer;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count:=_Width;
  Source:=Buffer;

  While (Count>0) Do
  Begin
    Dest^:=ColorRGB32To8(Source^);
    Inc(Source);
    Inc(Dest);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeRGBPalette4(Buffer, Palette: Pointer; Line:Cardinal);
Var
  Source, ColorTable:PByte;
  Dest:PByte;
  Count:Integer;
  Index:Integer;
  Temp:Color;
  A,B:Byte;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count:=_Width Shr 1;
  Source:=Buffer;

  Temp.A:=255;
  While (Count>0) Do
  Begin
    A:=Source^;
    B:=A And $0F;
    A:=(A Shr  4) And $0F;
    ColorTable:=PByte(Cardinal(Palette)+ A*4);
    {$IFDEF RGB}
    Temp.R:=ColorTable^; Inc(ColorTable);
    Temp.G:=ColorTable^; Inc(ColorTable);
    Temp.B:=ColorTable^; Inc(ColorTable);
    {$ENDIF}
    {$IFDEF BGR}
    Temp.B:=ColorTable^; Inc(ColorTable);
    Temp.G:=ColorTable^; Inc(ColorTable);
    Temp.R:=ColorTable^; Inc(ColorTable);
    {$ENDIF}
    Dest^:=ColorRGB32To8(Temp);
    Inc(Dest);

    ColorTable:=PByte(Cardinal(Palette)+ B*4);
    {$IFDEF RGB}
    Temp.R:=ColorTable^; Inc(ColorTable);
    Temp.G:=ColorTable^; Inc(ColorTable);
    Temp.B:=ColorTable^; Inc(ColorTable);
    {$ENDIF}
    {$IFDEF BGR}
    Temp.B:=ColorTable^; Inc(ColorTable);
    Temp.G:=ColorTable^; Inc(ColorTable);
    Temp.R:=ColorTable^; Inc(ColorTable);
    {$ENDIF}
    Dest^:=ColorRGB32To8(Temp);
    Inc(Dest);

    Inc(Source);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeRGBPalette8(Buffer, Palette: Pointer; Line:Cardinal);
Var
  Source, ColorTable:PByte;
  Dest:PByte;
  Count:Integer;
  Index:Integer;
  Temp:Color;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count:=_Width;
  Source:=Buffer;

  Temp.A:=255;
  While (Count>0) Do
  Begin
    ColorTable:=PByte(Cardinal(Palette)+ (Source^)*4);
    {$IFDEF RGB}
    Temp.R:=ColorTable^; Inc(ColorTable);
    Temp.G:=ColorTable^; Inc(ColorTable);
    Temp.B:=ColorTable^; Inc(ColorTable);
    {$ENDIF}
    {$IFDEF BGR}
    Temp.B:=ColorTable^; Inc(ColorTable);
    Temp.G:=ColorTable^; Inc(ColorTable);
    Temp.R:=ColorTable^; Inc(ColorTable);
    {$ENDIF}
    Inc(ColorTable);
    Dest^:=ColorRGB32To8(Temp);
    Inc(Source);
    Inc(Dest);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeBGR8(Buffer: Pointer; Line:Cardinal);
Var
  Dest:PByte;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Move(Buffer^, Dest^, _Width);
End;

Procedure Image.LineDecodeBGR16(Buffer: Pointer; Line:Cardinal);
Var
  Source:PWord;
  Dest:PByte;
  Count:Integer;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count:=_Width;
  Source:=Buffer;

  While (Count>0) Do
  Begin
//    Dest^:=ColorBGR16To8(Source^);
    Inc(Source);
    Inc(Dest);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeBGR24(Buffer: Pointer; Line:Cardinal);
Var
  Source:PByte;
  Dest:PByte;
  Temp:Color;
  Count:Integer;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count:=_Width;
  Source:=Buffer;

  Temp.A:=255;
  While (Count>0) Do
  Begin
    {$IFDEF BGR}
    Temp.R:=Source^; Inc(Source);
    Temp.G:=Source^; Inc(Source);
    Temp.B:=Source^; Inc(Source);
    {$ENDIF}
    {$IFDEF RGB}
    Temp.B:=Source^; Inc(Source);
    Temp.G:=Source^; Inc(Source);
    Temp.R:=Source^; Inc(Source);
    {$ENDIF}
    Dest^:=ColorRGB32To8(Temp);
    Inc(Dest);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeBGR32(Buffer: Pointer; Line:Cardinal);
Var
  Source:PColor;
  Dest:PByte;
  Count:Integer;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count:=_Width;
  Source:=Buffer;

  While (Count>0) Do
  Begin
    Dest^:=ColorBGR32To8(Source^);
    Inc(Source);
    Inc(Dest);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeBGRPalette4(Buffer, Palette: Pointer; Line:Cardinal);
Var
  Source, ColorTable:PByte;
  Dest:PByte;
  Count:Integer;
  Index:Integer;
  Temp:Color;
  A,B:Byte;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count:=_Width Shr 1;
  Source:=Buffer;

  Temp.A:=255;
  While (Count>0) Do
  Begin
    A:=Source^;
    B:=A And $0F;
    A:=(A Shr  4) And $0F;
    ColorTable:=PByte(Cardinal(Palette)+ A*4);
    {$IFDEF BGR}
    Temp.R:=ColorTable^; Inc(ColorTable);
    Temp.G:=ColorTable^; Inc(ColorTable);
    Temp.B:=ColorTable^; Inc(ColorTable);
    {$ENDIF}
    {$IFDEF RGB}
    Temp.B:=ColorTable^; Inc(ColorTable);
    Temp.G:=ColorTable^; Inc(ColorTable);
    Temp.R:=ColorTable^; Inc(ColorTable);
    {$ENDIF}
    Dest^:=ColorRGB32To8(Temp);
    Inc(Dest);

    ColorTable:=PByte(Cardinal(Palette)+ B*4);
    {$IFDEF BGR}
    Temp.R:=ColorTable^; Inc(ColorTable);
    Temp.G:=ColorTable^; Inc(ColorTable);
    Temp.B:=ColorTable^; Inc(ColorTable);
    {$ENDIF}
    {$IFDEF RGB}
    Temp.B:=ColorTable^; Inc(ColorTable);
    Temp.G:=ColorTable^; Inc(ColorTable);
    Temp.R:=ColorTable^; Inc(ColorTable);
    {$ENDIF}
    Dest^:=ColorRGB32To8(Temp);
    Inc(Dest);

    Inc(Source);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeBGRPalette8(Buffer, Palette: Pointer; Line:Cardinal);
Var
  Source, ColorTable:PByte;
  Dest:PByte;
  Count:Integer;
  Index:Integer;
  Temp:Color;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count := _Width;
  Source := Buffer;

  Temp.A := 255;
  While (Count>0) Do
  Begin
    ColorTable:=PByte(Cardinal(Palette)+ (Source^)*4);
    {$IFDEF BGR}
    Temp.R:=ColorTable^; Inc(ColorTable);
    Temp.G:=ColorTable^; Inc(ColorTable);
    Temp.B:=ColorTable^; Inc(ColorTable);
    {$ENDIF}
    {$IFDEF RGB}
    Temp.B:=ColorTable^; Inc(ColorTable);
    Temp.G:=ColorTable^; Inc(ColorTable);
    Temp.R:=ColorTable^; Inc(ColorTable);
    {$ENDIF}
    Inc(ColorTable);
    Dest^:=ColorRGB32To8(Temp);
    Inc(Source);
    Inc(Dest);
    Dec(Count);
  End;
End;

{$ENDIF}

{$IFDEF PIXEL32}
Procedure Image.LineDecodeRGB8(Buffer: Pointer; Line: Cardinal);
Var
  Source:PByte;
  Dest:PColorRGBA;
  Count:Integer;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count:=_Width;
  Source:=Buffer;

  While (Count>0) Do
  Begin
    Dest ^:= ColorRGB8To32(Source^);
    Inc(Source);
    Inc(Dest);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeRGB16(Buffer: Pointer; Line:Cardinal);
Var
  Source:PWord;
  Dest:PColorRGBA;
  Count:Integer;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count:=_Width;
  Source:=Buffer;

  While (Count>0) Do
  Begin
    Dest^:=ColorRGB16To32(Source^);
    Inc(Source);
    Inc(Dest);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeRGB24(Buffer: Pointer; Line:Cardinal);
Var
  Source:PByte;
  Dest:PColorRGBA;
  Count:Integer;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count:=_Width;
  Source:=Buffer;
  While (Count>0) Do
  Begin
    {$IFDEF RGB}
    Dest.R:=Source^; Inc(Source);
    Dest.G:=Source^; Inc(Source);
    Dest.B:=Source^; Inc(Source);
    {$ENDIF}
    {$IFDEF BGR}
    Dest.B:=Source^; Inc(Source);
    Dest.G:=Source^; Inc(Source);
    Dest.R:=Source^; Inc(Source);
    {$ENDIF}
    Dest.A:=255;
    Inc(Dest);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeRGB32(Buffer: Pointer; Line:Cardinal);
Var
  Dest:PColorRGBA;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Move(Buffer^, Dest^, _Width*PixelSize);
End;

Procedure Image.LineDecodeRGBPalette4(Buffer, Palette: Pointer; Line:Cardinal);
Var
  Source:PByte;
  Dest:PColorRGBA;
  Count:Integer;
  A,B:Byte;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count := _Width;
  Source := Buffer;

  While (Count>0) Do
  Begin
    A:=Source^;
    B:=A And $0F;
    A:=(A Shr  4) And $0F;
    Dest^:=PColorPalette(Palette)[A];
    Inc(Dest);
    Dest^:=PColorPalette(Palette)[B];
    Inc(Dest);

    Inc(Source);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeRGBPalette8(Buffer, Palette: Pointer; Line:Cardinal);
Var
  Source:PByte;
  Dest:PColorRGBA;
  Count:Integer;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count:=_Width;
  Source:=Buffer;
  While (Count>0) Do
  Begin
    Dest^ := PColorPalette(Palette)[Source^];
    Inc(Source);
    Inc(Dest);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeBGR8(Buffer: Pointer; Line:Cardinal);
Var
  Source:PByte;
  Dest:PColorRGBA;
  Count:Integer;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count:=_Width;
  Source:=Buffer;
  While (Count>0) Do
  Begin
    Dest^:=ColorBGR8To32(Source^);
    Inc(Source);
    Inc(Dest);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeBGR16(Buffer: Pointer; Line:Cardinal);
Var
  Source:PWord;
  Dest:PColorRGBA;
  Count:Integer;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count := _Width;
  Source := Buffer;

  While (Count>0) Do
  Begin
    Dest^:=ColorBGR16To32(Source^);
    Inc(Source);
    Inc(Dest);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeBGR24(Buffer: Pointer; Line:Cardinal);
Var
  Source:PByte;
  Dest:PColorRGBA;
  Count:Integer;
Begin
  If (Line>=_Height) Or (Buffer = Nil) Then
    Exit;

  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count := _Width;
  Source := Buffer;

  While (Count>0) Do
  Begin
    {$IFDEF BGR}
    Dest.R := Source^; Inc(Source);
    Dest.G := Source^; Inc(Source);
    Dest.B := Source^; Inc(Source);
    {$ENDIF}
    {$IFDEF RGB}
    Dest.B := Source^; Inc(Source);
    Dest.G := Source^; Inc(Source);
    Dest.R := Source^; Inc(Source);
    {$ENDIF}
    Dest.A := 255;
    Inc(Dest);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeBGR32(Buffer: Pointer; Line:Cardinal);
Var
  Dest:PColorRGBA;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Move(Buffer^, Dest^, _Width*PixelSize);
End;

Procedure Image.LineDecodeBGRPalette4(Buffer, Palette: Pointer; Line:Cardinal);
Var
  Source:PByte;
  Dest:PColorRGBA;
  Count:Integer;
  A,B:Byte;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count:=_Width;
  Source:=Buffer;

  While (Count>0) Do
  Begin
    A:=Source^;
    B:=A And $0F;
    A:=(A Shr  4) And $0F;
    Dest^:=PColorPalette(Palette)[A];
    Inc(Dest);
    Dest^:=PColorPalette(Palette)[B];
    Inc(Dest);

    Inc(Source);
    Dec(Count);
  End;
End;

Procedure Image.LineDecodeBGRPalette8(Buffer, Palette: Pointer; Line:Cardinal);
Var
  Source:PByte;
  Dest:PColorRGBA;
  Count:Integer;
Begin
  Dest := Self.GetLineOffset(Line);
  If (Dest =  Nil) Then
    Exit;

  Count:=_Width;
  Source:=Buffer;

  While (Count>0) Do
  Begin
    Dest^:=PColorPalette(Palette)[Source^];
    Inc(Source);
    Inc(Dest);
    Dec(Count);
  End;
End;
{$ENDIF}

{$IFDEF NDS}
Function Image.AutoTile:Cardinal;
Var
	TileCount:Integer;
	Start, Dest, Temp:PByte;
	I,J,X,Y:Integer;
Begin
  GetMem(Temp, _Size);
  Dest:=Temp;
  TileCount:=((Width Shr 3) * (Height Shr 3));
	X:=0;
	Y:=0;
	For I:=0 To Pred(TileCount) Do
	Begin
		For J:=0 To 7 Do
		Begin
      Start := @_Pixels._Data[X+((Y+J)*_Width)];
			Move(Start^, Dest^, 8);
			Inc(Dest, 8);
		End;

		Inc(X,8);
		If (X>=_Width) Then
		Begin
			X:=0;
			Inc(Y,8);
		End;
	End;

  Move(Temp^, _Pixels._Data[0], _Size);
  FreeMem(Temp);
  Result := TileCount;
End;
{$ENDIF}

Function Image.Crop(X1,Y1,X2,Y2:Integer):Image;
Var
  W,H:Integer;
  I,J:Integer;
Begin
  W := Pred(X2-X1);
  H := Pred(Y2-Y1);
  If (W<=0) Or (H<=0) Then
  Begin
    Result := Nil;
    Exit;
  End;

  Result := Image.Create(W, H);
  For J:=0 To Pred(H) Do
    For I:=0 To Pred(W) Do
    Begin
      Result.SetPixel(I,J, Self.GetPixel(X1+I, Y1+J));
    End;
End;

Function Image.Combine(Layer:Image; Alpha:Single; Mode:ColorCombineMode; Const Mask:Cardinal):Boolean;
Var
  A,B:PColorRGBA;
  C:ColorRGBA;
  InvAlpha:Single;
  Count:Integer;
Begin
  Result := False;

  If (Layer = Nil) Then
    Exit;

  If (Layer.Width<>Self.Width) Or (Layer.Height<>Self.Height) Then
    Exit;

  A := Self.RawPixels;
  B := Layer.RawPixels;

  Count := Self.Width * Self.Height;

  InvAlpha := 1.0 - Alpha;

  While Count>0 Do
  Begin
    C := ColorCombine(A^, B^, Mode);

    If (Mask And maskRed<>0) Then
      A.R := Trunc(A.R * InvAlpha + C.R * Alpha);

    If (Mask And maskGreen<>0) Then
      A.g := Trunc(A.G * InvAlpha + C.G * Alpha);

    If (Mask And maskBlue<>0) Then
      A.B := Trunc(A.B * InvAlpha + C.B * Alpha);

    If (Mask And maskAlpha<>0) Then
      A.A := Trunc(A.A * InvAlpha + C.A * Alpha);

    If (Mask = maskAlpha) And (A.A<250) Then
    Begin
      A.R := 0;
      A.G := 0;
      A.B := 0;
    End;

    //A^:= ColorMix(C, A^, Alpha);

    Inc(A);
    Inc(B);
    Dec(Count);
  End;


  Result := True;
End;

Function Image.MipMap(): Image;
Var
  I,J:Integer;
  PX, PY:Single;
  A, B, C, D, F:ColorRGBA;
Begin
  Result := Image.Create(Self.Width Shr 1, Self.Height Shr 1);

  For I:=0 To Pred(Result.Width) Do
    For J:=0 To Pred(Result.Height) Do
    Begin
      PX := (I * 2.0) + 0.5;
      PY := (J * 2.0) + 0.5;

      A := Self.GetPixel(Trunc(PX), Trunc(PY));
      B := Self.GetPixel(Round(PX), Trunc(PY));
      C := Self.GetPixel(Round(PX), Round(PY));
      D := Self.GetPixel(Trunc(PX), Round(PY));

      F.R := Trunc((A.R + B.R + C.R + D.R) * 0.25);
      F.G := Trunc((A.G + B.G + C.G + D.G) * 0.25);
      F.B := Trunc((A.B + B.B + C.B + D.B) * 0.25);
      F.A := Trunc((A.A + B.A + C.A + D.A) * 0.25);

      Result.SetPixel(I, J, F);
    End;
End;

Function Image.GetImageTransparencyType:ImageTransparencyType;
Var
  P:PColorRGBA;
  Count:Integer;
Begin
  If _TransparencyType = imageUnknown Then
  Begin
    P := Self.RawPixels;
    Count := Self.Width * Self.Height;

    _TransparencyType := imageOpaque;
    While Count>0 Do
    Begin
      If (P.A<255) Then
      Begin
        If (P.A>0) Then
        Begin
          _TransparencyType := imageTranslucent;
          Break;
        End Else
          _TransparencyType := imageTransparent;
      End;

      Inc(P);
      Dec(Count);
    End;
  End;

  Result := _TransparencyType;
End;

Procedure Image.ClearWithColor(Const Color:ColorRGBA; Mask:Cardinal);
Var
  Count:Integer;
  P:PColorRGBA;
Begin
  P := Self.RawPixels;
  Count := Width * Height;

  If (Mask = maskRGBA) Then
  Begin
    While (Count>0) Do
    Begin
      P^ := Color;
      Inc(P);
      Dec(Count);
    End;
  End Else
  Begin
    While (Count>0) Do
    Begin
      If (Mask And maskRed<>0) Then
        P.R := Color.R;

      If (Mask And maskGreen<>0) Then
        P.G := Color.G;

      If (Mask And maskBlue<>0) Then
        P.B := Color.B;

      If (Mask And maskAlpha<>0) Then
        P.A := Color.A;

      Inc(P);
      Dec(Count);
    End;
  End;
End;

Function Image.Pixels(Flags: ImageProcessFlags; Const Mask:Cardinal): ImageIterator;
Begin
  Result := FullImageIterator.Create(Self, Flags, Mask);
End;

{ ImageFrame }
Constructor ImageFrame.Create(Width, Height:Integer);
Begin
  SetLength(_Data, Width * Height);
  If (Width>0) And (Height>0) Then
	  FillChar(_Data[0], Width * Height * PixelSize, 0);
End;

Procedure ImageFrame.Release;
Begin
  SetLength(_Data, 0);
End;

End.


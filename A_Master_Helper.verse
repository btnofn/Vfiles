<#
====================================================================================================
Copyright (c) 2024 MapAcademy. All rights reserved.

 

This software and its associated documentation files (the "Software") are the

proprietary property of MapAcademy and are protected by copyright law.

 

The Software is provided to you under the terms of the MapAcademy End User

License Agreement (the "License"). You may use, copy, distribute, and modify

the Software solely in accordance with the terms of the License.

 

BY USING THE SOFTWARE, YOU AGREE TO BE BOUND BY THE TERMS OF THE LICENSE.

IF YOU DO NOT AGREE TO THE TERMS OF THE LICENSE, DO NOT USE THE SOFTWARE.

 

The Software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND,

either express or implied, including without limitation any warranties of

MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, or NON-INFRINGEMENT.

For more details, please refer to the MapAcademy End User License Agreement.
====================================================================================================
#>
using { /Verse.org/Simulation }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }

#UI Helper Classes =========================================================================================================================================================
#A custom class that allows for creation of canvas slots within a creative device
CanvasPosition:= class<concrete>():
    @editable AnchorX : type{_X : float where _X >= 0.0, _X <= 1.0} = 0.0
    @editable AnchorY : type{_X : float where _X >= 0.0, _X <= 1.0} = 0.0
    @editable Left : float = 0.0
    @editable Top : float = 0.0
    @editable Right : float = 0.0
    @editable Bottom : float = 0.0
    @editable Allignment : vector2 = vector2{}
    @editable ZOrder : type{_X : int where _X >= 0, _X <= 2147483647} = 0
    MaybeLeft : ?float = false
    MaybeTop : ?float = false
    MaybeRight : ?float = false
    MaybeBottom : ?float = false
    MaybeAllignment : ?vector2 = false
    MaybeZOrder : ?type{_X : int where _X >= 0, _X <= 2147483647} = false

    #Function to create and return a new canvas slot using the Canvas Positions settings
    MakeCanvasSlot(Widget : widget , MaybePos : ?CanvasPosition) : canvas_slot=
        var FinalLeft : float = Left
        var FinalTop : float = Top
        var FinalRight : float = Right
        var FinalBottom : float = Bottom
        var FinalAllignment : vector2 = Allignment
        var FinalZOrder : type{_X : int where _X >= 0, _X <= 2147483647} = ZOrder
        if(UpdatedPos := MaybePos?):
            if(NewLeft := UpdatedPos.MaybeLeft?){set FinalLeft = NewLeft}
            if(NewRight := UpdatedPos.MaybeRight?){set FinalRight = NewRight}
            if(NewTop := UpdatedPos.MaybeTop?){set FinalTop = NewTop}
            if(NewBottom := UpdatedPos.MaybeBottom?){set FinalBottom = NewBottom}
            if(NewAllignment := UpdatedPos.MaybeAllignment?){set FinalAllignment = NewAllignment}
            if(NewZOrder := UpdatedPos.MaybeZOrder?){set FinalZOrder = NewZOrder}
        canvas_slot:
            Anchors := anchors{Minimum := vector2{X := AnchorX,Y := AnchorY},Maximum := vector2{X := AnchorX,Y := AnchorY}}
            Offsets := margin{Left := FinalLeft , Top := FinalTop , Right := FinalRight , Bottom := FinalBottom}
            SizeToContent := false
            Alignment := FinalAllignment
            ZOrder := FinalZOrder
            Widget := Widget

    GetMargin(MaybeMargin : ?CustomMargin) : margin=
        var FinalLeft : float = Left
        var FinalTop : float = Top
        var FinalRight : float = Right
        var FinalBottom : float = Bottom
        if(UpdatedPos := MaybeMargin?):
            if(NewLeft := UpdatedPos.MaybeLeft?){set FinalLeft = NewLeft}
            if(NewRight := UpdatedPos.MaybeRight?){set FinalRight = NewRight}
            if(NewTop := UpdatedPos.MaybeTop?){set FinalTop = NewTop}
            if(NewBottom := UpdatedPos.MaybeBottom?){set FinalBottom = NewBottom}
        margin{
            Left := FinalLeft
            Top := FinalTop
            Right := FinalRight
            Bottom := FinalBottom
        }

    GetCanvas(MaybeCanvas : ?CanvasPosition) : CanvasPosition=
        var FinalLeft : float = Left
        var FinalTop : float = Top
        var FinalRight : float = Right
        var FinalBottom : float = Bottom
        var FinalAllignment : vector2 = Allignment
        var FinalZOrder : type{_X : int where _X >= 0, _X <= 2147483647} = ZOrder
        if(UpdatedPos := MaybeCanvas?):
            if(NewLeft := UpdatedPos.MaybeLeft?){set FinalLeft = NewLeft}
            if(NewRight := UpdatedPos.MaybeRight?){set FinalRight = NewRight}
            if(NewTop := UpdatedPos.MaybeTop?){set FinalTop = NewTop}
            if(NewBottom := UpdatedPos.MaybeBottom?){set FinalBottom = NewBottom}
            if(NewAllignment := UpdatedPos.MaybeAllignment?){set FinalAllignment = NewAllignment}
            if(NewZOrder := UpdatedPos.MaybeZOrder?){set FinalZOrder = NewZOrder}
        CanvasPosition:
            AnchorX := AnchorX
            AnchorY := AnchorY
            Left := FinalLeft
            Top := FinalTop
            Right := FinalRight
            Bottom := FinalBottom
            Allignment := FinalAllignment
            ZOrder := FinalZOrder

CustomMargin := class():
    MaybeLeft : ?float = false
    MaybeTop : ?float = false
    MaybeRight : ?float = false
    MaybeBottom : ?float = false






CanvasButtonWidget := class<concrete>(BaseButtonWidget) : 
    @editable Position : CanvasPosition = CanvasPosition{}

CanvasTextWidget := class<concrete>(BaseTextWidget) : 
    @editable Position : CanvasPosition = CanvasPosition{}

CanvasImageWidget := class<concrete>(BaseImageWidget) : 
    @editable Position : CanvasPosition = CanvasPosition{}
    
BaseButtonWidget := class<concrete>():
    @editable ButtonType : UIButtonType = UIButtonType.Loud
    @editable ButtonText : string = ""

    #Creates and returns a button widget
    GetNewWidget(Agent : agent) : text_button_base =
        var AllButtons : UIAllButtons = UIAllButtons{}
        NewButton := AllButtons.GetButton(ButtonType)
        NewButton.SetText(MasterS2M(ButtonText))
        return NewButton

#Text Widget Class
BaseTextWidget:= class<concrete>():
    @editable TextMessage : string = ""
    @editable TextJustification : text_justification = text_justification.Left
    @editable TextColor : color = White
    @editable TextOpacity : type{_X : float where _X >= 0.0, _X <= 1.0} = 1.0
    @editable TextShadowColor : color = color{}
    @editable TextShadowOffset : vector2 = vector2{X:= 1.0 , Y:= 1.0}
    @editable TextShadowOpacity : type{_X : float where _X >= 0.0, _X <= 1.0} = 1.0

    #Creates and returns a text widget
    GetNewWidget() : text_block =
        var TW : text_block = text_block{
            DefaultText := MasterS2M(TextMessage)
            DefaultTextColor := TextColor
            DefaultTextOpacity := TextOpacity
            DefaultShadowColor := TextShadowColor
            DefaultShadowOffset := option{TextShadowOffset}
            DefaultShadowOpacity := TextShadowOpacity
            DefaultJustification := TextJustification
        }
        return TW

#Text Widget Class
BaseColorWidget:= class<concrete>():
    @editable DefaultColor : color = color{}
    @editable DefaultOpacity : type{_X : float where _X >= 0.0, _X <= 1.0} = 1.0

    #Creates and returns a text widget
    GetNewWidget() : color_block =
        var CW : color_block = color_block{
            DefaultColor := DefaultColor
            DefaultOpacity := DefaultOpacity
        }
        return CW

#Image Widget Class
BaseImageWidget := class<concrete>():
    #Add Images Here
    #======================================================================================================================================================
    var AllImages : []texture = array{}
    #======================================================================================================================================================
    @editable ImageIDX : int = 0
    @editable ImageTint : color = White

    #Creates and returns an image widget
    GetNewWidget() : texture_block =
        var IW : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder , DefaultTint := ImageTint}
        if(NewImage := AllImages[ImageIDX]){IW.SetImage(NewImage)}
        return IW


#Class that contains multiple buttons that is used to change which button appears
UIAllButtons := class<concrete>():
    var LoudButton : button_loud = button_loud{}
    var QuietButton : button_quiet = button_quiet{}
    var RegularButton : button_regular = button_regular{}

    GetButton(Type : UIButtonType) : text_button_base=
        if(Type = UIButtonType.Loud):
            return LoudButton

        else if(Type = UIButtonType.Regular):
            return RegularButton

        else if(Type = UIButtonType.Quiet):
            return QuietButton

        return LoudButton

#List of different button types
UIButtonType := enum:
    Loud
    Regular
    Quiet




MoveWidgetPosition(MovedWidget : widget , RootWidget : canvas, CurrentPosition : CanvasPosition , NewOffsets : margin , Time : float)<suspends> : CanvasPosition=
    NewCanvasPosition := CanvasPosition{
        AnchorX := CurrentPosition.AnchorX
        AnchorY := CurrentPosition.AnchorY
        Left := NewOffsets.Left
        Top := NewOffsets.Top
        Right := NewOffsets.Right
        Bottom := NewOffsets.Bottom
        Allignment := CurrentPosition.Allignment
        ZOrder := CurrentPosition.ZOrder
    }

    var ScaleXStackbox : stack_box = stack_box{Orientation := orientation.Horizontal}
    var ScaleYStackbox : stack_box = stack_box{Orientation := orientation.Horizontal}

    var PositionXStackbox : stack_box = stack_box{Orientation := orientation.Horizontal}
    var PositionYStackbox : stack_box = stack_box{Orientation := orientation.Vertical}


    var NotXScaleMover : color_block = color_block{DefaultOpacity := 0.0 , DefaultDesiredSize := vector2{X:= 0.0, Y:= 0.0}}
    var YScaleMover : color_block = color_block{DefaultOpacity := 0.0}
    
    var XPositionMover : color_block = color_block{DefaultOpacity := 0.0}
    var YPositionMoverPlusXScaleMover : color_block = color_block{DefaultOpacity := 0.0}

    if(ToTextureBlock := texture_block[MovedWidget]):
        ToTextureBlock.SetDesiredSize(vector2{X:= 0.0, Y:= 0.0})
    else if(ToColorBlock := color_block[MovedWidget]):
        ToColorBlock.SetDesiredSize(vector2{X:= 0.0, Y:= 0.0})


    XScaleDifference : float = Abs(NewOffsets.Right) - Abs(CurrentPosition.Right)
    YScaleDifference : float = Abs(NewOffsets.Bottom) - Abs(CurrentPosition.Bottom)


    var XScaleValue : float = Abs(CurrentPosition.Right)
    var YScaleValue : float = Abs(CurrentPosition.Bottom)
    XScaleMovementAmount := ((XScaleDifference/Time)/30.0)
    YScaleMovementAmount := ((YScaleDifference/Time)/30.0)


    var XPosValue : float = XScaleDifference * CurrentPosition.Allignment.X
    var YPosValue : float = YScaleDifference * CurrentPosition.Allignment.Y

    XCorrectionMovementAmount := (((XPosValue)/Time) / 30.0)
    YCorrectionMovementAmount := (((YPosValue)/Time) / 30.0)



    XMovementDifference := (NewOffsets.Left - CurrentPosition.Left) * -1.0
    YMovementDifference := (NewOffsets.Top - CurrentPosition.Top) * -1.0

    XMovementAmount := (((XMovementDifference)/Time) / 30.0)
    YMovementAmount := (((YMovementDifference)/Time) / 30.0)



    YPositionMoverPlusXScaleMover.SetDesiredSize(vector2{X:=XScaleValue, Y:= YPosValue})
    YScaleMover.SetDesiredSize(vector2{X:=0.0, Y:= YScaleValue})
    XPositionMover.SetDesiredSize(vector2{X:=XPosValue, Y:= 0.0})

    ScaleXStackbox.AddWidget(stack_box_slot{Widget := MovedWidget , HorizontalAlignment := horizontal_alignment.Fill , VerticalAlignment := vertical_alignment.Fill , Distribution := option{1.0}})
    ScaleXStackbox.AddWidget(stack_box_slot{Widget := NotXScaleMover , HorizontalAlignment := horizontal_alignment.Fill , VerticalAlignment := vertical_alignment.Fill})

    ScaleYStackbox.AddWidget(stack_box_slot{Widget := YScaleMover , HorizontalAlignment := horizontal_alignment.Fill , VerticalAlignment := vertical_alignment.Fill})
    ScaleYStackbox.AddWidget(stack_box_slot{Widget := ScaleXStackbox , HorizontalAlignment := horizontal_alignment.Fill , VerticalAlignment := vertical_alignment.Fill , Distribution := option{1.0}})


    PositionYStackbox.AddWidget(stack_box_slot{Widget := YPositionMoverPlusXScaleMover , HorizontalAlignment := horizontal_alignment.Fill , VerticalAlignment := vertical_alignment.Fill})
    PositionYStackbox.AddWidget(stack_box_slot{Widget := ScaleYStackbox , HorizontalAlignment := horizontal_alignment.Fill , VerticalAlignment := vertical_alignment.Fill})

    PositionXStackbox.AddWidget(stack_box_slot{Widget := XPositionMover , HorizontalAlignment := horizontal_alignment.Fill , VerticalAlignment := vertical_alignment.Fill})
    PositionXStackbox.AddWidget(stack_box_slot{Widget := PositionYStackbox , HorizontalAlignment := horizontal_alignment.Fill , VerticalAlignment := vertical_alignment.Fill})



    RootWidget.AddWidget(CurrentPosition.MakeCanvasSlot(PositionXStackbox , option{CanvasPosition{MaybeRight := option{NewOffsets.Right} , MaybeBottom := option{NewOffsets.Bottom}}}))


    race:
        block:
            Sleep(Time)
            YScaleMover.SetVisibility(widget_visibility.Hidden)
            XPositionMover.SetVisibility(widget_visibility.Hidden)
            YPositionMoverPlusXScaleMover.SetVisibility(widget_visibility.Hidden)
            NotXScaleMover.SetVisibility(widget_visibility.Hidden)
            return NewCanvasPosition
        loop:
            Sleep(0.0)
            set XScaleValue += XScaleMovementAmount
            set YScaleValue += YScaleMovementAmount
            
            set XPosValue -= (XCorrectionMovementAmount + XMovementAmount)
            set YPosValue -= (YCorrectionMovementAmount + YMovementAmount)


            YScaleMover.SetDesiredSize(vector2{X:=0.0, Y:= YScaleValue})

            XPositionMover.SetDesiredSize(vector2{X:=XPosValue, Y:= 0.0})

            YPositionMoverPlusXScaleMover.SetDesiredSize(vector2{X:=XScaleValue, Y:= YPosValue})

    

    Print("Return")
    return NewCanvasPosition
    

# Returns the same map with the provided index removed, returns option{false} otherwise
(Input:[t]u where t:subtype(comparable), u:type).WithRemovedKey(KeyToRemove:t)<transacts>:?[t]u = 
    var NewMap:[t]u = map{}
    var FoundIndex:logic = false
    
    for (Key -> Value : Input):
        if(Key = KeyToRemove):
            set FoundIndex = true
        else:
            set NewMap = ConcatenateMaps(NewMap, map{Key => Value})

    if(FoundIndex?) then option{NewMap} else (__ :?[t]u = false)

#Localize Classes =============================================================================================================================================================

#Converts a values to agents to a message
MasterS2M<localizes>(String : string) : message = "{String}"
MasterA2M<localizes>(Agent : agent) : message = "{Agent}"

#Used to round amounts, cut off decimal placs, and add Prefix/Suffixs
RoundedAmount(Prefix : string , Input:float, Decimals:int , Suffix : string) : message = {
    var NumEnder : string = ""
    var MainSuffix : string = ""
    var NewInput : float = 0.0

    
    if(Input >= 10000.0 and Input < 1000000.0):
        set NumEnder = "K"
        set NewInput = (Input / 1000.0)
    else if(Input >= 1000000.0 and Input < 1000000000.0):
        set NumEnder = "M"
        set NewInput = (Input / 1000000.0)
    else if(Input >= 1000000000.0 and Input < 1000000000000.0):
        set NumEnder = "B"
        set NewInput = (Input / 1000000000.0)
    else if(Input >= 1000000000000.0):
        set NumEnder = "T"
        set NewInput = (Input / 1000000000000.0)
    else:
        set NewInput = Input

    set MainSuffix = Suffix

    var String : []char = ToString(NewInput)
    var Zeros : string = "00000000"
    
    if (DotIndex := String.Find['.']):
        StopIndex := if (Decimals > 0) { Min(DotIndex+Decimals+1,String.Length) } else { DotIndex }

        if(AfterDecimal := String.Slice[DotIndex+1,DotIndex+Decimals+1] , NewZeros := Zeros.Slice[0,Decimals]):
            if(AfterDecimal = NewZeros):
                if (FinalString := String.Slice[0, DotIndex]):
                    return MasterS2M("{Prefix}{FinalString}{NumEnder}{MainSuffix}")
            else:
                if (FinalString := String.Slice[0, StopIndex]):
                    return MasterS2M("{Prefix}{FinalString}{NumEnder}{MainSuffix}")
    
    return MasterS2M("0")
    }


#Different interpolation types used for keyframes
CustomInterpTypes := enum:
    InterpLinear
    InterpEase
    InterpEaseIn
    InterpEaseOut
    InterpEaseInOut

#Returns a built in interpolation type based off of the selected type from the custom enum
GetInterpType(CustomInterpType : CustomInterpTypes) : cubic_bezier_parameters=
    if(CustomInterpType = CustomInterpTypes.InterpLinear){return Linear}
    if(CustomInterpType = CustomInterpTypes.InterpEase){return Ease}
    if(CustomInterpType = CustomInterpTypes.InterpEaseIn){return EaseIn}
    if(CustomInterpType = CustomInterpTypes.InterpEaseOut){return EaseOut}
    if(CustomInterpType = CustomInterpTypes.InterpEaseInOut){return EaseInOut}
    return Linear

#Function that moves a prop to a location using animation controller
(InProp:creative_prop).ACMoveToLocation(Location : vector3 , Rotation: rotation, Scale : vector3, Time : float , CustomInterpType : CustomInterpTypes)<suspends> : void =
    InterpType := GetInterpType(CustomInterpType)
    MovementKeyFrame : keyframe_delta = keyframe_delta
    {
        DeltaLocation := (Location)
        DeltaRotation := Rotation
        DeltaScale := (Scale)
        Time := Time
        Interpolation := InterpType
    } 
    if (AController := InProp.GetAnimationController[]):
        KeyFrames:[]keyframe_delta = array { MovementKeyFrame }
        AController.SetAnimation(KeyFrames, ?Mode:=animation_mode.OneShot)
        AController.Play()
    Sleep(Time)
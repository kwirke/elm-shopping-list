module Ui.TextInput exposing (ChapterModel, TextInputProps, chapterInitialState, docs, textInputView)

import Css exposing (..)
import Css.Animations as Animations
import DesignSystem.ColorDecisions exposing (activeButtonTextColor, glassButtonGlowingBoxShadowColor, inputTextColor, inputTextColorGlow)
import DesignSystem.Colors exposing (..)
import DesignSystem.Sizes exposing (cardBorderRadius, cardBoxShadow, cardMargins, cardTextShadow, itemFontSize)
import DesignSystem.StyledIcons exposing (blueChevron, blueX)
import ElmBook
import ElmBook.Actions exposing (logAction, updateStateWith)
import ElmBook.Chapter exposing (chapter, renderComponent, renderComponentList, renderStatefulComponent, renderStatefulComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Html.Attributes exposing (placeholder)
import Html.Styled exposing (Html, a, button, div, input)
import Html.Styled.Attributes as HtmlAttr exposing (css)
import Html.Styled.Events as HtmlEvt
import Svg.Styled.Attributes exposing (x)
import Ui.Glassmorphism exposing (glassmorphism)
import Ui.StyleResets exposing (resetButtonStyles)


type alias TextInputProps msg =
    { value : String
    , onInput : String -> msg
    , attributes : List (Html.Styled.Attribute msg)
    , hasError : Bool
    }


cardBackground : Bool -> Style
cardBackground hasError =
    let
        choose : a -> a -> a
        choose a b =
            if hasError then
                a

            else
                b
    in
    Css.batch
        [ glassmorphism
            { color = choose red accentBlue.s800
            , opacityPct = choose 20 0
            , blurPx = 12
            , saturationPct = 0
            }
        , pseudoClass "focus-within"
            [ glassmorphism
                { color = choose red accentBlue.s750
                , opacityPct = choose 30 50
                , blurPx = 12
                , saturationPct = 50
                }
            ]
        ]


textInputCardStyles : Style -> List Style
textInputCardStyles glass =
    [ displayFlex
    , width (pct 100)
    , height (px 30)
    , alignItems center
    , borderRadius cardBorderRadius
    , cardBoxShadow (hex glassButtonGlowingBoxShadowColor)
    , cardMargins
    , padding2 (px 5) (px 10)
    , glass
    ]


blinking =
    Animations.keyframes
        [ ( 0, [ Animations.opacity (int 1) ] )
        , ( 50, [ Animations.opacity (int 1) ] )
        , ( 51, [ Animations.opacity (int 0) ] )
        , ( 100, [ Animations.opacity (int 0) ] )
        ]


blinkingAnimation : Bool -> Style
blinkingAnimation isEmpty =
    Css.batch
        (if isEmpty then
            [ animationName blinking
            , animationDuration (sec 1)
            , animationIterationCount infinite
            ]

         else
            []
        )


textInputStyles : Bool -> List Style
textInputStyles isEmpty =
    [ displayFlex
    , width (pct 100)
    , fontSize itemFontSize
    , textIndent (px 2) -- avoid text shadow clipping
    , borderStyle none
    , backgroundColor transparent
    , color (hex inputTextColor)
    , cardTextShadow (hex inputTextColorGlow)
    , outline none
    , blinkingAnimation isEmpty
    , pseudoElement "placeholder"
        [ color (hex inputTextColor)
        ]
    ]


iconOverInputStyle : Style
iconOverInputStyle =
    zIndex (int 1)


widthContainer : List (Html msg) -> Html msg
widthContainer kids =
    div
        [ css [ displayFlex, width (pct 100) ] ]
        kids


textInputView : TextInputProps msg -> Html msg
textInputView { value, onInput, attributes, hasError } =
    let
        resetInput =
            onInput ""

        isEmpty =
            value == ""

        cardStyles =
            textInputCardStyles (cardBackground hasError)
    in
    widthContainer
        [ div
            [ css cardStyles ]
            [ blueChevron iconOverInputStyle
            , input
                (attributes
                    ++ [ css (textInputStyles isEmpty)
                       , HtmlEvt.onInput onInput
                       , HtmlAttr.value value
                       , HtmlAttr.placeholder "_"
                       ]
                )
                []
            , button
                [ css (resetButtonStyles ++ [ displayFlex ])
                , HtmlEvt.onClick resetInput
                , HtmlAttr.type_ "button"
                ]
                [ blueX iconOverInputStyle ]
            ]
        ]



-- DOCS


type alias ChapterModel =
    String


type alias SharedState x =
    { x | textInputModel : ChapterModel }


chapterInitialState : ChapterModel
chapterInitialState =
    ""


updateChapterState : String -> SharedState x -> SharedState x
updateChapterState val x =
    { x | textInputModel = val }


docs : Chapter (SharedState x)
docs =
    chapter "TextInput"
        |> renderStatefulComponentList
            [ ( "Default"
              , \{ textInputModel } ->
                    textInputView
                        { value = textInputModel
                        , onInput = updateStateWith updateChapterState
                        , attributes = []
                        , hasError = False
                        }
              )
            , ( "With error"
              , \{ textInputModel } ->
                    textInputView
                        { value = textInputModel
                        , onInput = updateStateWith updateChapterState
                        , attributes = []
                        , hasError = True
                        }
              )
            ]

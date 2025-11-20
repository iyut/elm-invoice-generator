port module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Json.Encode as Encode


-- MAIN

main : Program (Maybe String) Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


-- MODEL

type alias Model =
    { invoice : Invoice
    , currency : String
    }

type alias Invoice =
    { -- Company Info
      companyName : String
    , companyEmail : String
    , companyAddress : String
    , companyPhone : String
    , logoUrl : Maybe String

    -- Customer Info (Bill To)
    , customerName : String
    , customerEmail : String
    , customerAddress : String

    -- Ship To Info
    , shipToName : String
    , shipToEmail : String
    , shipToAddress : String

    -- Invoice Details
    , invoiceNumber : String
    , invoiceDate : String
    , dueDate : String

    -- Line Items
    , items : List LineItem

    -- Additional Charges
    , taxRate : Float
    , discount : Float
    , shipping : Float

    -- Notes
    , notes : String
    }

type alias LineItem =
    { id : Int
    , description : String
    , quantity : Float
    , rate : Float
    }

init : Maybe String -> ( Model, Cmd Msg )
init maybeStoredData =
    case maybeStoredData of
        Just jsonString ->
            case Decode.decodeString invoiceDecoder jsonString of
                Ok invoice ->
                    ( { invoice = invoice, currency = "USD" }, Cmd.none )

                Err _ ->
                    ( initialModel, Cmd.none )

        Nothing ->
            ( initialModel, Cmd.none )

initialModel : Model
initialModel =
    { invoice = initialInvoice
    , currency = "USD"
    }

initialInvoice : Invoice
initialInvoice =
    { companyName = ""
    , companyEmail = ""
    , companyAddress = ""
    , companyPhone = ""
    , logoUrl = Nothing
    , customerName = ""
    , customerEmail = ""
    , customerAddress = ""
    , shipToName = ""
    , shipToEmail = ""
    , shipToAddress = ""
    , invoiceNumber = "INV-001"
    , invoiceDate = ""
    , dueDate = ""
    , items = [ LineItem 1 "" 1 0 ]
    , taxRate = 0
    , discount = 0
    , shipping = 0
    , notes = ""
    }


-- UPDATE

type Msg
    = UpdateCompanyName String
    | UpdateCompanyEmail String
    | UpdateCompanyAddress String
    | UpdateCompanyPhone String
    | UpdateCustomerName String
    | UpdateCustomerEmail String
    | UpdateCustomerAddress String
    | UpdateShipToName String
    | UpdateShipToEmail String
    | UpdateShipToAddress String
    | UpdateInvoiceNumber String
    | UpdateInvoiceDate String
    | UpdateDueDate String
    | UpdateItemDescription Int String
    | UpdateItemQuantity Int String
    | UpdateItemRate Int String
    | AddItem
    | RemoveItem Int
    | UpdateTaxRate String
    | UpdateDiscount String
    | UpdateShipping String
    | UpdateNotes String
    | UpdateCurrency String
    | SaveInvoice
    | DownloadPDF
    | RequestLogoUpload
    | LogoSelected String
    | RemoveLogo

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateCompanyName value ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | companyName = value }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateCompanyEmail value ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | companyEmail = value }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateCompanyAddress value ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | companyAddress = value }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateCompanyPhone value ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | companyPhone = value }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateCustomerName value ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | customerName = value }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateCustomerEmail value ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | customerEmail = value }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateCustomerAddress value ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | customerAddress = value }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateShipToName value ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | shipToName = value }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateShipToEmail value ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | shipToEmail = value }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateShipToAddress value ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | shipToAddress = value }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateInvoiceNumber value ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | invoiceNumber = value }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateInvoiceDate value ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | invoiceDate = value }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateDueDate value ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | dueDate = value }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateItemDescription id value ->
            let
                invoice = model.invoice
                updatedItems =
                    List.map
                        (\item ->
                            if item.id == id then
                                { item | description = value }
                            else
                                item
                        )
                        invoice.items
                updatedInvoice = { invoice | items = updatedItems }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateItemQuantity id value ->
            let
                invoice = model.invoice
                quantity = String.toFloat value |> Maybe.withDefault 0
                updatedItems =
                    List.map
                        (\item ->
                            if item.id == id then
                                { item | quantity = quantity }
                            else
                                item
                        )
                        invoice.items
                updatedInvoice = { invoice | items = updatedItems }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateItemRate id value ->
            let
                invoice = model.invoice
                rate = String.toFloat value |> Maybe.withDefault 0
                updatedItems =
                    List.map
                        (\item ->
                            if item.id == id then
                                { item | rate = rate }
                            else
                                item
                        )
                        invoice.items
                updatedInvoice = { invoice | items = updatedItems }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        AddItem ->
            let
                invoice = model.invoice
                newId = (List.length invoice.items) + 1
                newItem = LineItem newId "" 1 0
                updatedInvoice = { invoice | items = invoice.items ++ [ newItem ] }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        RemoveItem id ->
            let
                invoice = model.invoice
                updatedItems = List.filter (\item -> item.id /= id) invoice.items
                updatedInvoice = { invoice | items = updatedItems }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateTaxRate value ->
            let
                invoice = model.invoice
                taxRate = String.toFloat value |> Maybe.withDefault 0
                updatedInvoice = { invoice | taxRate = taxRate }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateDiscount value ->
            let
                invoice = model.invoice
                discount = String.toFloat value |> Maybe.withDefault 0
                updatedInvoice = { invoice | discount = discount }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateShipping value ->
            let
                invoice = model.invoice
                shipping = String.toFloat value |> Maybe.withDefault 0
                updatedInvoice = { invoice | shipping = shipping }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateNotes value ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | notes = value }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        UpdateCurrency value ->
            ( { model | currency = value }, Cmd.none )

        SaveInvoice ->
            ( model, saveToLocalStorage (encodeInvoice model.invoice) )

        DownloadPDF ->
            ( model, downloadPDF () )

        RequestLogoUpload ->
            ( model, requestLogoUpload () )

        LogoSelected logoData ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | logoUrl = Just logoData }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )

        RemoveLogo ->
            let
                invoice = model.invoice
                updatedInvoice = { invoice | logoUrl = Nothing }
            in
            ( { model | invoice = updatedInvoice }, Cmd.none )


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ =
    logoSelected LogoSelected


-- VIEW

view : Model -> Html Msg
view model =
    div [ class "app-container" ]
        [ viewActionToolbar model
        , viewEditableInvoice model
        ]

viewActionToolbar : Model -> Html Msg
viewActionToolbar model =
    div [ class "action-toolbar" ]
        [ div [ class "toolbar-title" ] [ text "Invoice Generator" ]
        , button [ onClick SaveInvoice, class "btn-save" ] [ text "Save" ]
        , button [ onClick DownloadPDF, class "btn-download-pdf" ] [ text "Download PDF" ]
        ]

viewEditableInvoice : Model -> Html Msg
viewEditableInvoice model =
    let
        subtotal = calculateSubtotal model.invoice.items
        taxAmount = subtotal * (model.invoice.taxRate / 100)
        total = subtotal + taxAmount - model.invoice.discount + model.invoice.shipping
    in
    div [ class "invoice-container" ]
        [ h1 [ class "invoice-title" ] [ text "INVOICE" ]

        -- Header with company logo and info
        , div [ class "invoice-header" ]
            [ div [ class "company-info" ]
                [ case model.invoice.logoUrl of
                    Just logoData ->
                        div [ class "logo-upload-container" ]
                            [ img
                                [ src logoData
                                , class "company-logo-editable"
                                , onClick RequestLogoUpload
                                , title "Click to change logo"
                                ]
                                []
                            , button
                                [ onClick RemoveLogo
                                , class "btn-remove-logo-inline"
                                , title "Remove logo"
                                ]
                                [ text "×" ]
                            ]

                    Nothing ->
                        div
                            [ class "logo-upload-placeholder"
                            , onClick RequestLogoUpload
                            ]
                            [ text "+ Add Logo" ]
                , h2 []
                    [ input
                        [ class "inline-input"
                        , placeholder "Your Company Name"
                        , value model.invoice.companyName
                        , onInput UpdateCompanyName
                        , style "font-size" "20px"
                        , style "font-weight" "600"
                        ]
                        []
                    ]
                , p []
                    [ input
                        [ class "inline-input"
                        , placeholder "email@company.com"
                        , value model.invoice.companyEmail
                        , onInput UpdateCompanyEmail
                        ]
                        []
                    ]
                , p []
                    [ input
                        [ class "inline-input"
                        , placeholder "Phone Number"
                        , value model.invoice.companyPhone
                        , onInput UpdateCompanyPhone
                        ]
                        []
                    ]
                , p [ class "address" ]
                    [ textarea
                        [ class "inline-textarea"
                        , placeholder "Company Address"
                        , value model.invoice.companyAddress
                        , onInput UpdateCompanyAddress
                        , rows 2
                        ]
                        []
                    ]
                ]
            , div [ class "invoice-meta" ]
                [ div []
                    [ strong [] [ text "Invoice #: " ]
                    , input
                        [ class "inline-input"
                        , value model.invoice.invoiceNumber
                        , onInput UpdateInvoiceNumber
                        , style "width" "120px"
                        , style "display" "inline-block"
                        ]
                        []
                    ]
                , div []
                    [ strong [] [ text "Date: " ]
                    , input
                        [ class "inline-input"
                        , type_ "date"
                        , value model.invoice.invoiceDate
                        , onInput UpdateInvoiceDate
                        , style "width" "150px"
                        , style "display" "inline-block"
                        ]
                        []
                    ]
                , div []
                    [ strong [] [ text "Due Date: " ]
                    , input
                        [ class "inline-input"
                        , type_ "date"
                        , value model.invoice.dueDate
                        , onInput UpdateDueDate
                        , style "width" "150px"
                        , style "display" "inline-block"
                        ]
                        []
                    ]
                , div []
                    [ strong [] [ text "Currency: " ]
                    , select
                        [ onInput UpdateCurrency
                        , style "width" "80px"
                        , style "display" "inline-block"
                        ]
                        [ option [ value "USD" ] [ text "USD" ]
                        , option [ value "EUR" ] [ text "EUR" ]
                        , option [ value "GBP" ] [ text "GBP" ]
                        , option [ value "IDR" ] [ text "IDR" ]
                        , option [ value "JPY" ] [ text "JPY" ]
                        ]
                    ]
                ]
            ]

        -- Customer Info (Bill To and Ship To)
        , div [ class "customer-shipping-section" ]
            [ div [ class "customer-section" ]
                [ h3 [] [ text "Bill To:" ]
                , p []
                    [ input
                        [ class "inline-input"
                        , placeholder "Customer Name"
                        , value model.invoice.customerName
                        , onInput UpdateCustomerName
                        ]
                        []
                    ]
                , p []
                    [ input
                        [ class "inline-input"
                        , placeholder "customer@email.com"
                        , value model.invoice.customerEmail
                        , onInput UpdateCustomerEmail
                        ]
                        []
                    ]
                , p [ class "address" ]
                    [ textarea
                        [ class "inline-textarea"
                        , placeholder "Customer Address"
                        , value model.invoice.customerAddress
                        , onInput UpdateCustomerAddress
                        , rows 2
                        ]
                        []
                    ]
                ]
            , div [ class "shipping-section" ]
                [ h3 [] [ text "Ship To:" ]
                , p []
                    [ input
                        [ class "inline-input"
                        , placeholder "Recipient Name"
                        , value model.invoice.shipToName
                        , onInput UpdateShipToName
                        ]
                        []
                    ]
                , p []
                    [ input
                        [ class "inline-input"
                        , placeholder "recipient@email.com"
                        , value model.invoice.shipToEmail
                        , onInput UpdateShipToEmail
                        ]
                        []
                    ]
                , p [ class "address" ]
                    [ textarea
                        [ class "inline-textarea"
                        , placeholder "Shipping Address"
                        , value model.invoice.shipToAddress
                        , onInput UpdateShipToAddress
                        , rows 2
                        ]
                        []
                    ]
                ]
            ]

        -- Items Table
        , table [ class "invoice-table" ]
            [ thead []
                [ tr []
                    [ th [] [ text "Description" ]
                    , th [] [ text "Quantity" ]
                    , th [] [ text "Rate" ]
                    , th [] [ text "Amount" ]
                    , th [] [ text "" ]
                    ]
                ]
            , tbody []
                (List.map (viewEditableItemRow model.currency) model.invoice.items)
            ]
        , button [ onClick AddItem, class "btn-add" ] [ text "+ Add Item" ]

        -- Totals
        , div [ class "invoice-totals" ]
            [ div [ class "total-row" ]
                [ span [] [ text "Subtotal:" ]
                , span [] [ text (formatCurrency model.currency subtotal) ]
                ]
            , div [ class "total-row" ]
                [ span []
                    [ text "Tax ("
                    , input
                        [ class "inline-input"
                        , type_ "number"
                        , placeholder "0"
                        , value (String.fromFloat model.invoice.taxRate)
                        , onInput UpdateTaxRate
                        , style "width" "50px"
                        , style "display" "inline-block"
                        , style "text-align" "right"
                        ]
                        []
                    , text "%):"
                    ]
                , span [] [ text (formatCurrency model.currency taxAmount) ]
                ]
            , if model.invoice.discount > 0 then
                div [ class "total-row" ]
                    [ span []
                        [ text "Discount: "
                        , input
                            [ class "inline-input"
                            , type_ "number"
                            , placeholder "0"
                            , value (String.fromFloat model.invoice.discount)
                            , onInput UpdateDiscount
                            , style "width" "80px"
                            , style "display" "inline-block"
                            ]
                            []
                        ]
                    , span [] [ text ("-" ++ formatCurrency model.currency model.invoice.discount) ]
                    ]

              else
                div [ class "total-row" ]
                    [ span []
                        [ text "Discount: "
                        , input
                            [ class "inline-input"
                            , type_ "number"
                            , placeholder "0"
                            , value ""
                            , onInput UpdateDiscount
                            , style "width" "80px"
                            , style "display" "inline-block"
                            ]
                            []
                        ]
                    , span [] [ text (formatCurrency model.currency 0) ]
                    ]
            , if model.invoice.shipping > 0 then
                div [ class "total-row" ]
                    [ span []
                        [ text "Shipping: "
                        , input
                            [ class "inline-input"
                            , type_ "number"
                            , placeholder "0"
                            , value (String.fromFloat model.invoice.shipping)
                            , onInput UpdateShipping
                            , style "width" "80px"
                            , style "display" "inline-block"
                            ]
                            []
                        ]
                    , span [] [ text (formatCurrency model.currency model.invoice.shipping) ]
                    ]

              else
                div [ class "total-row" ]
                    [ span []
                        [ text "Shipping: "
                        , input
                            [ class "inline-input"
                            , type_ "number"
                            , placeholder "0"
                            , value ""
                            , onInput UpdateShipping
                            , style "width" "80px"
                            , style "display" "inline-block"
                            ]
                            []
                        ]
                    , span [] [ text (formatCurrency model.currency 0) ]
                    ]
            , div [ class "total-row total-final" ]
                [ span [] [ text "Total:" ]
                , span [] [ text (formatCurrency model.currency total) ]
                ]
            ]

        -- Notes
        , div [ class "invoice-notes" ]
            [ h3 [] [ text "Notes:" ]
            , p []
                [ textarea
                    [ class "inline-textarea"
                    , placeholder "Payment terms, thank you message, or other notes"
                    , value model.invoice.notes
                    , onInput UpdateNotes
                    , rows 3
                    ]
                    []
                ]
            ]
        ]

viewEditableItemRow : String -> LineItem -> Html Msg
viewEditableItemRow currency item =
    let
        amount = item.quantity * item.rate
    in
    tr []
        [ td []
            [ input
                [ class "inline-input"
                , placeholder "Item description"
                , value item.description
                , onInput (UpdateItemDescription item.id)
                ]
                []
            ]
        , td []
            [ input
                [ class "inline-input"
                , type_ "number"
                , placeholder "1"
                , value (String.fromFloat item.quantity)
                , onInput (UpdateItemQuantity item.id)
                , style "text-align" "center"
                ]
                []
            ]
        , td []
            [ input
                [ class "inline-input"
                , type_ "number"
                , placeholder "0"
                , value (String.fromFloat item.rate)
                , onInput (UpdateItemRate item.id)
                , style "text-align" "center"
                ]
                []
            ]
        , td [] [ text (formatCurrency currency amount) ]
        , td []
            [ button
                [ onClick (RemoveItem item.id)
                , class "btn-remove"
                ]
                [ text "×" ]
            ]
        ]

-- HELPERS

calculateSubtotal : List LineItem -> Float
calculateSubtotal items =
    List.foldl (\item acc -> acc + (item.quantity * item.rate)) 0 items

formatCurrency : String -> Float -> String
formatCurrency currency amount =
    let
        symbol = case currency of
            "USD" -> "$"
            "EUR" -> "€"
            "GBP" -> "£"
            "IDR" -> "Rp"
            "JPY" -> "¥"
            _ -> "$"

        formatted = String.fromFloat (toFloat (round (amount * 100)) / 100)
    in
    symbol ++ formatted

formatDate : String -> String
formatDate dateString =
    -- Expects format: YYYY-MM-DD
    -- Returns format: 20 January 2025
    if String.isEmpty dateString then
        ""
    else
        case String.split "-" dateString of
            [year, month, day] ->
                let
                    monthName = case month of
                        "01" -> "January"
                        "02" -> "February"
                        "03" -> "March"
                        "04" -> "April"
                        "05" -> "May"
                        "06" -> "June"
                        "07" -> "July"
                        "08" -> "August"
                        "09" -> "September"
                        "10" -> "October"
                        "11" -> "November"
                        "12" -> "December"
                        _ -> month

                    dayNum = String.toInt day |> Maybe.withDefault 0 |> String.fromInt
                in
                dayNum ++ " " ++ monthName ++ " " ++ year

            _ ->
                dateString


-- JSON ENCODING/DECODING

encodeInvoice : Invoice -> String
encodeInvoice invoice =
    Encode.encode 0 <|
        Encode.object
            [ ( "companyName", Encode.string invoice.companyName )
            , ( "companyEmail", Encode.string invoice.companyEmail )
            , ( "companyAddress", Encode.string invoice.companyAddress )
            , ( "companyPhone", Encode.string invoice.companyPhone )
            , ( "logoUrl", encodeMaybeString invoice.logoUrl )
            , ( "customerName", Encode.string invoice.customerName )
            , ( "customerEmail", Encode.string invoice.customerEmail )
            , ( "customerAddress", Encode.string invoice.customerAddress )
            , ( "shipToName", Encode.string invoice.shipToName )
            , ( "shipToEmail", Encode.string invoice.shipToEmail )
            , ( "shipToAddress", Encode.string invoice.shipToAddress )
            , ( "invoiceNumber", Encode.string invoice.invoiceNumber )
            , ( "invoiceDate", Encode.string invoice.invoiceDate )
            , ( "dueDate", Encode.string invoice.dueDate )
            , ( "items", Encode.list encodeLineItem invoice.items )
            , ( "taxRate", Encode.float invoice.taxRate )
            , ( "discount", Encode.float invoice.discount )
            , ( "shipping", Encode.float invoice.shipping )
            , ( "notes", Encode.string invoice.notes )
            ]

encodeMaybeString : Maybe String -> Encode.Value
encodeMaybeString maybeStr =
    case maybeStr of
        Just str ->
            Encode.string str

        Nothing ->
            Encode.null

encodeLineItem : LineItem -> Encode.Value
encodeLineItem item =
    Encode.object
        [ ( "id", Encode.int item.id )
        , ( "description", Encode.string item.description )
        , ( "quantity", Encode.float item.quantity )
        , ( "rate", Encode.float item.rate )
        ]

invoiceDecoder : Decode.Decoder Invoice
invoiceDecoder =
    Decode.succeed Invoice
        |> andMap (Decode.field "companyName" Decode.string)
        |> andMap (Decode.field "companyEmail" Decode.string)
        |> andMap (Decode.field "companyAddress" Decode.string)
        |> andMap (Decode.field "companyPhone" Decode.string)
        |> andMap (Decode.maybe (Decode.field "logoUrl" Decode.string))
        |> andMap (Decode.field "customerName" Decode.string)
        |> andMap (Decode.field "customerEmail" Decode.string)
        |> andMap (Decode.field "customerAddress" Decode.string)
        |> andMap (Decode.oneOf [ Decode.field "shipToName" Decode.string, Decode.succeed "" ])
        |> andMap (Decode.oneOf [ Decode.field "shipToEmail" Decode.string, Decode.succeed "" ])
        |> andMap (Decode.oneOf [ Decode.field "shipToAddress" Decode.string, Decode.succeed "" ])
        |> andMap (Decode.field "invoiceNumber" Decode.string)
        |> andMap (Decode.field "invoiceDate" Decode.string)
        |> andMap (Decode.field "dueDate" Decode.string)
        |> andMap (Decode.field "items" (Decode.list lineItemDecoder))
        |> andMap (Decode.field "taxRate" Decode.float)
        |> andMap (Decode.field "discount" Decode.float)
        |> andMap (Decode.field "shipping" Decode.float)
        |> andMap (Decode.field "notes" Decode.string)

andMap : Decode.Decoder a -> Decode.Decoder (a -> b) -> Decode.Decoder b
andMap =
    Decode.map2 (|>)

lineItemDecoder : Decode.Decoder LineItem
lineItemDecoder =
    Decode.map4 LineItem
        (Decode.field "id" Decode.int)
        (Decode.field "description" Decode.string)
        (Decode.field "quantity" Decode.float)
        (Decode.field "rate" Decode.float)


-- PORTS

port saveToLocalStorage : String -> Cmd msg

port downloadPDF : () -> Cmd msg

port requestLogoUpload : () -> Cmd msg

port logoSelected : (String -> msg) -> Sub msg

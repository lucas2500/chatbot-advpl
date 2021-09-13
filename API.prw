#INCLUDE 'totvs.ch'
#INCLUDE "restful.ch"
#INCLUDE "Protheus.ch"

WSRESTFUL PostMessage DESCRIPTION "API que recebe as requisições da WebHook do Telegram"

	WSMETHOD POST DESCRIPTION "API que recebe as requisições da WebHook do Telegram" WSSYNTAX "/PostMessage"

END WSRESTFUL

WSMETHOD POST WSRECEIVE WSSERVICE PostMessage

	Local cBody    := EncodeUTF8(::GetContent())
	Local oJson    := JSonObject():New()
	Local oJsonRet := JSonObject():New()
	Local cJson    := ""
	Local cMsg     := ""

	oJson:FromJson(cBody)

	DO CASE

	CASE DecodeUTF8(oJson["message"]["text"]) == "Olá"
		cMsg := "Olá visitante!!"

	CASE oJson["message"]["text"] == "Boa noite"
		cMsg := "Boa noite visitante!!"

	OTHERWISE
		cMsg := "Não entendi o que você quis dizer :/"

	END CASE

	If SendMsg(EncodeUTF8(cMsg))
		oJsonRet["BotResponse"] := oJson["message"]["text"]
		Self:SetStatus(200)
	Else
		oJsonRet["BotResponse"] := "Nao foi possivel responder a mensagem no Telegram"
		Self:SetStatus(500)
	Endif

	cJson := oJsonRet:ToJson()
	Self:SetContentType("application/json")
	Self:SetResponse(cJson)

Return .T.

Static Function SendMsg(cMsg)

	Local oRequest  := Nil
	Local lRet      := .F.

	// Endpoint do Telegram
	Local cTelAPI   := SuperGetMV("VAR_TEL", .F., "https://api.telegram.org/")

	// ID do bot do Telegram
	Local BotID     := SuperGetMV("VAR_BOTID", .F., "1488831808:AAGFIouwdQuVbofFrYSZwh6eDSTTgOESl50")

	// ID do chat do Telegram
	Local ChatId    := SuperGetMV("VAR_CHAT", .F., "853200685")

	oRequest := FWRest():New(cTelAPI)
	oRequest:setPath("bot" + BotID + "/sendMessage" + "?chat_id=" + ChatId + "&text=" + cMsg + "&parse_mode=html")

	If oRequest:Get()
		FwLogMsg("INFO", /*cTransactionId*/, "JOBCTCOIN", FunName(), "", "01", "Notifcacao enviada para o Telegram!!")
		lRet := .T.
	Else
		FwLogMsg("INFO", /*cTransactionId*/, "JOBCTCOIN", FunName(), "", "01", "Houve um erro ao enviar a notificacao para o Telegram!!")
	Endif

Return lRet

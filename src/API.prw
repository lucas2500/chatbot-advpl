#INCLUDE 'totvs.ch'
#INCLUDE "restful.ch"
#INCLUDE "Protheus.ch"

/*
@author	Lucas Barbosa
@since	12/09/2021
*/

WSRESTFUL PostMessage DESCRIPTION "API que recebe as requisi��es da WebHook do Telegram"

	WSMETHOD POST DESCRIPTION "Recebe e trata o body enviado pelo Telegram" WSSYNTAX "/PostMessage"

END WSRESTFUL

WSMETHOD POST WSRECEIVE WSSERVICE PostMessage

	Local cBody    := EncodeUTF8(::GetContent())
	Local oJson    := JSonObject():New()
	Local oJsonRet := JSonObject():New()
	Local cJson    := ""
	Local cMsg     := ""
	Local nI       := 0

	oJson:FromJson(cBody)

	DO CASE

	CASE Lower(DecodeUTF8(oJson["message"]["text"])) == "ol�" .OR. Lower(DecodeUTF8(oJson["message"]["text"])) == "boa noite"

		cMsg := "Ol� visitante!!%0A"
		cMsg += "<b>Selecione uma das op��es abaixo:</b>%0A%0A"
		cMsg += "1 - Me diga qual a data de hoje%0A"
		cMsg += "2 - Conte de 1 at� 10%0A"
		cMsg += "3 - Me diga qual � o sentido da vida"

	CASE Lower(DecodeUTF8(oJson["message"]["text"])) == "1"

		cMsg := DTOC(dDatabase)

	CASE Lower(DecodeUTF8(oJson["message"]["text"])) == "2"

		For nI := 1 To 10
			cMsg += cValToChar(nI) + "%0A"
		Next nI

	CASE Lower(DecodeUTF8(oJson["message"]["text"])) == "3"

		cMsg := "Com toda certeza o sentido da vida �: " + LifeMean()

	OTHERWISE
		cMsg := "N�o entendi o que voc� quis dizer :/"

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
	Local BotID     := SuperGetMV("VAR_BOTID", .F., "")

	// ID do chat do Telegram
	Local ChatId    := SuperGetMV("VAR_CHAT", .F., "")

	oRequest := FWRest():New(cTelAPI)
	oRequest:setPath("bot" + BotID + "/sendMessage" + "?chat_id=" + ChatId + "&text=" + cMsg + "&parse_mode=html")

	If oRequest:Get()
		FwLogMsg("INFO", /*cTransactionId*/, "JOBCTCOIN", FunName(), "", "01", "Notifcacao enviada para o Telegram!!")
		lRet := .T.
	Else
		FwLogMsg("INFO", /*cTransactionId*/, "JOBCTCOIN", FunName(), "", "01", "Houve um erro ao enviar a notificacao para o Telegram!!")
	Endif

Return lRet

Static Function LifeMean()

	Local nRandom   := 0
	Local cLifeMean := ""
	Local aLifeMean := {;
		"Maratonar a vers�o estendida de O Senhor dos An�is",; 
		"Definir cronograma sem estimar esfor�o",; 
		"Programar chatbots no s�bado � noite",; 
		"Ver o Palmeiras ser campe�o mundial",;
		"Terminar de assistir One Piece",; 
		"Fazer um update sem where",; 
		"Tunar um Corsa 2005",;
		"Trabalhar na TOTVS",;
		"Aprender ADVPL"}

	nRandom := Randomize(1, Len(aLifeMean))

	cLifeMean := aLifeMean[nRandom]
	
Return cLifeMean

If (Form event code:C388=On Clicked:K2:4)
	C_OBJECT:C1216($voZintParameterv2; $voResult)
	$voZintParameterv2:=New object:C1471
	$voZintParameterv2[ZINT_FORMAT]:=ZINT_Format_SVG  // ZINT_Format_PNG  //
	$voZintParameterv2[ZINT_SECURE]:=2  // Not respected
	//$voZintParameterv2[ZINT_SMALL_TEXT]:=False
	//$voZintParameterv2[ZINT_BOX]:=False
	//$voZintParameterv2[ZINT_BORDER]:=0
	$voZintParameterv2[ZINT_DPI]:=96
	//$voZintParameterv2[ZINT_ROTATE]:=0
	$voZintParameterv2[ZINT_NO_BACKGROUND]:=True:C214
	$voZintParameterv2[ZINT_TYPE]:=BARCODE_QRCODE
	$voZintParameterv2[ZINT_SCALE]:=4
	$voResult:=ZINT(OBJECT Get pointer:C1124(Object named:K67:5; "Eingabe")->; $voZintParameterv2)
	OBJECT Get pointer:C1124(Object named:K67:5; "QRCode")->:=$voResult.image
End if 

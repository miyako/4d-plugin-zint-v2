//%attributes = {}
C_OBJECT:C1216(zint_params)

OB SET:C1220(zint_params;ZINT_TYPE;BARCODE_MICROQR)
  //OB SET(zint_params;ZINT_FORMAT;ZINT_Format_SVG)//fix: default is SVG
OB SET:C1220(zint_params;ZINT_SCALE;10)
OB SET:C1220(zint_params;ZINT_VERSION;4)

$status:=ZINT ("123456789";zint_params)

$image:=$status.image
SET PICTURE TO PASTEBOARD:C521($image)

//%attributes = {}
C_OBJECT:C1216(zint_params)

OB SET:C1220(zint_params;ZINT_TYPE;BARCODE_CODE128)
OB SET:C1220(zint_params;ZINT_FORMAT;ZINT_Format_SVG)
OB SET:C1220(zint_params;ZINT_NO_TEXT;True:C214)

OB SET:C1220(zint_params;ZINT_WHITE_SPACE;5)
OB SET:C1220(zint_params;ZINT_SCALE;10)
OB SET:C1220(zint_params;ZINT_HEIGHT;30)
OB SET:C1220(zint_params;ZINT_BOX;True:C214)
OB SET:C1220(zint_params;ZINT_BORDER;0)

$status:=ZINT ("123456abcdef123456abcdef";zint_params)

$image:=$status.image
SET PICTURE TO PASTEBOARD:C521($image)

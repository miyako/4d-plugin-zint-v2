//%attributes = {}
C_OBJECT:C1216($zint_params)

OB SET:C1220($zint_params;ZINT_TYPE;BARCODE_MICROQR)
  //OB SET($zint_params;ZINT_FORMAT;ZINT_Format_SVG)//fix: default is SVG
OB SET:C1220($zint_params;ZINT_SCALE;10)
OB SET:C1220($zint_params;ZINT_VERSION;1)

  //M1:5 numeric
$status:=ZINT ("12345";$zint_params)
$image:=$status.image
SET PICTURE TO PASTEBOARD:C521($image)

  //M2:10 numeric or 6 alphanumeric
$status:=ZINT ("123457890";$zint_params)
$image:=$status.image
SET PICTURE TO PASTEBOARD:C521($image)

  //M2:10 numeric or 6 alphanumeric
$status:=ZINT ("abcdef";$zint_params)
$image:=$status.image
SET PICTURE TO PASTEBOARD:C521($image)
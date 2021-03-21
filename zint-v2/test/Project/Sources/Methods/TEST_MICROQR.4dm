//%attributes = {}
$params:=New object:C1471

$params[ZINT_TYPE]:=BARCODE_MICROQR
$params[ZINT_FORMAT]:=ZINT_Format_SVG
$params[ZINT_NO_TEXT]:=False:C215
$params[ZINT_WHITE_SPACE]:=5
$params[ZINT_SCALE]:=10
$params[ZINT_HEIGHT]:=30
$params[ZINT_BOX]:=True:C214
$params[ZINT_BORDER]:=0

$status:=ZINT ("12345";$params)

READ PICTURE FILE:C678(Get 4D folder:C485(Current resources folder:K5:16)+"m1.svg";$image)

ASSERT:C1129(Equal pictures:C1196($image;$status.image;$mask))

$status:=ZINT ("123457890";$params)

READ PICTURE FILE:C678(Get 4D folder:C485(Current resources folder:K5:16)+"m2a.svg";$image)

ASSERT:C1129(Equal pictures:C1196($image;$status.image;$mask))

$status:=ZINT ("abcdef";$params)

READ PICTURE FILE:C678(Get 4D folder:C485(Current resources folder:K5:16)+"m2b.svg";$image)

ASSERT:C1129(Equal pictures:C1196($image;$status.image;$mask))

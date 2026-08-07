//%attributes = {"invisible":true}
$params:=New object:C1471

$params[ZINT_TYPE]:=BARCODE_ISBNX
$params[ZINT_FORMAT]:=ZINT_Format_SVG_12
$params[ZINT_NO_TEXT]:=False:C215
$params[ZINT_WHITE_SPACE]:=0
$params[ZINT_SCALE]:=0.75
$params[ZINT_HEIGHT]:=40
$params[ZINT_BOX]:=False:C215
$params[ZINT_BORDER]:=0

$status:=ZINT("9789151107400"; $params)

WRITE PICTURE FILE:C680(System folder:C487(Desktop:K41:16)+"test.svg"; $status.image)
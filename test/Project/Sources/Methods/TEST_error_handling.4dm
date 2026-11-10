//%attributes = {"lang":"en"}
// Run manually in 4D or through test/regression/run_4d.py. Throws on failure.
// Numeric types refer to Zint's API, not hmBarcode IDs.
var $format; $i : Integer
var $longInput : Text:=""
For ($i; 1; 1000)
	$longInput+="A"
End for
var $case; $result : Object
var $failures : Collection:=[{data: "ABC"; type: 1; error: "ERROR_INVALID_DATA"}; {data: ""; type: 20; error: "ERROR_INVALID_DATA"}; {data: $longInput; type: 20; error: "ERROR_TOO_LONG"}]
For each ($format; [1; 2; 3])
	For each ($case; $failures)
		$result:=ZINT($case.data; {type: $case.type; format: $format})
		If ($result.error#$case.error)
			throw(-1; "Unexpected error for format "+String($format)+": "+JSON Stringify($result))
		End if
		If (OB Is defined($result; "image") | OB Is defined($result; "data"))
			throw(-1; "Fatal encoding error returned image/data for format "+String($format))
		End if
		If ((Value type($result.message)#Is text) | ($result.message=""))
			throw(-1; "Missing encoder diagnostic for format "+String($format))
		End if
		If (OB Is defined($result; "warning"))
			throw(-1; "Fatal encoding error also returned a warning")
		End if
	End for each
	// Type 0 is corrected by bundled Zint to Code 128 with WARN_INVALID_OPTION.
	$result:=ZINT("123456"; {type: 0; format: $format})
	If (($result.warning#"WARN_INVALID_OPTION") | OB Is defined($result; "error"))
		throw(-1; "Warning was not preserved for format "+String($format))
	End if
	If ((Picture size($result.image)=0) | ($result.data="") | ($result.message=""))
		throw(-1; "Warning must retain a usable image, data, and diagnostic")
	End if
	// Successful calls after failures/warnings must still render all three types.
	For each ($case; [{data: "123456"+Char(13); type: 20}; {data: "plain Data Matrix"; type: 71}; {data: "https://example.com/?a=1&b=2"; type: 58}])
		$result:=ZINT($case.data; {type: $case.type; format: $format})
		If (OB Is defined($result; "error") | OB Is defined($result; "warning") | OB Is defined($result; "message"))
			throw(-1; "Successful call returned stale diagnostic properties")
		End if
		If ((Picture size($result.image)=0) | ($result.data=""))
			throw(-1; "Successful call returned no image/data")
		End if
	End for each
End for each

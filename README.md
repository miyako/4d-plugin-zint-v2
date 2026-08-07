![version](https://img.shields.io/badge/version-19%2B-5682DF)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/4d-plugin-zint-v2)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-zint-v2/total)

### Dependencies and Licensing

* the source code of this plugin developed using the [4D Plug-in SDK](https://github.com/4d/4D-Plugin-SDK) is licensed under the [MIT license](https://github.com/miyako/4d-plugin-gs/blob/master/LICENSE).
* see [Zint](https://zint.org.uk) for the licensing of **Zint** (shared library).
* the licensing of the binary product of this plugin is subject to the licensing of all its dependencies.

The ZINT plugin wraps the open-source [Zint](https://www.zint.org.uk/) barcode-encoding library so 4D code can generate barcode and 2D-symbol images directly from text data, without shelling out to an external tool. It exposes a single command, `ZINT`, which encodes a text string into any symbology Zint supports and returns the result as either an SVG (vector) or PNG (raster) image, packaged in a 4D `Object` alongside the raw image data and any error/warning the encoder produced.

| Command | Returns | Purpose |
|---|---|---|
| [`ZINT`](#zint) | `Object` | Encode text into a barcode/2D symbol and return it as an SVG or PNG image. |

**Platforms:** macOS and Windows. Reading the full source, the only platform-conditional code is a compiler check (`#ifndef _MSC_VER`) that swaps a C99 variable-length array for `_alloca` on MSVC — an implementation detail with no effect on behavior or output. There is no `VERSIONMAC`/`VERSIONWIN`-style behavioral divergence anywhere in the command.

---

## Requirements & platform notes

- **Parameter 2 (`options`) is mandatory in practice, even though nothing enforces it at the API level.** If it's omitted, or if it isn't an object 4D can resolve, `ZINT` returns an empty `Object` — no `image`, no `data`, and critically, **no `error` property either**. The same silent-empty-object result also occurs on the rare internal failure of Zint's own symbol allocator. If you get back `{}` with nothing on it, check that `options` was actually passed and that it has at minimum a `type`.
- **A non-empty result does not mean encoding succeeded.** Zint's encoder can return several non-fatal-looking error codes (see [Error handling](#error-handling--troubleshooting) below) for which the plugin still renders and returns an `image`/`data` pair from a symbol that failed to encode correctly. Always check for an `error` property first — its presence doesn't get suppressed just because an image also came back.
- **Only `ERROR_MEMORY` and `ERROR_FILE_ACCESS` skip rendering entirely** — those two are the only codes for which the returned object has `error` but no `image`/`data` at all.
- The 4D constants referenced in the plugin's own sample methods (`ZINT_TYPE`, `ZINT_FORMAT`, `ZINT_HEIGHT`, `ZINT_WHITE_SPACE`, `ZINT_SCALE`, `ZINT_BOX`, `ZINT_BORDER`, `ZINT_NO_TEXT`) aren't defined anywhere in the source files this doc was written from, so their exact resolved values aren't directly confirmed here. Given they're used as `options` property keys (e.g. `$params[ZINT_TYPE]:=...`) and the C++ reads those same properties by the literal string names `"type"`, `"format"`, `"height"`, `"white_space"`, `"scale"`, `"box"`, `"border"`, `"no_text"` — it's a near-certain but *inferred* (not directly verified) match. The property tables below always give the verified literal string key as the source of truth; use the 4D constant if your project defines it, or the plain string key otherwise.
- The `4DPlugin-zint.h` header defines a second set of numeric constants (`ZINT_HEIGHT`, `ZINT_BORDER`, `ZINT_BOX`, etc., valued `1`–`23`) and `ZINT_OUTPUT_SVG`/`ZINT_OUTPUT_PNG`/`ZINT_Format_SVG_12` (valued `1`/`2`/`3`). Only the latter three are actually referenced anywhere in the plugin's C++ — the numbered `ZINT_HEIGHT`-style group is unused dead code in the current implementation and should **not** be assumed to correspond to anything on the 4D side.
- As of this build, `rotate: 270` combined with PNG output renders correctly. This is a **forward-looking** statement: it reflects a fix applied during this review to a loop-variable typo that previously caused that specific combination (PNG format + 270° rotation) to hang indefinitely. If you're running an older compiled binary, confirm the fix is actually in it before relying on that combination in production.

---

## ZINT

### Syntax

```4d
ZINT ( data ; options ) → Object
```

#### Parameters

| Parameter | Type | Description |
|---|---|---|
| `data` | Text | The text to encode. Read unconditionally as parameter 1 — always required. |
| `options` | Object | Encoding and rendering options (see table below). See the note above on what happens if this is omitted. |
| Result | Object | The encoded symbol and/or an error/warning. See [Return object](#return-object) below. |

### Description

#### `options` properties

| Property | Type | Range / default | Description |
|---|---|---|---|
| `type` | Number | No default — leaving it unset produces `symbology = 0`, which Zint will almost certainly reject with an error. | The Zint symbology constant to encode as (e.g. `BARCODE_CODE128`, `BARCODE_ISBNX`, `BARCODE_MICROQR`, `BARCODE_QRCODE`...). These are Zint's own numeric symbology IDs; consult your 4D constants list or Zint's own header for the full set — this doc only directly verifies the three used in the plugin's sample methods (`BARCODE_ISBNX`, `BARCODE_MICROQR`, `BARCODE_CODE128`). |
| `format` | Number | Default: SVG (`1`) — any value other than `2` or `3` falls through to SVG. | Output format: `1` = SVG 1.1, `2` = PNG, `3` = SVG 1.2 (the plugin's own CMYK-flavored SVG variant — see notes below). The plugin's sample methods only ever set this to `1`/`3` under the names `ZINT_Format_SVG`/`ZINT_Format_SVG_12`; the value `2` (PNG) has no confirmed 4D constant name in the material this doc was written from. |
| `height` | Number | `1`–`1000`. Values outside this range are silently ignored and Zint's own default (based on symbology) is used instead. | Symbol height in modules. |
| `white_space` | Number | `0`–`1000`, silently ignored outside that range. | Horizontal quiet-zone width. |
| `border` | Number | `0`–`1000`, silently ignored outside that range. | Border width, used together with `box`/`bind` below. |
| `box` | Boolean | Default `false`. | Draws a full box border around the symbol. |
| `bind` | Boolean | Default `false`. | Draws horizontal binding bars above/below the symbol (no side bars). |
| `no_background` | Boolean | Default `true` if omitted. | When `true`, the background is left transparent instead of filled white. |
| `GS1` | Boolean | Default `false`. | Enables GS1 data-mode parsing (`GS1_MODE`). Combinable with `kanji`/`SJIS` below — the plugin OR-combines these onto Zint's `input_mode` bitmask. |
| `no_text` | Boolean | Default `false`. | Suppresses the human-readable text normally drawn under the symbol. |
| `square` | Boolean | Default `false`. | Data Matrix only: forces a square (vs. rectangular) symbol (`DM_SQUARE`). |
| `kanji` | Boolean | Default `false`. | Enables Kanji input mode; character-set conversion is handled internally by Zint. |
| `SJIS` | Boolean | Default `false`. | Enables Shift-JIS input mode; the plugin also switches its own text-encoding conversion (see below) to Shift-JIS when this is set. |
| `small_text` | Boolean | Default `false`. | Uses a smaller built-in bitmap font for the human-readable text in PNG output. |
| `dpi` | Number | Only takes effect above `72`; otherwise the plugin uses `72`. | Resolution metadata embedded in the output (PNG `pHYs` chunk / SVG `ns4d:DPI` attribute). Does not change pixel dimensions, only the resolution the image reports itself as. |
| `scale` | Number | `0.01`–`100`, silently ignored outside that range. | Overall output scale factor. *(The upper bound of `100` was added during this review — see the accompanying source review for why an unbounded value here was unsafe. Older binaries may accept larger values.)* |
| `rotate` | Number | `90`, `180`, or `270`; anything else (including omission) is treated as `0`. | Rotates the rendered output by the given number of degrees. |
| `columns` | Number | `1`–`30`, silently ignored outside that range. | Maps to Zint's generic `option_2` field — meaning depends on the chosen `type` (e.g. PDF417 column count). Writes the same underlying field as `version` below; if both are set, whichever is read last in the options object wins. |
| `version` | Number | `1`–`40`, silently ignored outside that range. | Also maps to `option_2`. **Micro QR (`BARCODE_MICROQR`) is a traced special case:** the plugin remaps `version` values `1`–`4` down to Zint's internal `0`–`3` before encoding, so use `1`–`4` (not `0`–`3`) to select Micro QR versions M1–M4. |
| `secure` | Number | `1`–`8`, silently ignored outside that range. | Maps to Zint's generic `option_1` field (e.g. PDF417 security/error-correction level, depending on symbology). |
| `primary` | Text | Max 90 characters — longer values are silently dropped (not truncated; the field is left at its previous/empty value). | Composite-symbol "primary message" field, copied into Zint's internal buffer. |
| `mode` | Number | `0`–`6`, silently ignored outside that range. | Maps to Zint's generic `option_1` field for symbologies that use a mode selector (meaning is symbology-dependent). |

#### Return object

| Property | Type | Present when | Description |
|---|---|---|---|
| `image` | Picture | Encoding reached the rendering stage (i.e. not `ERROR_MEMORY`/`ERROR_FILE_ACCESS`) and `pixelbuf`/SVG buffer allocation succeeded. | A native 4D `Picture`. For SVG output this wraps the SVG source directly; for PNG output it wraps genuine PNG bytes. |
| `data` | Text | Same conditions as `image`. | The same image content as text: raw SVG markup for `format` `1`/`3`, or **Base64-encoded PNG bytes** for `format` `2`. These are built through different internal code paths, so don't assume `data` is always human-readable markup — check `format` before parsing it. |
| `error` | Text | `ZBarcode_Encode` returned one of: `ERROR_MEMORY`, `ERROR_FILE_ACCESS`, `ERROR_ENCODING_PROBLEM`, `ERROR_INVALID_OPTION`, `ERROR_INVALID_CHECK`, `ERROR_INVALID_DATA`, `ERROR_TOO_LONG`. | The literal error constant name as text (e.g. `"ERROR_TOO_LONG"`). See [Error handling](#error-handling--troubleshooting) for what each means and whether `image`/`data` still come back alongside it. |
| `warning` | Text | `ZBarcode_Encode` returned `WARN_INVALID_OPTION`. | Set instead of (not in addition to) `error` — encoding still proceeds and `image`/`data` are still populated. |

### Example

From the plugin's own test method (`TEST_ISBN.4dm`) — SVG 1.2 output:

```4d
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
```

From the plugin's own test method (`TEST_MICROQR.4dm`) — note the round-trip comparison pattern against known-good reference images, and the plain `Boolean` literals used for `box`/`no_text`:

```4d
//%attributes = {"invisible":true}
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
```

A PNG variant, built from the property table above rather than a provided sample — hedged accordingly since no sample file in this project exercises PNG output. `2` is used literally for `format` because no confirmed 4D constant name for PNG exists in the material reviewed; check your own constants list before assuming a name for it:

```4d
$params:=New object

$params.type:=BARCODE_CODE128
$params.format:=2  // PNG — verify the actual 4D constant name against your project's constants list
$params.height:=50
$params.scale:=2
$params.no_background:=False

$status:=ZINT("4D-2026-08"; $params)

If ($status.error#Null)
	ALERT:C41("Barcode encoding failed: "+$status.error)
Else 
	WRITE PICTURE FILE("test.png"; $status.image)
End if 
```

A minimal error-handling wrapper, showing the check that matters most (per the note in [Requirements & platform notes](#requirements--platform-notes) about non-empty results that still carry an error):

```4d
$params:=New object
$params.type:=BARCODE_QRCODE
$params.format:=1

$status:=ZINT($myText; $params)

If ($status.error#Null)
	ALERT("Encoding problem: "+$status.error)
Else 
	If ($status.warning#Null)
		// still usable, but Zint had to silently correct something
	End if 
	$pict:=$status.image
End if 
```

---

## Error handling & troubleshooting

- **An empty `{}` result usually means `options` was missing or unresolvable, not that encoding failed.** `ZINT` only ever populates `error`/`warning` after it has successfully entered the encoding branch — omitting `options` entirely, or a rare internal `ZBarcode_Create` allocation failure, both return a plain empty object with none of `image`/`data`/`error` set. There's nothing in the current source that distinguishes these two causes from the caller's side.
- **`error` can be present alongside a populated `image`/`data`.** Only `ERROR_MEMORY` and `ERROR_FILE_ACCESS` suppress rendering; every other error code (`ERROR_ENCODING_PROBLEM`, `ERROR_INVALID_OPTION`, `ERROR_INVALID_CHECK`, `ERROR_INVALID_DATA`, `ERROR_TOO_LONG`) and the one warning code (`WARN_INVALID_OPTION`) still fall through to rendering. Treat `error#Null` as the authoritative success/failure signal, not the presence of `image`.
- **`ERROR_TOO_LONG`** — the input `data` exceeds the chosen symbology's maximum data capacity.
- **`ERROR_INVALID_DATA`** — `data` contains characters the chosen symbology (or input mode, e.g. `GS1`/numeric-only symbologies) can't encode.
- **`ERROR_INVALID_CHECK`** — a check-digit embedded in `data` (for symbologies that validate one, e.g. ISBN) doesn't match.
- **`ERROR_INVALID_OPTION`** — an `options` value is inconsistent with the chosen `type` (e.g. a `columns`/`version`/`secure` value the symbology doesn't support).
- **`ERROR_ENCODING_PROBLEM`** — an internal Zint encoding failure specific to certain symbologies.
- **`ERROR_MEMORY`** — Zint failed to allocate memory internally. No `image`/`data` returned.
- **`ERROR_FILE_ACCESS`** — Zint attempted and failed a file read internally. No `image`/`data` returned. (Not applicable to any usage pattern shown in this plugin's own samples, all of which pass plain text.)
- **`WARN_INVALID_OPTION`** — a non-fatal invalid `options` value was corrected automatically; encoding proceeded and `image`/`data` are populated normally.
- **`scale`, `height`, `white_space`, `border`, `columns`, `version`, `secure`, and `mode` are all silently clamped/ignored outside their documented ranges**, with no `warning`/`error` raised for the out-of-range value itself — the call will look like it succeeded using Zint's own default for that field instead of what you passed.
- **`columns` and `version` write the same internal field.** Setting both in the same `options` object means one silently overrides the other with no conflict signal — don't set both unless you've confirmed which one you actually want to win.
- **PNG + `rotate: 270` requires the fixed build.** See the forward-looking note in [Requirements & platform notes](#requirements--platform-notes) — on an unpatched binary this specific combination hangs rather than erroring, with no `error` property to catch, because the call never returns.

---

## Quick reference

```4d
// SVG
$params:=New object
$params.type:=BARCODE_CODE128
$params.format:=1
$params.height:=40
$params.scale:=2
$status:=ZINT("123456789"; $params)
If ($status.error=Null)
	WRITE PICTURE FILE("barcode.svg"; $status.image)
End if 

// SVG 1.2 (CMYK)
$params:=New object
$params.type:=BARCODE_ISBNX
$params.format:=3
$params.height:=40
$status:=ZINT("9789151107400"; $params)

// Micro QR, version M4
$params:=New object
$params.type:=BARCODE_MICROQR
$params.format:=1
$params.version:=4
$status:=ZINT("12345"; $params)

// PNG — confirm the constant/value for format:2 against your own project
$params:=New object
$params.type:=BARCODE_QRCODE
$params.format:=2
$params.no_background:=False
$status:=ZINT("https://example.com"; $params)
If ($status.error=Null)
	WRITE PICTURE FILE("qr.png"; $status.image)
End if 
```

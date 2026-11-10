#!/usr/bin/env python3
"""Run ZINT error regressions in an isolated, dataless tool4d project."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--bundle', type=Path, required=True, help='Freshly built zint.bundle')
parser.add_argument('--tool', default='/Applications/tool4d.app/Contents/MacOS/tool4d')
args = parser.parse_args()
method = Path(__file__).resolve().parents[1] / 'Project/Sources/Methods/TEST_error_handling.4dm'
with tempfile.TemporaryDirectory(prefix='zint-errors-') as temp:
    base = Path(temp)
    methods = base / 'Project/Sources/Methods'
    methods.mkdir(parents=True)
    (base / 'Resources').mkdir()
    project = base / 'Project/Regression.4DProject'
    project.write_text(json.dumps({'compatibilityVersion': 1901, 'tokenizedText': False}))
    shutil.copytree(args.bundle.resolve(), base / 'Plugins/zint.bundle')
    shutil.copy2(method, methods)
    (methods / 'Run.4dm').write_text('''//%attributes = {"lang":"en"}
var $report : Object:={success: False}
Try
    TEST_error_handling
    $report.success:=True
Catch
    $report.errors:=Last errors
End try
Folder(fk resources folder).file("result.json").setText(JSON Stringify($report); "UTF-8-no-bom")
QUIT 4D
''')
    process = subprocess.run([args.tool, f'--project={project}', '--dataless',
                              '--skip-onstartup', '--startup-method=Run'],
                             capture_output=True, text=True, timeout=60)
    report = base / 'Resources/result.json'
    if process.returncode or not report.exists():
        raise RuntimeError(f'4D exited {process.returncode}: {process.stdout}\n{process.stderr}')
    result = json.loads(report.read_text())
    if not result.get('success'):
        raise AssertionError(json.dumps(result, indent=2))
    print('Passed: fatal errors, warning output, and successful calls for SVG, PNG, and SVG 1.2.')

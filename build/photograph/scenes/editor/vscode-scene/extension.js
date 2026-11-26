// Stages the editor scene in ~/Inglenook (see ../prepare.sh). Finds its places by text,
// so the content can change without touching this file.
const vscode = require('vscode');

const FILE = 'build/lib/Contrast.psm1';
const ERROR = 'Get-Luminence';
const ERROR_MESSAGE = "The term 'Get-Luminence' is not recognized as a name of a cmdlet or function.";
const SELECT_FROM = '$hi = ';   // the selection runs from here to the end of the next line
const SELECT_LINES = 2;

function find(doc, text) {
  for (let i = 0; i < doc.lineCount; i++) {
    const at = doc.lineAt(i).text.indexOf(text);
    if (at >= 0) return new vscode.Position(i, at);
  }
  throw new Error(`vscode-scene: "${text}" is not in ${FILE}`);
}

exports.activate = async function (context) {
  const folder = vscode.workspace.workspaceFolders && vscode.workspace.workspaceFolders[0];
  if (!folder) return;
  const uri = vscode.Uri.joinPath(folder.uri, FILE);
  const doc = await vscode.workspace.openTextDocument(uri);

  const errorAt = find(doc, ERROR);
  const problems = vscode.languages.createDiagnosticCollection('inglenook-scene');
  problems.set(uri, [new vscode.Diagnostic(
    new vscode.Range(errorAt, errorAt.translate(0, ERROR.length)), ERROR_MESSAGE, vscode.DiagnosticSeverity.Error)]);
  context.subscriptions.push(problems);

  // The selection comes with the editor, so the window title (which names the file)
  // changes only once the scene is all there.
  const start = find(doc, SELECT_FROM);
  const endLine = start.line + SELECT_LINES - 1;
  const end = new vscode.Position(endLine, doc.lineAt(endLine).text.length);
  const editor = await vscode.window.showTextDocument(doc, { preview: false, selection: new vscode.Range(start, end) });
  // The window may still be growing to its size, so the editor can scroll to center the
  // selection. The whole file fits: show it from the top.
  editor.revealRange(new vscode.Range(0, 0, 0, 0), vscode.TextEditorRevealType.AtTop);
};

exports.deactivate = function () {};

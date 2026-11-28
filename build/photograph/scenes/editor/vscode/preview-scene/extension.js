// Opens ~/Notes/Hearth.md in the Markdown preview beside the code (see ../stage.sh).
// Waits for the editor scene's file to be the active editor, so the preview opens to its
// right, and keeps the focus on it, so the window title still names that file.
const vscode = require('vscode');
const os = require('os');
const path = require('path');

const FILE = 'Contrast.psm1';
const NOTE = path.join(os.homedir(), 'Notes', 'Hearth.md');

function isScene(editor) {
  return editor && path.basename(editor.document.uri.fsPath) === FILE;
}

exports.activate = function (context) {
  let done = false;
  const open = async () => {
    if (done) return;
    done = true;
    await vscode.commands.executeCommand('vscode.openWith', vscode.Uri.file(NOTE), 'vscode.markdown.preview.editor',
      { viewColumn: vscode.ViewColumn.Beside, preserveFocus: true });
  };
  if (isScene(vscode.window.activeTextEditor)) { open(); return; }
  context.subscriptions.push(vscode.window.onDidChangeActiveTextEditor(e => { if (isScene(e)) open(); }));
};

exports.deactivate = function () {};

// Inglenook Day for Insomnia, part of Inglenook 0.1.1.
// https://github.com/mookeyj79/Inglenook
//
// Insomnia reads its colors from a theme plugin: module.exports.themes, with
// background, foreground and highlight blocks, styles for parts of the app, and
// rawCss for what the blocks cannot reach. Every highlight is solid.

const rawCss = `
/* Selection and cursor in the editors. */
.editor .CodeMirror-selected,
.editor .CodeMirror-focused .CodeMirror-selected,
.editor .CodeMirror-line::selection,
.editor .CodeMirror-line > span::selection,
.editor .CodeMirror-line > span > span::selection {
  background: #e3dbc8;
}
::selection {
  background: #e3dbc8;
  color: #2d373f;
}
.editor .CodeMirror-cursor {
  border-left-color: #9b5a00;
}
.editor .CodeMirror-matchingbracket {
  text-decoration-color: #9b5a00;
}

/* Search matches: a steel wash, text on it. */
.editor .CodeMirror .cm-searching {
  background: #d2dddf;
  color: #2d373f;
  border-bottom: 0;
}

/* Line numbers and gutters. */
.editor .CodeMirror-linenumber {
  --hl-xl: #657178;
}

/* Syntax, by meaning. */
.editor .cm-property,
.editor .cm-attribute,
.editor .cm-builtin,
.editor .cm-def,
.editor .cm-variable-2 {
  color: #326893;
}
.editor .cm-string,
.editor .cm-string-2 {
  color: #407135;
}
.editor .cm-string.cm-property {
  color: #326893;
}
.editor .cm-number {
  color: #915023;
}
.editor .cm-atom,
.editor .cm-keyword,
.editor .cm-header {
  color: #844b80;
}
.editor .cm-variable-3,
.editor .cm-type {
  color: #5e5a9a;
}
.editor .cm-tag {
  color: #905560;
}
.editor .cm-link,
.editor .cm-nunjucks-variable,
.editor .cm-nunjucks-tag {
  color: #017272;
}
.editor .cm-variable {
  color: #2d373f;
}
.editor .cm-bracket,
.editor .cm-punctuation,
.editor .cm-meta,
.editor .cm-qualifier {
  color: #49545d;
}
.editor .cm-comment,
.editor .cm-nunjucks-comment,
.editor .cm-curl-comment {
  color: #657178;
}
.editor .cm-error {
  background: none;
  color: #a04037;
}

/* HTTP methods by meaning: reading is information, creating is success,
   changing is a warning, removing is an error, asking about a resource is quiet.
   Insomnia draws GET, QUERY and GraphQL in its accent color, and HEAD and OPTIONS
   in its info color, so those two are moved here. */
.http-method-GET,
.http-method-QUERY,
.http-method-GQL,
.bg-http-method-GET,
.bg-http-method-QUERY,
button[aria-label="Request Method"][class*="--color-surprise"] {
  --color-surprise: #326893;
  --color-font-surprise: #f9fbf8;
}
.http-method-HEAD,
.http-method-OPTIONS,
.bg-http-method-HEAD,
.bg-http-method-OPTIONS,
button[aria-label="Request Method"][class*="--color-info"] {
  --color-info: #49545d;
  --color-font-info: #f9fbf8;
}
/* Status tags: Insomnia draws 3xx redirects in its accent color; they are information. */
.tag.bg-surprise {
  --color-surprise: #326893;
  --color-font-surprise: #f9fbf8;
}
/* The method button beside the URL: a solid fill, without the app's darkening layer. */
button[aria-label="Request Method"] {
  background-image: none;
}
/* Method tags in the sidebar and tabs: a solid wash of the method's color, text on it. */
span[class*="rgba(var(--color-surprise-rgb),0.5)"] {
  background: #d2dddf;
  color: #2d373f;
}
span[class*="rgba(var(--color-success-rgb),0.5)"] {
  background: #d5ded0;
  color: #2d373f;
}
span[class*="rgba(var(--color-warning-rgb),0.5)"],
span[class*="rgba(var(--color-notice-rgb),0.5)"] {
  background: #dcdccb;
  color: #2d373f;
}
span[class*="rgba(var(--color-danger-rgb),0.5)"] {
  background: #e4d6d1;
  color: #2d373f;
}
span[class*="rgba(var(--color-info-rgb),0.5)"] {
  background: #dbded6;
  color: #2d373f;
}
`;

module.exports.themes = [
  {
    name: 'inglenook-day',
    displayName: 'Inglenook Day',
    theme: {
      background: {
        default: '#f1f3ee',
        success: '#407135',
        notice: '#706416',
        warning: '#706416',
        danger: '#a04037',
        surprise: '#9b5a00',
        info: '#326893',
      },
      foreground: {
        default: '#2d373f',
        success: '#f9fbf8',
        notice: '#f9fbf8',
        warning: '#f9fbf8',
        danger: '#f9fbf8',
        surprise: '#f9fbf8',
        info: '#f9fbf8',
      },
      highlight: {
        default: '#657178',
        xxs: '#e9ebe5',
        xs: '#dbded6',
        sm: '#cfd2cb',
        md: '#cfd2cb',
        lg: '#657178',
        xl: '#49545d',
      },
      rawCss,
      styles: {
        appHeader: {
          background: { default: '#e0e2dc' },
          foreground: { default: '#2d373f' },
        },
        sidebar: {
          background: { default: '#e9ebe5' },
          foreground: { default: '#2d373f' },
        },
        sidebarHeader: {
          background: { default: '#e9ebe5' },
          foreground: { default: '#2d373f' },
        },
        sidebarList: {
          background: { default: '#e9ebe5' },
          foreground: { default: '#2d373f' },
        },
        pane: {
          background: { default: '#f1f3ee' },
          foreground: { default: '#2d373f' },
        },
        paneHeader: {
          background: { default: '#f1f3ee' },
          foreground: { default: '#2d373f' },
        },
        editor: {
          background: { default: '#f1f3ee' },
          foreground: { default: '#2d373f' },
        },
        dialog: {
          background: { default: '#f9fbf8' },
          foreground: { default: '#2d373f' },
        },
        dialogHeader: {
          background: { default: '#f9fbf8' },
          foreground: { default: '#2d373f' },
        },
        dialogFooter: {
          background: { default: '#f9fbf8' },
          foreground: { default: '#2d373f' },
        },
        dropdown: {
          background: { default: '#f9fbf8' },
          foreground: { default: '#2d373f' },
        },
        tooltip: {
          background: { default: '#f9fbf8' },
          foreground: { default: '#2d373f' },
        },
        link: {
          foreground: { default: '#9b5a00' },
        },
      },
    },
  },
];

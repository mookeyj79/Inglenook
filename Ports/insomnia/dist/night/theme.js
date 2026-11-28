// Inglenook Night for Insomnia, part of Inglenook 0.1.1.
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
  background: #463624;
}
::selection {
  background: #463624;
  color: #d1c9bc;
}
.editor .CodeMirror-cursor {
  border-left-color: #f3a958;
}
.editor .CodeMirror-matchingbracket {
  text-decoration-color: #f3a958;
}

/* Search matches: a steel wash, text on it. */
.editor .CodeMirror .cm-searching {
  background: #31383e;
  color: #d1c9bc;
  border-bottom: 0;
}

/* Line numbers and gutters. */
.editor .CodeMirror-linenumber {
  --hl-xl: #8f887f;
}

/* Syntax, by meaning. */
.editor .cm-property,
.editor .cm-attribute,
.editor .cm-builtin,
.editor .cm-def,
.editor .cm-variable-2 {
  color: #89b3d8;
}
.editor .cm-string,
.editor .cm-string-2 {
  color: #91bc88;
}
.editor .cm-string.cm-property {
  color: #89b3d8;
}
.editor .cm-number {
  color: #da9f7c;
}
.editor .cm-atom,
.editor .cm-keyword,
.editor .cm-header {
  color: #cb9cc6;
}
.editor .cm-variable-3,
.editor .cm-type {
  color: #a5a5d9;
}
.editor .cm-tag {
  color: #d4a2aa;
}
.editor .cm-link,
.editor .cm-nunjucks-variable,
.editor .cm-nunjucks-tag {
  color: #72bdbd;
}
.editor .cm-variable {
  color: #d1c9bc;
}
.editor .cm-bracket,
.editor .cm-punctuation,
.editor .cm-meta,
.editor .cm-qualifier {
  color: #b1aa9e;
}
.editor .cm-comment,
.editor .cm-nunjucks-comment,
.editor .cm-curl-comment {
  color: #8f887f;
}
.editor .cm-error {
  background: none;
  color: #d9897e;
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
  --color-surprise: #89b3d8;
  --color-font-surprise: #12100e;
}
.http-method-HEAD,
.http-method-OPTIONS,
.bg-http-method-HEAD,
.bg-http-method-OPTIONS,
button[aria-label="Request Method"][class*="--color-info"] {
  --color-info: #b1aa9e;
  --color-font-info: #12100e;
}
/* Status tags: Insomnia draws 3xx redirects in its accent color; they are information. */
.tag.bg-surprise {
  --color-surprise: #89b3d8;
  --color-font-surprise: #12100e;
}
/* The method button beside the URL: a solid fill, without the app's darkening layer. */
button[aria-label="Request Method"] {
  background-image: none;
}
/* Method tags in the sidebar and tabs: a solid wash of the method's color, text on it. */
span[class*="rgba(var(--color-surprise-rgb),0.5)"] {
  background: #31383e;
  color: #d1c9bc;
}
span[class*="rgba(var(--color-success-rgb),0.5)"] {
  background: #333a2e;
  color: #d1c9bc;
}
span[class*="rgba(var(--color-warning-rgb),0.5)"],
span[class*="rgba(var(--color-notice-rgb),0.5)"] {
  background: #3b382a;
  color: #d1c9bc;
}
span[class*="rgba(var(--color-danger-rgb),0.5)"] {
  background: #412f2c;
  color: #d1c9bc;
}
span[class*="rgba(var(--color-info-rgb),0.5)"] {
  background: #312e2c;
  color: #d1c9bc;
}
`;

module.exports.themes = [
  {
    name: 'inglenook-night',
    displayName: 'Inglenook Night',
    theme: {
      background: {
        default: '#1b1917',
        success: '#91bc88',
        notice: '#bdb377',
        warning: '#bdb377',
        danger: '#d9897e',
        surprise: '#f3a958',
        info: '#89b3d8',
      },
      foreground: {
        default: '#d1c9bc',
        success: '#12100e',
        notice: '#12100e',
        warning: '#12100e',
        danger: '#12100e',
        surprise: '#12100e',
        info: '#12100e',
      },
      highlight: {
        default: '#8f887f',
        xxs: '#171412',
        xs: '#312e2c',
        sm: '#363331',
        md: '#363331',
        lg: '#8f887f',
        xl: '#b1aa9e',
      },
      rawCss,
      styles: {
        appHeader: {
          background: { default: '#12100e' },
          foreground: { default: '#d1c9bc' },
        },
        sidebar: {
          background: { default: '#171412' },
          foreground: { default: '#d1c9bc' },
        },
        sidebarHeader: {
          background: { default: '#171412' },
          foreground: { default: '#d1c9bc' },
        },
        sidebarList: {
          background: { default: '#171412' },
          foreground: { default: '#d1c9bc' },
        },
        pane: {
          background: { default: '#1b1917' },
          foreground: { default: '#d1c9bc' },
        },
        paneHeader: {
          background: { default: '#1b1917' },
          foreground: { default: '#d1c9bc' },
        },
        editor: {
          background: { default: '#1b1917' },
          foreground: { default: '#d1c9bc' },
        },
        dialog: {
          background: { default: '#262321' },
          foreground: { default: '#d1c9bc' },
        },
        dialogHeader: {
          background: { default: '#262321' },
          foreground: { default: '#d1c9bc' },
        },
        dialogFooter: {
          background: { default: '#262321' },
          foreground: { default: '#d1c9bc' },
        },
        dropdown: {
          background: { default: '#262321' },
          foreground: { default: '#d1c9bc' },
        },
        tooltip: {
          background: { default: '#262321' },
          foreground: { default: '#d1c9bc' },
        },
        link: {
          foreground: { default: '#f3a958' },
        },
      },
    },
  },
];

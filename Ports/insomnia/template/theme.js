// {{variant.name}} for Insomnia, part of {{meta.name}} {{meta.version}}.
// {{meta.repository}}
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
  background: {{accent|wash}};
}
::selection {
  background: {{accent|wash}};
  color: {{text}};
}
.editor .CodeMirror-cursor {
  border-left-color: {{accent}};
}
.editor .CodeMirror-matchingbracket {
  text-decoration-color: {{accent}};
}

/* Search matches: a steel wash, text on it. */
.editor .CodeMirror .cm-searching {
  background: {{steel|wash}};
  color: {{text}};
  border-bottom: 0;
}

/* Line numbers and gutters. */
.editor .CodeMirror-linenumber {
  --hl-xl: {{faint}};
}

/* Syntax, by meaning. */
.editor .cm-property,
.editor .cm-attribute,
.editor .cm-builtin,
.editor .cm-def,
.editor .cm-variable-2 {
  color: {{info}};
}
.editor .cm-string,
.editor .cm-string-2 {
  color: {{success}};
}
.editor .cm-string.cm-property {
  color: {{info}};
}
.editor .cm-number {
  color: {{literal}};
}
.editor .cm-atom,
.editor .cm-keyword,
.editor .cm-header {
  color: {{keyword}};
}
.editor .cm-variable-3,
.editor .cm-type {
  color: {{type}};
}
.editor .cm-tag {
  color: {{tag}};
}
.editor .cm-link,
.editor .cm-nunjucks-variable,
.editor .cm-nunjucks-tag {
  color: {{reference}};
}
.editor .cm-variable {
  color: {{text}};
}
.editor .cm-bracket,
.editor .cm-punctuation,
.editor .cm-meta,
.editor .cm-qualifier {
  color: {{dim}};
}
.editor .cm-comment,
.editor .cm-nunjucks-comment,
.editor .cm-curl-comment {
  color: {{faint}};
}
.editor .cm-error {
  background: none;
  color: {{error}};
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
  --color-surprise: {{info}};
  --color-font-surprise: {{on_accent}};
}
.http-method-HEAD,
.http-method-OPTIONS,
.bg-http-method-HEAD,
.bg-http-method-OPTIONS,
button[aria-label="Request Method"][class*="--color-info"] {
  --color-info: {{dim}};
  --color-font-info: {{on_accent}};
}
/* Status tags: Insomnia draws 3xx redirects in its accent color; they are information. */
.tag.bg-surprise {
  --color-surprise: {{info}};
  --color-font-surprise: {{on_accent}};
}
/* The method button beside the URL: a solid fill, without the app's darkening layer. */
button[aria-label="Request Method"] {
  background-image: none;
}
/* Method tags in the sidebar and tabs: a solid wash of the method's color, text on it. */
span[class*="rgba(var(--color-surprise-rgb),0.5)"] {
  background: {{info|wash}};
  color: {{text}};
}
span[class*="rgba(var(--color-success-rgb),0.5)"] {
  background: {{success|wash}};
  color: {{text}};
}
span[class*="rgba(var(--color-warning-rgb),0.5)"],
span[class*="rgba(var(--color-notice-rgb),0.5)"] {
  background: {{warning|wash}};
  color: {{text}};
}
span[class*="rgba(var(--color-danger-rgb),0.5)"] {
  background: {{error|wash}};
  color: {{text}};
}
span[class*="rgba(var(--color-info-rgb),0.5)"] {
  background: {{hover}};
  color: {{text}};
}
`;

module.exports.themes = [
  {
    name: '{{variant.slug}}',
    displayName: '{{variant.name}}',
    theme: {
      background: {
        default: '{{base}}',
        success: '{{success}}',
        notice: '{{warning}}',
        warning: '{{warning}}',
        danger: '{{error}}',
        surprise: '{{accent}}',
        info: '{{info}}',
      },
      foreground: {
        default: '{{text}}',
        success: '{{on_accent}}',
        notice: '{{on_accent}}',
        warning: '{{on_accent}}',
        danger: '{{on_accent}}',
        surprise: '{{on_accent}}',
        info: '{{on_accent}}',
      },
      highlight: {
        default: '{{faint}}',
        xxs: '{{deep}}',
        xs: '{{hover}}',
        sm: '{{line}}',
        md: '{{line}}',
        lg: '{{faint}}',
        xl: '{{dim}}',
      },
      rawCss,
      styles: {
        appHeader: {
          background: { default: '{{deeper}}' },
          foreground: { default: '{{text}}' },
        },
        sidebar: {
          background: { default: '{{deep}}' },
          foreground: { default: '{{text}}' },
        },
        sidebarHeader: {
          background: { default: '{{deep}}' },
          foreground: { default: '{{text}}' },
        },
        sidebarList: {
          background: { default: '{{deep}}' },
          foreground: { default: '{{text}}' },
        },
        pane: {
          background: { default: '{{base}}' },
          foreground: { default: '{{text}}' },
        },
        paneHeader: {
          background: { default: '{{base}}' },
          foreground: { default: '{{text}}' },
        },
        editor: {
          background: { default: '{{base}}' },
          foreground: { default: '{{text}}' },
        },
        dialog: {
          background: { default: '{{raised}}' },
          foreground: { default: '{{text}}' },
        },
        dialogHeader: {
          background: { default: '{{raised}}' },
          foreground: { default: '{{text}}' },
        },
        dialogFooter: {
          background: { default: '{{raised}}' },
          foreground: { default: '{{text}}' },
        },
        dropdown: {
          background: { default: '{{raised}}' },
          foreground: { default: '{{text}}' },
        },
        tooltip: {
          background: { default: '{{raised}}' },
          foreground: { default: '{{text}}' },
        },
        link: {
          foreground: { default: '{{accent}}' },
        },
      },
    },
  },
];

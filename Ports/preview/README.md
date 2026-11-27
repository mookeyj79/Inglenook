# Inglenook preview site

**Variants:** Inglenook Day, Inglenook Night\
**Tested with:** Not tested yet

A web page that shows Inglenook before you install anything: a terminal session, a code sample, a diagram and a small app, in Day or Night, then every color with its value and contrast, the roles, and how code is colored. A second page lists every port with its category, tier and platforms, plus the planned ones, with search and category filters. Each port's install guide is published as a page of its own.

## View it

- Preview: <https://mookeyj79.github.io/Inglenook/>
- Ports page: <https://mookeyj79.github.io/Inglenook/ports/>

The page frame opens in Day or Night to match your OS setting, and remembers the variant you pick with the switch. Add `?variant=day` or `?variant=night` to a link to open a set variant. From a copy of this repo, open `Ports/preview/dist/day/index.html` in a browser.

## Known limits

- The demos show how Inglenook is meant to look. They are not screenshots of real ports.
- Offline, the page falls back to system fonts, and the diagram shows as plain text.

## Sources

- [IBM Plex](https://github.com/IBM/plex) Sans, Serif and Mono, loaded from Google Fonts, under the SIL Open Font License 1.1.
- [Mermaid](https://github.com/mermaid-js/mermaid), which draws the diagram, loaded from jsDelivr, under the MIT License.
- The wallpapers behind the page, resized for the web: [Cabin Seating](../../wallpapers/README.md#cabin-seating) by Shixart1985 under CC BY 2.0 in Day, and [Mission Fireplace](../../wallpapers/README.md#mission-fireplace) by Richard N Horne under CC BY-SA 4.0 in Night.
